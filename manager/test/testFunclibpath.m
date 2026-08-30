classdef testFunclibpath < matlab.unittest.TestCase
   %TESTFUNCLIBPATH Unit tests for funclibpath (juq.7).
   %
   % Covers the MATLAB_FUNCTION_PATH and MATLAB_HOME_PATH reads. Every test
   % saves the touched env values and the search path, and restores both in
   % teardown, so the caller's session never keeps fixture paths.

   properties
      % Explicit scalar default: a bare typed struct property initializes
      % 0x0, and dot assignment into an empty struct errors.
      savedEnv struct = struct()
      savedPath char = ''
      homeDir string
      subDir string
   end

   properties (Constant)
      % Env vars the tests mutate; saved and restored around each test.
      envNames = ["MATLAB_FUNCTION_PATH", "MATLAB_HOME_PATH"]
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so funclibpath resolves from the repo
         % root.
         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (TestMethodSetup)
      function redirectEnvironment(testCase)
         import matlab.unittest.fixtures.TemporaryFolderFixture

         % Save the env values and the search path, then point the home
         % path at a fixture tree with one known subfolder.
         for name = testCase.envNames
            testCase.savedEnv.(matlab.lang.makeValidName(name)) = getenv(name);
         end
         testCase.savedPath = path();
         testCase.addTeardown(@() testCase.restoreState())

         tmp = testCase.applyFixture(TemporaryFolderFixture);
         testCase.homeDir = fullfile(string(tmp.Folder), "home");
         testCase.subDir = fullfile(testCase.homeDir, "sub1");
         mkdir(testCase.subDir)
         setenv('MATLAB_HOME_PATH', testCase.homeDir);
      end
   end

   methods (Access = private)
      function restoreState(testCase)
         %RESTORESTATE Put back the saved env values and search path.
         % Teardown hook: the addpath/rmpath options mutate the global
         % search path, so the saved path string is restored wholesale.
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
      function testWhichReturnsFunctionPath(testCase)
         % The no-option call returns the MATLAB_FUNCTION_PATH value.
         setenv('MATLAB_FUNCTION_PATH', testCase.homeDir);
         returned = funclibpath();
         expected = char(testCase.homeDir);
         testCase.verifyEqual(returned, expected);
      end

      function testAddpathAddsHomeTree(testCase)
         % The addpath option puts the MATLAB_HOME_PATH tree on the path.
         funclibpath('addpath');
         onpath = contains(path(), char(testCase.subDir));
         testCase.verifyTrue(onpath);
      end

      function testRmpathRemovesHomeTree(testCase)
         % The rmpath option removes the MATLAB_HOME_PATH tree again.
         funclibpath('addpath');
         funclibpath('rmpath');
         onpath = contains(path(), char(testCase.subDir));
         testCase.verifyFalse(onpath);
      end
   end
end
