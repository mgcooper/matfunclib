classdef testProjectRefs < matlab.unittest.TestCase
   %TESTPROJECTREFS Unit tests for manifest references and sync (juq.30).
   %
   % Every test redirects the project-directory env vars to a fresh
   % temp fixture, so the real directories in $HOME/MATLAB are never
   % touched (the pattern from testRegistrySafety and
   % testDependencyResolution). The fixture project directory holds:
   %
   %   depD, depB, depC, appA  -> the diamond: A -> [B, C] -> D
   %   cycX, cycY              -> a manifest cycle
   %   syncP                   -> the sync fixture project
   %
   % Projects are created leaves-first because addReference requires an
   % existing target Project, which is the ordering these tests prove.

   properties
      regDir string
      savedEnv struct = struct()
   end

   properties (Constant)
      % Env vars every test saves, redirects, and restores.
      envNames = ["MATLAB_DIRECTORY_PATH", ...
         "MATLAB_PROJECT_PATH", "MATLAB_TOOLBOX_PATH"]
      projNames = ["depD", "depB", "depC", "appA", "cycX", "cycY", ...
         "syncP", "default"]
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so the manager functions resolve
         % from the repo root.
         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (TestMethodSetup)
      function buildFixtureWorld(testCase)
         import matlab.unittest.fixtures.TemporaryFolderFixture

         % Save and restore the env vars the directory readers use.
         for name = testCase.envNames
            testCase.savedEnv.(matlab.lang.makeValidName(name)) = ...
               getenv(name);
         end
         testCase.addTeardown(@() testCase.restoreEnv())

         tmp = testCase.applyFixture(TemporaryFolderFixture);
         testCase.regDir = string(tmp.Folder);
         setenv('MATLAB_DIRECTORY_PATH', testCase.regDir);
         setenv('MATLAB_PROJECT_PATH', testCase.regDir);
         setenv('MATLAB_TOOLBOX_PATH', fullfile(testCase.regDir, ...
            "toolboxes"));

         % Project folders and the redirected project directory.
         folders = cell(numel(testCase.projNames), 1);
         for k = 1:numel(testCase.projNames)
            folders{k} = char(fullfile(testCase.regDir, ...
               testCase.projNames(k)));
            mkdir(folders{k})
         end
         projectlist = table( ...
            cellstr(testCase.projNames(:)), ...
            folders, ...
            repmat({{}}, numel(folders), 1), ...
            [false(numel(folders) - 1, 1); true], ...
            folders, ...
            VariableNames={'name', 'folder', 'activefiles', ...
            'activeproject', 'activefolder'});
         writeprjdirectory(projectlist)

         % Close any Project a test leaves open before the fixture
         % folder disappears (shared suite helper).
         testCase.addTeardown(@() closeprojectunder(testCase.regDir))
      end
   end

   methods (Access = private)
      function restoreEnv(testCase)
         % Put every redirected env var back the way the test found it.
         for name = testCase.envNames
            setenv(name, ...
               testCase.savedEnv.(matlab.lang.makeValidName(name)));
         end
      end

      function folder = projFolder(testCase, name)
         % Full path of a fixture project folder.
         folder = fullfile(testCase.regDir, name);
      end

      function writeManifest(testCase, name, deps)
         % Write an mproject.toml declaring project dependencies.
         lines = ["[project]"; "name = """ + name + """"];
         if ~isempty(deps)
            entries = """" + deps + """";
            lines = [lines; "[dependencies]"; ...
               "projects = [" + strjoin(entries, ", ") + "]"];
         end
         writelines(lines, fullfile(testCase.projFolder(name), ...
            "mproject.toml"));
      end

      function proj = makeProject(testCase, name)
         % Generate a fixture Project; the manifest, if any, resolves
         % through the redirected project directory.
         proj = createMatlabProject(testCase.projFolder(name));
      end
   end

   methods (Test)
      function testDiamondResolvesLeavesFirst(testCase)
         % The diamond A -> [B, C] -> D generated leaves-first: every
         % edge lands, and D is referenced once by each of B and C.
         testCase.writeManifest("depB", "depD")
         testCase.writeManifest("depC", "depD")
         testCase.writeManifest("appA", ["depB", "depC"])

         close(testCase.makeProject("depD"))
         projB = testCase.makeProject("depB");
         returned = numel(projB.ProjectReferences);
         expected = 1;
         testCase.verifyEqual(returned, expected)
         close(projB)
         close(testCase.makeProject("depC"))

         projA = testCase.makeProject("appA");
         returned = sort(referenceRoots(projA));
         expected = sort([testCase.projFolder("depB"); ...
            testCase.projFolder("depC")]);
         testCase.verifyEqual(returned, expected)
      end

      function testReferencesRoundTripAfterReopen(testCase)
         % Relative references survive close and reopen, resolving back
         % to the same target roots (the headless round trip).
         testCase.writeManifest("depB", "depD")
         close(testCase.makeProject("depD"))
         close(testCase.makeProject("depB"))

         reopened = openProject(testCase.projFolder("depB"));
         returned = referenceRoots(reopened);
         expected = testCase.projFolder("depD");
         testCase.verifyEqual(returned, expected)
      end

      function testTargetNotAProjectFailsFast(testCase)
         % A declared dependency whose folder is not yet a Project fails
         % with the identified error and adds no reference.
         testCase.writeManifest("appA", "depB")
         testCase.verifyError( ...
            @() createMatlabProject(testCase.projFolder("appA")), ...
            "matfunclib:addprojectrefs:targetNotAProject")

         % The Project was created but holds no partial reference.
         reopened = openProject(testCase.projFolder("appA"));
         returned = reopened.ProjectReferences;
         testCase.verifyEmpty(returned)
      end

      function testOrphanedTargetFailsFast(testCase)
         % A target with partial Project state (resources/project but
         % no root .prj, the hydrobasins breakage) must not pass the
         % target check: openProject cannot open it, so a reference to
         % it would land broken.
         testCase.writeManifest("appA", "depB")
         mkdir(fullfile(testCase.projFolder("depB"), ...
            "resources", "project"))
         testCase.verifyError( ...
            @() addprojectrefs(testCase.projFolder("appA")), ...
            "matfunclib:addprojectrefs:targetNotAProject")
      end

      function testMissingTargetFolderFailsFast(testCase)
         % A project directory entry whose folder was deleted must get
         % the target diagnostic (state "missing"), not a validator
         % error from inside the state check.
         testCase.writeManifest("appA", "depB")
         rmdir(testCase.projFolder("depB"), 's')
         testCase.verifyError( ...
            @() addprojectrefs(testCase.projFolder("appA")), ...
            "matfunclib:addprojectrefs:targetNotAProject")
      end

      function testCycleFailsFastWithChain(testCase)
         % A manifest cycle errors before any side effect, naming the
         % chain, so no reference is added anywhere.
         testCase.writeManifest("cycX", "cycY")
         testCase.writeManifest("cycY", "cycX")
         % references=false: generating cycY's own refs would hit the
         % same cycle this test wants to observe from cycX.
         close(createMatlabProject(testCase.projFolder("cycY"), ...
            references=false))

         testCase.verifyError( ...
            @() addprojectrefs(testCase.projFolder("cycX")), ...
            "matfunclib:addprojectrefs:dependencyCycle")

         reopened = openProject(testCase.projFolder("cycY"));
         returned = reopened.ProjectReferences;
         testCase.verifyEmpty(returned)
      end

      function testUnknownProjectFailsFast(testCase)
         % A manifest naming a project absent from the project
         % directory fails before anything opens.
         testCase.writeManifest("appA", "ghostproj")
         testCase.verifyError( ...
            @() addprojectrefs(testCase.projFolder("appA")), ...
            "matfunclib:addprojectrefs:unknownProject")
      end

      function testManifestRemovalStripsReference(testCase)
         % Reconciliation in the removal direction: dropping a
         % dependency from the manifest removes its reference on the
         % next pass, so the .prj graph tracks the declarations.
         testCase.writeManifest("depB", "depD")
         close(testCase.makeProject("depD"))
         close(testCase.makeProject("depB"))

         % The dependency is withdrawn: same project, empty manifest.
         testCase.writeManifest("depB", string.empty())
         [added, removed] = addprojectrefs(testCase.projFolder("depB"));

         testCase.verifyEmpty(added)
         returned = removed;
         expected = testCase.projFolder("depD");
         testCase.verifyEqual(returned, expected)

         reopened = openProject(testCase.projFolder("depB"));
         returned = reopened.ProjectReferences;
         testCase.verifyEmpty(returned)
      end

      function testRerunAddsNothing(testCase)
         % Idempotence: a second refs pass returns empty and the count
         % is unchanged.
         testCase.writeManifest("depB", "depD")
         close(testCase.makeProject("depD"))
         projB = testCase.makeProject("depB");

         returned = addprojectrefs(testCase.projFolder("depB"));
         testCase.verifyEmpty(returned)

         returned = numel(projB.ProjectReferences);
         expected = 1;
         testCase.verifyEqual(returned, expected)
      end

      function testInternalSubprojectReference(testCase)
         % The internal reference kind: a subfolder Project referenced
         % relatively without any manifest entry (the hub layout).
         parent = testCase.projFolder("appA");
         subFolder = fullfile(parent, "sublib");
         mkdir(subFolder)
         close(createMatlabProject(subFolder))
         close(createMatlabProject(parent))

         returned = addprojectrefs(parent, subprojects="sublib");
         expected = string(subFolder);
         testCase.verifyEqual(returned, expected)

         % A later manifest-only pass (no subprojects option, and this
         % parent has no manifest) must leave the internal reference
         % alone, so a hub's sub-library references survive routine
         % regeneration.
         [added, removed] = addprojectrefs(parent);
         testCase.verifyEmpty(added)
         testCase.verifyEmpty(removed)

         reopened = openProject(parent);
         returned = numel(reopened.ProjectReferences);
         expected = 1;
         testCase.verifyEqual(returned, expected)

         % An explicit empty list is different from omitting the
         % option: it reconciles the internal references down to none.
         [added, removed] = addprojectrefs(parent, ...
            subprojects=strings(0, 1));
         testCase.verifyEmpty(added)
         returned = removed;
         expected = string(subFolder);
         testCase.verifyEqual(returned, expected)

         reopened = openProject(parent);
         returned = reopened.ProjectReferences;
         testCase.verifyEmpty(returned)
      end

      function testSyncAddsMissingInRootFile(testCase)
         % An in-root required file missing from the Project is imported
         % directly (no copy).
         import matlab.unittest.fixtures.PathFixture
         syncRoot = testCase.projFolder("syncP");
         mkdir(fullfile(syncRoot, "util"))
         writelines(["function y = syncmain(x)"; ...
            "y = synchelper(x);"; "end"], ...
            fullfile(syncRoot, "syncmain.m"));
         writelines(["function y = synchelper(x)"; "y = x;"; "end"], ...
            fullfile(syncRoot, "util", "synchelper.m"));
         % Only the root goes on the session path: util/ must be
         % resolvable through sync's own analysis-time path exposure,
         % or this test would mask an unresolvable dependency.
         testCase.applyFixture(PathFixture(syncRoot));

         close(createMatlabProject(syncRoot, addProjectFiles=true))
         report = syncprojectfiles(syncRoot);

         returned = any(endsWith(report.added, "synchelper.m"));
         testCase.verifyTrue(returned)
         testCase.verifyEmpty(report.external)

         reopened = openProject(syncRoot);
         returned = any(endsWith(listprojectfiles(reopened), ...
            "synchelper.m"));
         testCase.verifyTrue(returned)

         % The imported file's folder must be on the Project path or a
         % clean-session reopen cannot resolve the dependency.
         returned = any(endsWith(listprojectpath(reopened), ...
            filesep + "util"));
         testCase.verifyTrue(returned)
      end

      function testSyncKeepsPrivateRequirementExternal(testCase)
         % A requirement below a private folder is callable only from
         % its own parent, so no root copy can satisfy it: it stays
         % external and nothing is imported.
         import matlab.unittest.fixtures.PathFixture
         syncRoot = testCase.projFolder("syncP");
         extLib = fullfile(testCase.regDir, "extlib");
         mkdir(fullfile(extLib, "private"))
         mkdir(fullfile(syncRoot, "vendor", "private"))
         writelines(["function y = syncextmain(x)"; ...
            "y = syncprivhelper(x);"; "end"], ...
            fullfile(extLib, "syncextmain.m"));
         writelines(["function y = syncprivhelper(x)"; "y = x;"; ...
            "end"], fullfile(extLib, "private", "syncprivhelper.m"));
         writelines(["function y = syncprivhelper(x)"; "y = x + 1;"; ...
            "end"], fullfile(syncRoot, "vendor", "private", ...
            "syncprivhelper.m"));
         writelines(["function y = syncmain(x)"; ...
            "y = syncextmain(x);"; "end"], ...
            fullfile(syncRoot, "syncmain.m"));
         testCase.applyFixture(PathFixture(syncRoot))
         testCase.applyFixture(PathFixture(extLib))

         close(createMatlabProject(syncRoot, addProjectFiles=true))
         report = syncprojectfiles(syncRoot);

         returned = any(endsWith(report.external, ...
            fullfile("private", "syncprivhelper.m")));
         testCase.verifyTrue(returned)
      end

      function testSyncReportsExternalRequirement(testCase)
         % A requirement outside the root with no root copy is reported,
         % never imported (vendoring is installRequiredFiles' job).
         import matlab.unittest.fixtures.PathFixture
         syncRoot = testCase.projFolder("syncP");
         extLib = fullfile(testCase.regDir, "extlib");
         mkdir(extLib)
         writelines(["function y = syncextfun(x)"; "y = x;"; "end"], ...
            fullfile(extLib, "syncextfun.m"));
         writelines(["function y = syncmain(x)"; ...
            "y = syncextfun(x);"; "end"], ...
            fullfile(syncRoot, "syncmain.m"));
         testCase.applyFixture(PathFixture(syncRoot))
         testCase.applyFixture(PathFixture(extLib))

         close(createMatlabProject(syncRoot, addProjectFiles=true))
         report = syncprojectfiles(syncRoot);

         returned = any(endsWith(report.external, "syncextfun.m"));
         testCase.verifyTrue(returned)

         reopened = openProject(syncRoot);
         returned = any(endsWith(listprojectfiles(reopened), ...
            "syncextfun.m"));
         testCase.verifyFalse(returned)
      end

      function testSyncResolvesInRootCopyByPathOrder(testCase)
         % A requirement with both an external copy on the session path
         % and an in-root copy resolves to the in-root copy during the
         % walk (in-root folders sit at the front of the analysis
         % path), so the in-root copy imports and nothing is external.
         import matlab.unittest.fixtures.PathFixture
         syncRoot = testCase.projFolder("syncP");
         extLib = fullfile(testCase.regDir, "extlib");
         mkdir(extLib)
         mkdir(fullfile(syncRoot, "vendor"))
         writelines(["function y = syncshadow(x)"; "y = x;"; "end"], ...
            fullfile(extLib, "syncshadow.m"));
         writelines(["function y = syncshadow(x)"; "y = x + 1;"; ...
            "end"], fullfile(syncRoot, "vendor", "syncshadow.m"));
         writelines(["function y = syncmain(x)"; ...
            "y = syncshadow(x);"; "end"], ...
            fullfile(syncRoot, "syncmain.m"));
         % Only the external copy is on the session path; the analysis
         % walk must still prefer the in-root copy.
         testCase.applyFixture(PathFixture(syncRoot))
         testCase.applyFixture(PathFixture(extLib))

         close(createMatlabProject(syncRoot, addProjectFiles=true))
         report = syncprojectfiles(syncRoot);

         returned = any(contains(report.added, ...
            fullfile("vendor", "syncshadow.m")));
         testCase.verifyTrue(returned)
         testCase.verifyEmpty(report.external)

         reopened = openProject(syncRoot);
         returned = any(contains(listprojectfiles(reopened), ...
            fullfile("vendor", "syncshadow.m")));
         testCase.verifyTrue(returned)
      end

      function testSyncKeepsPackageRequirementExternal(testCase)
         % A same-named root file under a DIFFERENT package must not
         % shadow the requirement: +b/helper.m cannot satisfy
         % +a/helper.m, so the requirement stays external and nothing
         % is imported.
         import matlab.unittest.fixtures.PathFixture
         syncRoot = testCase.projFolder("syncP");
         extLib = fullfile(testCase.regDir, "extlib");
         mkdir(fullfile(extLib, "+syncpa"))
         mkdir(fullfile(syncRoot, "vendor", "+syncpb"))
         writelines(["function y = synchelper(x)"; "y = x;"; "end"], ...
            fullfile(extLib, "+syncpa", "synchelper.m"));
         writelines(["function y = synchelper(x)"; "y = x + 1;"; ...
            "end"], fullfile(syncRoot, "vendor", "+syncpb", ...
            "synchelper.m"));
         writelines(["function y = syncmain(x)"; ...
            "y = syncpa.synchelper(x);"; "end"], ...
            fullfile(syncRoot, "syncmain.m"));
         testCase.applyFixture(PathFixture(syncRoot))
         testCase.applyFixture(PathFixture(extLib))

         close(createMatlabProject(syncRoot, addProjectFiles=true))
         report = syncprojectfiles(syncRoot);

         returned = any(endsWith(report.external, ...
            fullfile("+syncpa", "synchelper.m")));
         testCase.verifyTrue(returned)

         reopened = openProject(syncRoot);
         returned = any(contains(listprojectfiles(reopened), ...
            "+syncpb"));
         testCase.verifyFalse(returned)
      end

   end
end

function roots = referenceRoots(proj)
   %REFERENCEROOTS Resolved root folders of a Project's references.

   arguments
      proj (1,1) matlab.project.Project
   end

   nrefs = numel(proj.ProjectReferences);
   roots = strings(nrefs, 1);
   for k = 1:nrefs
      roots(k) = string(proj.ProjectReferences(k).Project.RootFolder);
   end
end

