classdef testBackupfile < matlab.unittest.TestCase
   %TESTBACKUPFILE Unit tests for the harvested varargout behavior of backupfile.
   %
   % The legacy function-based suite (test_backupfile.m) covers the copy/zip
   % mechanics; this suite targets the output contract harvested from the
   % icemodel copy: varargout so zero-output calls display nothing, and every
   % code path (including the file-not-found warning path) still assigns
   % requested outputs.

   properties
      tmpFile string
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so backupfile and its helpers
         % (isoctave, mkfiledate, tempfile) resolve from the repo root.
         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end

      function makeFixtureFile(testCase)
         import matlab.unittest.fixtures.TemporaryFolderFixture

         % One real file to back up.
         tmp = testCase.applyFixture(TemporaryFolderFixture);
         testCase.tmpFile = fullfile(tmp.Folder, "target.m");
         writelines("% fixture", testCase.tmpFile)
      end
   end

   methods (Test)
      function testTwoOutputsNameOnly(testCase)
         % Name-only mode (no copy) returns the backup path and name.
         [returned_path, returned_name] = backupfile(testCase.tmpFile);
         testCase.verifyFalse(isfile(returned_path))
         testCase.verifySubstring(returned_name, "target")
         testCase.verifySubstring(returned_path, "target")
      end

      function testOneOutputNameOnly(testCase)
         returned = backupfile(testCase.tmpFile);
         testCase.verifySubstring(returned, "target")
      end

      function testZeroOutputCallRuns(testCase)
         % The varargout contract: calling with no outputs neither errors
         % nor assigns ans in this workspace.
         backupfile(testCase.tmpFile)
         testCase.verifyEqual(exist('ans', 'var'), 0)
      end

      function testMissingFileStillAssignsOutputs(testCase)
         % The file-not-found path warns but must still assign requested
         % outputs (the harvested icemodel copy returned early and left
         % varargout unassigned). The warning has no identifier, so check
         % it through lastwarn.
         missing = fullfile(tempname() + ".m");
         lastwarn('');
         returned = backupfile(missing, true);
         testCase.verifySubstring(lastwarn(), "File not found")
         testCase.verifySubstring(returned, "_")
      end
   end
end
