classdef testBuildfile < matlab.unittest.TestCase
   %TESTBUILDFILE Test the build plan, its tasks, and releasefile.
   %
   % The plan case reads the buildfile from the project root, the way
   % buildtool discovers it, without side effects. Every other case
   % runs against an owned temporary fixture (a clean synthetic
   % project, or a copy of the template), so nothing is written under
   % the checkout. All cases restore the path and close any Project
   % they open (shared suite helper).
   %
   % The clean-fixture pipeline case runs buildtool("release"), which
   % executes checkTask and testTask as gates and releaseTask's
   % delegation to releasefile. The seeded-defect case pins the
   % matfunclib-juq.27 behavior: a check from the project root fails
   % on a defect the nested build/ layout reported green.

   properties
      % Project root (the folder holding buildfile.m), derived from
      % this file so the suite runs from any folder.
      Root
   end

   methods (TestClassSetup)
      function locateRoot(testCase)
         testCase.Root = string(fileparts(fileparts( ...
            mfilename('fullpath'))));

         % releasefile calls addpath on the shipped folder; put the
         % path back after the class, and close any Project a case
         % opens, so later suites see the state they started with.
         saved = path();
         testCase.addTeardown(@() path(saved));
         testCase.addTeardown(@() closetestproject(testCase.Root));
      end
   end

   methods (Access = private)
      function root = makeCleanFixture(testCase, tmpFolder)
         % A minimal clean project the whole pipeline can pass: root
         % build files, one lint-clean shipped function in a
         % namespace, the namespace-stamped internals releasefile
         % dispatches to (the same rename stamping performs), an empty
         % test folder, and a pinned version.
         root = fullfile(string(tmpFolder), "cleanproj");
         mkdir(fullfile(root, "toolbox", "+syn", "+internal"))
         mkdir(fullfile(root, "test"))
         copyfile(fullfile(testCase.Root, "buildfile.m"), root)
         copyfile(fullfile(testCase.Root, "releasefile.m"), root)
         copyfile(fullfile(testCase.Root, "private"), ...
            fullfile(root, "private"))
         writelines("v0.3.0", fullfile(root, "toolbox", "version.txt"));
         writelines([ ...
            "function y = synfun(x)"; ...
            "   %SYNFUN Identity function for the build fixture."; ...
            "   y = x;"; ...
            "end"], ...
            fullfile(root, "toolbox", "+syn", "synfun.m"));
         for name = ["releaseoptions.m", "version.m"]
            stamped = strrep(string(fileread(fullfile(testCase.Root, ...
               "toolbox", "+tbx", "+internal", name))), ...
               "tbx.internal", "syn.internal");
            writelines(splitlines(stamped), ...
               fullfile(root, "toolbox", "+syn", "+internal", name));
         end
      end
   end

   methods (Test)
      function testPlanHasTheFourTasks(testCase)
         % The plan resolves from the project root with the check,
         % test, contents, and release tasks, and the release task
         % depends on check and test so packaging cannot skip them.
         import matlab.unittest.fixtures.CurrentFolderFixture
         testCase.applyFixture(CurrentFolderFixture(testCase.Root));

         plan = buildfile();

         returned = sort(string({plan.Tasks.Name}));
         expected = sort(["check", "test", "contents", "release"]);
         testCase.verifyEqual(returned, expected)

         returned = sort(string(plan("release").Dependencies));
         expected = sort(["check", "test"]);
         testCase.verifyEqual(returned, expected)
      end

      function testBuildtoolReleasePipelineOnCleanFixture(testCase)
         % buildtool("release") on a clean fixture runs the check and
         % test gates, then releaseTask's delegation to releasefile,
         % and lands a versioned .mltbx in the fixture's release/.
         import matlab.unittest.fixtures.CurrentFolderFixture
         import matlab.unittest.fixtures.TemporaryFolderFixture
         tmp = testCase.applyFixture(TemporaryFolderFixture);
         root = testCase.makeCleanFixture(tmp.Folder);
         testCase.applyFixture(CurrentFolderFixture(root));
         testCase.addTeardown(@() closetestproject(root));

         buildtool("release");

         found = dir(fullfile(root, "release", "*.mltbx"));
         testCase.assertNumElements(found, 1)

         returned = string(matlab.addons.toolbox.toolboxVersion( ...
            fullfile(found(1).folder, found(1).name)));
         expected = "0.3.0";
         testCase.verifyEqual(returned, expected)
      end

      function testBuildtoolCheckCatchesSeededDefect(testCase)
         % The matfunclib-juq.27 regression pin: with the buildfile at
         % the project root, a seeded syntax error in the shipped code
         % fails buildtool("check"). The old nested build/ layout
         % scoped the check to build/ and reported green on the same
         % defect.
         import matlab.unittest.fixtures.CurrentFolderFixture
         import matlab.unittest.fixtures.TemporaryFolderFixture
         tmp = testCase.applyFixture(TemporaryFolderFixture);
         root = testCase.makeCleanFixture(tmp.Folder);
         writelines(["function y = broken(x)"; "y = [1, 2;"; "end"], ...
            fullfile(root, "toolbox", "+syn", "broken.m"));
         testCase.applyFixture(CurrentFolderFixture(root));

         failed = false;
         try
            buildtool("check");
         catch
            failed = true;
         end
         returned = failed;
         testCase.verifyTrue(returned)
      end

      function testBuildtoolContentsRegenerates(testCase)
         % buildtool("contents") dispatches through the discovered
         % namespace to makecontents and rewrites the Contents index.
         % The template copy provides the +tbx internals the task
         % needs.
         import matlab.unittest.fixtures.CurrentFolderFixture
         import matlab.unittest.fixtures.TemporaryFolderFixture
         tmp = testCase.applyFixture(TemporaryFolderFixture);
         root = fullfile(string(tmp.Folder), "templatecopy");
         mkdir(root)
         copyfile(fullfile(testCase.Root, "buildfile.m"), root)
         copyfile(fullfile(testCase.Root, "releasefile.m"), root)
         copyfile(fullfile(testCase.Root, "private"), ...
            fullfile(root, "private"))
         copyfile(fullfile(testCase.Root, "toolbox"), ...
            fullfile(root, "toolbox"))
         % makecontents rewrites existing Contents.m files rather than
         % creating missing ones, so seed a stale marker and verify the
         % task replaces it.
         contentsfile = fullfile(root, "toolbox", "+tbx", "Contents.m");
         writelines("% STALE CONTENTS MARKER", contentsfile)
         testCase.applyFixture(CurrentFolderFixture(root));

         buildtool("contents");

         returned = contains(string(fileread(contentsfile)), ...
            "STALE CONTENTS MARKER");
         testCase.verifyFalse(returned)

         % The generator writes no trailing whitespace, so regenerated
         % files do not fight the editor's smart indent.
         lines = readlines(contentsfile);
         returned = nnz(endsWith(lines, " ") ...
            | endsWith(lines, sprintf("\t")));
         expected = 0;
         testCase.verifyEqual(returned, expected)
      end

      function testProjectfileCreatesAtItsOwnRoot(testCase)
         % projectfile self-locates the project root as its own folder,
         % so the created Project must be rooted exactly there (a stale
         % two-level derivation would target the parent folder and
         % still pass every other test).
         import matlab.unittest.fixtures.CurrentFolderFixture
         import matlab.unittest.fixtures.PathFixture
         import matlab.unittest.fixtures.TemporaryFolderFixture

         % projectfile delegates to manager's createMatlabProject, so
         % the repository root goes on the path for this case.
         testCase.applyFixture(PathFixture(fileparts(testCase.Root), ...
            "IncludingSubfolders", true));

         tmp = testCase.applyFixture(TemporaryFolderFixture);
         root = fullfile(string(tmp.Folder), "projcopy");
         mkdir(root)
         copyfile(fullfile(testCase.Root, "projectfile.m"), root)
         copyfile(fullfile(testCase.Root, "mproject.toml"), root)
         copyfile(fullfile(testCase.Root, "toolbox"), ...
            fullfile(root, "toolbox"))
         testCase.applyFixture(CurrentFolderFixture(root));
         testCase.addTeardown(@() closetestproject(root));

         proj = projectfile("create");

         returned = string(proj.RootFolder);
         expected = root;
         testCase.verifyEqual(returned, expected)
      end

      function testReleasefilePackagesHeadless(testCase)
         % The direct entry point (the form releaseTask delegates to)
         % packages an installable .mltbx whose embedded version
         % matches version.txt, against an owned temporary copy of the
         % template so the artifact dies with the fixture.
         import matlab.unittest.fixtures.CurrentFolderFixture
         import matlab.unittest.fixtures.TemporaryFolderFixture
         tmp = testCase.applyFixture(TemporaryFolderFixture);
         root = fullfile(string(tmp.Folder), "templatecopy");
         mkdir(root)
         copyfile(fullfile(testCase.Root, "releasefile.m"), root)
         copyfile(fullfile(testCase.Root, "private"), ...
            fullfile(root, "private"))
         copyfile(fullfile(testCase.Root, "toolbox"), ...
            fullfile(root, "toolbox"))

         % cd resolution picks the copy's releasefile, which
         % self-locates the copy as its root. version.txt rides inside
         % the copied toolbox/ folder.
         testCase.applyFixture(CurrentFolderFixture(root));
         testCase.addTeardown(@() closetestproject(root));

         mltbxfile = releasefile();

         returned = isfile(mltbxfile);
         testCase.verifyTrue(returned)

         returned = startsWith(mltbxfile, root + filesep);
         testCase.verifyTrue(returned)

         returned = string( ...
            matlab.addons.toolbox.toolboxVersion(mltbxfile));
         expected = erase(strtrim(string(fileread(fullfile( ...
            root, 'toolbox', 'version.txt')))), "v");
         testCase.verifyEqual(returned, expected)
      end
   end
end
