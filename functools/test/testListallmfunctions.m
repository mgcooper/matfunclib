classdef testListallmfunctions < matlab.unittest.TestCase
   %TESTLISTALLMFUNCTIONS Unit tests for listallmfunctions (juq.7).
   %
   % Covers the MATLAB_FUNCTION_PATH / MATLAB_FEX_PATH reads. Every test
   % redirects those variables to fixture folders and restores the saved
   % values in teardown. MATLAB_PROJECT_PATH stays unset so the tests do
   % not touch the project registry.

   properties
      % Explicit scalar default: a bare typed struct property initializes
      % 0x0, and dot assignment into an empty struct errors.
      savedEnv struct = struct()
      funcDir string
      fexDir string
   end

   properties (Constant)
      % Env vars the tests mutate; saved and restored around each test.
      envNames = ["MATLAB_FUNCTION_PATH", "MATLAB_FEX_PATH", ...
         "MATLAB_PROJECT_PATH"]
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so the function resolves from the
         % repo root.
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

         % Save the real env values, then point the function and fex paths
         % at fixture folders holding a known set of .m files.
         for name = testCase.envNames
            testCase.savedEnv.(matlab.lang.makeValidName(name)) = getenv(name);
         end
         testCase.addTeardown(@() testCase.restoreEnv())

         tmp = testCase.applyFixture(TemporaryFolderFixture);
         testCase.funcDir = fullfile(string(tmp.Folder), "funclib");
         testCase.fexDir = fullfile(string(tmp.Folder), "fexlib");
         mkdir(fullfile(testCase.funcDir, "sub"))
         mkdir(testCase.fexDir)
         testCase.writeStub(fullfile(testCase.funcDir, "alpha.m"))
         testCase.writeStub(fullfile(testCase.funcDir, "sub", "beta.m"))
         testCase.writeStub(fullfile(testCase.funcDir, "readme.m"))
         testCase.writeStub(fullfile(testCase.fexDir, "gamma.m"))

         setenv('MATLAB_FUNCTION_PATH', testCase.funcDir);
         setenv('MATLAB_FEX_PATH', testCase.fexDir);
         % unsetenv, not setenv(name, ''): isenv treats set-but-empty as
         % set, and the registry branch must stay off in these tests.
         unsetenv('MATLAB_PROJECT_PATH');
      end
   end

   methods (Access = private)
      function restoreEnv(testCase)
         %RESTOREENV Put back the saved env values.
         % Teardown hook: the tests redirect the whole trio, so each saved
         % value must be written back one by one.
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

   methods (Static, Access = private)
      function writeStub(filename)
         %WRITESTUB Write a one-line .m stub for the fixture listing.
         fid = fopen(filename, 'w');
         fprintf(fid, '%% stub\n');
         fclose(fid);
      end
   end

   methods (Test)
      function testListsFunctionAndFexFiles(testCase)
         % The listing covers MATLAB_FUNCTION_PATH recursively plus
         % MATLAB_FEX_PATH, and drops readme files.
         returned = listallmfunctions();
         testCase.verifyTrue(ismember('alpha.m', returned));
         testCase.verifyTrue(ismember('beta.m', returned));
         testCase.verifyTrue(ismember('gamma.m', returned));
         testCase.verifyFalse(ismember('readme.m', returned));
      end

      function testErrorsWithoutFunctionPath(testCase)
         % Without MATLAB_FUNCTION_PATH the function raises its guard
         % error. The error has no identifier, so the test catches it and
         % checks the message.
         unsetenv('MATLAB_FUNCTION_PATH');
         caught = '';
         try
            listallmfunctions();
         catch e
            caught = e.message;
         end
         testCase.verifyEqual(caught, ...
            'set environment variable MATLAB_FUNCTION_PATH to use this function');
      end
   end
end
