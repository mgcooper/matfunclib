classdef testCreateHubProject < matlab.unittest.TestCase
   %TESTCREATEHUBPROJECT Unit tests for hub Project generation (juq.32).
   %
   % Each test builds a two-sub-project hub inside a
   % TemporaryFolderFixture. Every Project closes before the fixture
   % folder is destroyed, so no Project or path state leaks between
   % tests and the real repository is never touched. The fixture tree
   % carries no mproject.toml, so the reference pass declares no
   % external dependency and never reads the project directory.

   properties
      % Root of the per-test fixture tree holding the hub folder.
      base string

      % The hub folder the tests generate into.
      hubDir string

      % The two sub-project folder names paired with their Project
      % names, the argument shape createhubproject takes.
      subprojects string
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so createhubproject and its
         % manager helpers resolve from the repo root.
         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (TestMethodSetup)
      function buildFixtureTree(testCase)
         import matlab.unittest.fixtures.TemporaryFolderFixture

         tmp = testCase.applyFixture(TemporaryFolderFixture);
         testCase.base = string(tmp.Folder);
         testCase.hubDir = fullfile(testCase.base, "fixturehub");
         testCase.subprojects = ["alpha", "Alpha"; "beta", "Beta"];

         % Two sub-libraries, each with a top-level function and one
         % code subfolder, plus a scratch folder the ignore option
         % excludes.
         mkdir(testCase.hubDir)
         for name = testCase.subprojects(:, 1).'
            folder = fullfile(testCase.hubDir, name);
            mkdir(fullfile(folder, "util"))
            mkdir(fullfile(folder, "testbed"))
            writelines(["function y = " + name + "fun(x)"; "y = x;"; ...
               "end"], fullfile(folder, name + "fun.m"));
            writelines(["function y = helper(x)"; "y = x;"; "end"], ...
               fullfile(folder, "util", "helper.m"));
            writelines(["function y = scratch(x)"; "y = x;"; "end"], ...
               fullfile(folder, "testbed", "scratch.m"));
         end

         % Close any Project a test leaves open before the fixture
         % folder is deleted out from under it (shared suite helper).
         testCase.addTeardown(@() closeprojectunder(testCase.base));
      end
   end

   methods (Test)
      function testGeneratesHubAndSubprojects(testCase)
         % The hub layout in one call: both sub-projects become
         % Projects and the hub references both of them.
         proj = createhubproject(testCase.hubDir, testCase.subprojects);

         returned = sort(testCase.referenceNames(proj));
         expected = ["alpha"; "beta"];
         testCase.verifyEqual(returned, expected)

         for name = testCase.subprojects(:, 1).'
            returned = projectstate(fullfile(testCase.hubDir, name));
            expected = "project";
            testCase.verifyEqual(returned, expected)
         end
      end

      function testProjectNamesSetPrjFilenames(testCase)
         % MATLAB writes the .prj filename from the Project name. The
         % CamelCase names in the roster therefore keep the generated
         % files named the way the repository expects.
         proj = createhubproject(testCase.hubDir, testCase.subprojects, ...
            projectName="FixtureHub");
         close(proj)

         returned = isfile(fullfile(testCase.hubDir, "FixtureHub.prj"));
         testCase.verifyTrue(returned)

         returned = isfile(fullfile(testCase.hubDir, "alpha", "Alpha.prj"));
         testCase.verifyTrue(returned)
      end

      function testIgnoredSubFoldersExcludedFromSubprojects(testCase)
         % The ignore list reaches every sub-project import, so a
         % scratch tree never becomes a member or a path entry.
         proj = createhubproject(testCase.hubDir, testCase.subprojects, ...
            ignoredSubFolders="testbed");
         close(proj)

         alpha = openProject(fullfile(testCase.hubDir, "alpha"));
         files = listprojectfiles(alpha);

         returned = any(endsWith(files, filesep + "util"));
         testCase.verifyTrue(returned)

         returned = any(contains(files, filesep + "testbed"));
         testCase.verifyFalse(returned)
      end

      function testGenerationCompletesWithOverlappingPaths(testCase)
         % The manager-overlap scenario: the caller's path already
         % holds folders the sub-projects manage. That happens when the
         % generator is reached through the code it is about to import.
         % Closing a sub-project removes those folders. Without the
         % loop's entry-path restore, the generator falls off the path
         % and the next iteration errors with Unrecognized function.
         % This test runs that scenario end to end. The assertion is
         % that generation completes and keeps its declared reference
         % set.
         overlap = fullfile(testCase.hubDir, "alpha", "util");
         addpath(overlap)
         testCase.addTeardown(@() rmpath(overlap));

         proj = createhubproject(testCase.hubDir, testCase.subprojects);

         returned = sort(testCase.referenceNames(proj));
         expected = ["alpha"; "beta"];
         testCase.verifyEqual(returned, expected)

         % The overlapping folder is on the path while the hub is open,
         % through the reference it belongs to.
         returned = contains(string(path()), overlap);
         testCase.verifyTrue(returned)
      end

      function testRegeneratesWhileTheHubIsOpen(testCase)
         % The "open the hub, then regenerate" call. MATLAB holds one
         % root Project, so generating the first sub-project closes the
         % hub, and that close removes the folders the hub put on the
         % path. The call closes the open Project first, so generation
         % completes and returns the hub open again.
         first = createhubproject(testCase.hubDir, testCase.subprojects);
         close(first)
         openProject(testCase.hubDir);

         proj = createhubproject(testCase.hubDir, testCase.subprojects);

         returned = sort(testCase.referenceNames(proj));
         expected = ["alpha"; "beta"];
         testCase.verifyEqual(returned, expected)
      end

      function testDroppedSubprojectLeavesThePathWithTheHubOpen(testCase)
         % A roster entry dropped while the hub is open: the call
         % closes the hub, generates the shorter roster, and removes
         % the stale reference. The dropped sub-project's folders must
         % not survive on the path, or a session would keep code the
         % hub stopped referencing.
         first = createhubproject(testCase.hubDir, testCase.subprojects);
         close(first)
         openProject(testCase.hubDir);

         proj = createhubproject(testCase.hubDir, ...
            testCase.subprojects(1, :));

         returned = testCase.referenceNames(proj);
         expected = "alpha";
         testCase.verifyEqual(returned, expected)

         returned = contains(string(path()), ...
            fullfile(testCase.hubDir, "beta"));
         testCase.verifyFalse(returned)
      end

      function testDoubleRunIsIdempotent(testCase)
         % The double-run proof: a second call opens what exists and
         % changes nothing, so the reference set is unchanged.
         first = createhubproject(testCase.hubDir, testCase.subprojects);
         expected = sort(testCase.referenceNames(first));
         close(first)

         second = createhubproject(testCase.hubDir, testCase.subprojects);
         returned = sort(testCase.referenceNames(second));
         testCase.verifyEqual(returned, expected)
      end

      function testDroppedSubprojectIsUnreferenced(testCase)
         % The roster is the declaration, so removing an entry removes
         % its reference on the next run instead of leaving a stale
         % edge behind.
         first = createhubproject(testCase.hubDir, testCase.subprojects);
         close(first)

         second = createhubproject(testCase.hubDir, ...
            testCase.subprojects(1, :));
         returned = testCase.referenceNames(second);
         expected = "alpha";
         testCase.verifyEqual(returned, expected)
      end
   end

   methods (Access = private)
      function names = referenceNames(~, proj)
         %REFERENCENAMES Folder names of a Project's references.

         nrefs = numel(proj.ProjectReferences);
         names = strings(nrefs, 1);
         for k = 1:nrefs
            [~, names(k)] = fileparts( ...
               string(proj.ProjectReferences(k).Project.RootFolder));
         end
      end
   end
end
