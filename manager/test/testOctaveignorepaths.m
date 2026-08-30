classdef testOctaveignorepaths < matlab.unittest.TestCase
   %TESTOCTAVEIGNOREPATHS Unit tests for octaveignorepaths (juq.7).
   %
   % The Octave branches in startup.m and funclibpath consume this list
   % but never run under the MATLAB test harness, so this suite pins the
   % list construction directly, including the MATLAB_FEX_PATH read.

   properties
      % Explicit scalar default: a bare typed struct property initializes
      % 0x0, and dot assignment into an empty struct errors.
      savedEnv struct = struct()
   end

   properties (Constant)
      % Env vars the tests mutate; saved and restored around each test.
      envNames = ["MATLAB_FUNCTION_PATH", "MATLAB_FEX_PATH"]
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so the helper resolves from the repo
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
      function saveEnvironment(testCase)
         % Save the env values so each test returns to the caller's
         % environment.
         for name = testCase.envNames
            testCase.savedEnv.(matlab.lang.makeValidName(name)) = getenv(name);
         end
         testCase.addTeardown(@() testCase.restoreEnv())
      end
   end

   methods (Access = private)
      function restoreEnv(testCase)
         %RESTOREENV Put back the saved env values.
         % Teardown hook: the tests redirect both variables, so each saved
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

   methods (Test)
      function testListDerivesFromBothEnvVars(testCase)
         % The list holds four MATLAB_FUNCTION_PATH entries and the one
         % MATLAB_FEX_PATH entry, in this fixed order.
         setenv('MATLAB_FUNCTION_PATH', fullfile(tempdir, 'funclib'));
         setenv('MATLAB_FEX_PATH', fullfile(tempdir, 'fexlib'));
         returned = octaveignorepaths();
         expected = {
            fullfile(tempdir, 'funclib', 'libtext', 'printf'); ...
            fullfile(tempdir, 'funclib', 'liblogic', 'iscomplex'); ...
            fullfile(tempdir, 'funclib', 'liblogic', 'ifelse'); ...
            fullfile(tempdir, 'funclib', 'libstruct', 'numfields'); ...
            fullfile(tempdir, 'fexlib', 'libarrays', 'foreach'); ...
            };
         testCase.verifyEqual(returned, expected);
      end
   end
end
