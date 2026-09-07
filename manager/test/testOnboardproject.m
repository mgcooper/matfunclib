classdef testOnboardproject < matlab.unittest.TestCase
   %TESTONBOARDPROJECT Unit tests for onboardproject (juq.33).
   %
   % Every test redirects MATLAB_DIRECTORY_PATH and MATLAB_PROJECT_PATH
   % to a fresh temp folder holding a fixture registry and a fixture git
   % project, so the real registries and projects are never touched. The
   % search path and env values are restored in teardown.

   properties
      regDir string
      projDir string
      % Explicit scalar default: a bare typed struct property initializes
      % 0x0, and dot assignment into an empty struct errors.
      savedEnv struct = struct()
      savedPath char = ''
   end

   properties (Constant)
      % Env vars every test saves, redirects, and restores.
      envNames = ["MATLAB_DIRECTORY_PATH", "MATLAB_PROJECT_PATH"]
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so onboardproject and the manager
         % helpers resolve from the repo root.
         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (TestMethodSetup)
      function buildFixture(testCase)
         import matlab.unittest.fixtures.TemporaryFolderFixture

         % Save the env values and the search path for teardown; the
         % generator opens and closes Projects, which edits the path.
         for name = testCase.envNames
            testCase.savedEnv.(matlab.lang.makeValidName(name)) = getenv(name);
         end
         testCase.savedPath = path();
         testCase.addTeardown(@() testCase.restoreState())

         tmp = testCase.applyFixture(TemporaryFolderFixture);
         testCase.regDir = string(tmp.Folder);
         setenv('MATLAB_DIRECTORY_PATH', testCase.regDir);
         setenv('MATLAB_PROJECT_PATH', testCase.regDir);

         % Fixture project: a git repo with one tracked code folder and
         % one untracked scratch folder, so the follow-git membership
         % rule is observable through the onboarding result.
         testCase.projDir = fullfile(testCase.regDir, "alpha");
         mkdir(fullfile(testCase.projDir, "toolbox"))
         mkdir(fullfile(testCase.projDir, "scratch"))
         mkdir(fullfile(testCase.projDir, "testbed"))
         writelines(["function y = topfun(x)"; "y = x;"; "end"], ...
            fullfile(testCase.projDir, "topfun.m"));
         writelines(["function y = shipped(x)"; "y = x;"; "end"], ...
            fullfile(testCase.projDir, "toolbox", "shipped.m"));
         writelines(["function y = junk(x)"; "y = x;"; "end"], ...
            fullfile(testCase.projDir, "scratch", "junk.m"));
         writelines(["function y = bench(x)"; "y = x;"; "end"], ...
            fullfile(testCase.projDir, "testbed", "bench.m"));
         root = char(testCase.projDir);
         [initStatus, ~] = system(sprintf( ...
            'git -C "%s" init -q && git -C "%s" add toolbox testbed topfun.m', ...
            root, root));
         testCase.assertEqual(initStatus, 0)

         % Fixture registry with the columns writeprjdirectory requires.
         % The ghost row resolves to a folder that does not exist, so the
         % folderNotFound branch is testable.
         folders = [testCase.projDir; fullfile(testCase.regDir, "default"); ...
            fullfile(testCase.regDir, "ghost")];
         mkdir(folders(2))
         projectlist = table( ...
            {'alpha'; 'default'; 'ghost'}, ...
            cellstr([testCase.regDir; testCase.regDir; testCase.regDir]), ...
            {{}; {}; {}}, ...
            [true; false; false], ...
            cellstr(folders), ...
            VariableNames={'name', 'folder', 'activefiles', ...
            'activeproject', 'activefolder'});
         writeprjdirectory(projectlist)

         % Close any Project the test leaves open before the fixture
         % folder is deleted out from under it (shared suite helper).
         testCase.addTeardown(@() closeprojectunder(testCase.regDir));
      end
   end

   methods (Access = private)
      function restoreState(testCase)
         %RESTORESTATE Put back the saved env values and search path.
         % Teardown hook: onboarding opens and closes Projects and the
         % tests redirect the registry, so both must return to the
         % pre-test state.
         path(testCase.savedPath);
         for name = testCase.envNames
            saved = testCase.savedEnv.(matlab.lang.makeValidName(name));
            if isempty(saved)
               % setenv(name, '') leaves the variable set-but-empty, which
               % isenv treats as set; unsetenv restores true absence.
               unsetenv(name);
            else
               setenv(name, saved);
            end
         end
      end
   end

   methods (Test)
      function testOnboardCreatesProjectManifestAndPolicy(testCase)
         % One call produces the whole onboarding result: a Project, a
         % name-only manifest stub, the git-policy patterns, and the
         % import rule. The untracked scratch folder stays out
         % (follow-git membership). The TRACKED testbed folder stays
         % out (the ignoredSubFolders default). Top-level topfun.m is a
         % member (addProjectFiles). The tracked shipped.m below
         % toolbox is not a file member (addChildFiles stays false).
         % The entry path comes back unchanged.
         expected = path();
         returned = onboardproject("alpha");
         testCase.verifyEqual(path(), expected);
         testCase.verifyEqual(returned, testCase.projDir);
         returned = char(projectstate(testCase.projDir));
         expected = 'project';
         testCase.verifyEqual(returned, expected);

         manifest = readlines(fullfile(testCase.projDir, "mproject.toml"));
         returned = any(manifest == "name = ""alpha""");
         testCase.verifyTrue(returned);

         ignorelines = readlines(fullfile(testCase.projDir, ".gitignore"));
         returned = any(ignorelines == "**/resources/*") ...
            && any(ignorelines == "!**/resources/project/");
         testCase.verifyTrue(returned);

         reopened = openProject(testCase.projDir);
         files = listprojectfiles(reopened);
         returned = any(endsWith(files, filesep + "toolbox"));
         testCase.verifyTrue(returned);
         returned = any(endsWith(files, filesep + "scratch"));
         testCase.verifyFalse(returned);
         returned = any(endsWith(files, filesep + "testbed"));
         testCase.verifyFalse(returned);
         returned = any(endsWith(files, filesep + "topfun.m"));
         testCase.verifyTrue(returned);
         returned = any(endsWith(files, filesep + "shipped.m"));
         testCase.verifyFalse(returned);
         close(reopened)
      end

      function testOnboardKeepsExistingManifest(testCase)
         % An existing manifest is never touched: dependencies declared
         % by hand survive onboarding byte for byte.
         manifestFile = fullfile(testCase.projDir, "mproject.toml");
         expected = ["[project]"; "name = ""alpha"""; ""; ...
            "# hand-written marker"];
         writelines(expected, manifestFile);
         onboardproject("alpha");
         returned = readlines(manifestFile);
         testCase.verifyEqual(returned(1:numel(expected)), expected);
      end

      function testOnboardIdempotent(testCase)
         % A re-run converges: the member set is unchanged and the
         % policy block is not appended twice.
         onboardproject("alpha");
         first = openProject(testCase.projDir);
         expected = sort(listprojectfiles(first));
         close(first)

         onboardproject("alpha");
         second = openProject(testCase.projDir);
         returned = sort(listprojectfiles(second));
         close(second)
         testCase.verifyEqual(returned, expected);

         ignorelines = readlines(fullfile(testCase.projDir, ".gitignore"));
         testCase.verifyEqual(nnz(ignorelines == "**/resources/*"), 1);
      end

      function testUnknownNameErrors(testCase)
         % A name outside the project directory fails fast with the
         % identified error instead of erroring inside column indexing.
         testCase.verifyError(@() onboardproject("nosuchproject"), ...
            "matfunclib:manager:onboardproject:unknownProject")
      end

      function testRegisteredMissingFolderErrors(testCase)
         % A registered name whose activefolder does not exist fails
         % fast with the identified error before any generation.
         testCase.verifyError(@() onboardproject("ghost"), ...
            "matfunclib:manager:onboardproject:folderNotFound")
      end

      function testFailedGenerationRestoresSession(testCase)
         % A manifest declaring an unknown dependency makes the
         % reference pass fail AFTER the Project is open and the path
         % changed; the onCleanup restore must close the Project and
         % put the entry path back so a retry starts from a clean
         % session.
         writelines(["[project]"; "name = ""alpha"""; ""; ...
            "[dependencies]"; "projects = [""nosuchdep""]"], ...
            fullfile(testCase.projDir, "mproject.toml"));
         expected = path();
         testCase.verifyError(@() onboardproject("alpha"), ...
            "matfunclib:addprojectrefs:unknownProject")
         returned = path();
         testCase.verifyEqual(returned, expected);
         returned = isempty(matlab.project.rootProject());
         testCase.verifyTrue(returned);
      end
   end
end
