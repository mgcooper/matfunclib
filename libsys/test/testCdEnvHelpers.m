classdef testCdEnvHelpers < matlab.unittest.TestCase
   %TESTCDENVHELPERS Unit tests for the env-var driven cd helpers (juq.7).
   %
   % Covers the MATLAB_FEX_PATH read in cdfex and the fallback order in
   % cddata. Every test saves the touched env values and the working
   % directory, and restores both in teardown.

   properties
      % Explicit scalar default: a bare typed struct property initializes
      % 0x0, and dot assignment into an empty struct errors.
      savedEnv struct = struct()
      savedDir char = ''
   end

   properties (Constant)
      % Env vars the tests mutate; saved and restored around each test.
      % MATLABDATAPATH is retired (juq.7); two tests set it to prove
      % cddata ignores it.
      envNames = ["MATLAB_FEX_PATH", "USERDATAPATH", ...
         "MATLAB_ACTIVE_PROJECT_DATA_PATH", "MATLABDATAPATH", "OLD_CWD"]
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so the helpers resolve from the repo
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
      function saveState(testCase)
         % Save the env values and the working directory for teardown.
         for name = testCase.envNames
            testCase.savedEnv.(matlab.lang.makeValidName(name)) = getenv(name);
         end
         testCase.savedDir = pwd();
         testCase.addTeardown(@() testCase.restoreState())
      end
   end

   methods (Access = private)
      function restoreState(testCase)
         %RESTORESTATE Put back the saved env values and working directory.
         % Teardown hook: the cd helpers change the working directory and
         % OLD_CWD, so both must return to the pre-test state.
         cd(testCase.savedDir);
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

      function [folder, resolved] = tempTarget(testCase)
         %TEMPTARGET Create a temp folder and resolve its canonical path.
         % cd-then-pwd resolves the macOS /var vs /private/var symlink, so
         % the tests compare pwd output against a path resolved the same
         % way.
         import matlab.unittest.fixtures.TemporaryFolderFixture
         tmp = testCase.applyFixture(TemporaryFolderFixture);
         folder = tmp.Folder;
         startdir = pwd();
         cd(folder);
         resolved = pwd();
         cd(startdir);
      end
   end

   methods (Test)
      function testCdfexUsesFexPath(testCase)
         % cdfex changes to the MATLAB_FEX_PATH folder.
         [folder, expected] = testCase.tempTarget();
         setenv('MATLAB_FEX_PATH', folder);
         cdfex();
         returned = pwd();
         testCase.verifyEqual(returned, expected);
      end

      function testCdfexRecordsOldCwd(testCase)
         % cdfex records the starting folder in OLD_CWD.
         [folder, ~] = testCase.tempTarget();
         setenv('MATLAB_FEX_PATH', folder);
         expected = pwd();
         cdfex();
         returned = getenv('OLD_CWD');
         testCase.verifyEqual(returned, expected);
      end

      function testCdfexStaysPutWhenUnset(testCase)
         % With no MATLAB_FEX_PATH, cdfex swallows the cd error and stays.
         unsetenv('MATLAB_FEX_PATH');
         expected = pwd();
         cdfex();
         returned = pwd();
         testCase.verifyEqual(returned, expected);
      end

      function testCddataPrefersUserDataPath(testCase)
         % cddata changes to USERDATAPATH when it is set.
         [folder, expected] = testCase.tempTarget();
         setenv('USERDATAPATH', folder);
         cddata();
         returned = pwd();
         testCase.verifyEqual(returned, expected);
      end

      function testCddataFallsBackToActiveProjectData(testCase)
         % With USERDATAPATH unset, cddata falls back to
         % MATLAB_ACTIVE_PROJECT_DATA_PATH. The retired MATLABDATAPATH
         % (deleted fallback, juq.7) points at a different folder to prove
         % cddata ignores it.
         [folder, expected] = testCase.tempTarget();
         [legacyFolder, ~] = testCase.tempTarget();
         unsetenv('USERDATAPATH');
         setenv('MATLABDATAPATH', legacyFolder);
         setenv('MATLAB_ACTIVE_PROJECT_DATA_PATH', folder);
         cddata();
         returned = pwd();
         testCase.verifyEqual(returned, expected);
      end

      function testCddataWarnsWhenNothingSet(testCase)
         % With neither live data variable set, cddata warns and stays
         % put, even when the retired MATLABDATAPATH (deleted fallback,
         % juq.7) points at a real folder. The warning has no identifier,
         % so the test reads lastwarn instead of using verifyWarning.
         [legacyFolder, ~] = testCase.tempTarget();
         unsetenv('USERDATAPATH');
         unsetenv('MATLAB_ACTIVE_PROJECT_DATA_PATH');
         setenv('MATLABDATAPATH', legacyFolder);
         expected = pwd();
         lastwarn('', '');
         cddata();
         [warnmsg, ~] = lastwarn();
         returned = pwd();
         testCase.verifyEqual(returned, expected);
         testCase.verifyEqual(warnmsg, 'no USERDATAPATH found');
      end
   end
end
