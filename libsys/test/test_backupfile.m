function tests = test_backupfile
   tests = functiontests(localfunctions);
end

% Setup shared resources
function setupOnce(testCase)

   % Run the tests in a temp directory.
   testCase.TestData.origPath = pwd;
   testCase.TestData.tmpDir = [tempname '_backupfile_test'];
   mkdir(testCase.TestData.tmpDir);
   cd(testCase.TestData.tmpDir);

   tempprfx = tempfile;
   testCase.TestData.filename = [tempprfx '.m'];
   testCase.TestData.tempprfx = tempprfx;
   fclose(fopen(testCase.TestData.filename, 'w'));
end

% Cleanup
function teardownOnce(testCase)
   cd(testCase.TestData.origPath);
   rmdir(testCase.TestData.tmpDir, 's');
end

% Test a file without making a copy
function test_no_copy(testCase)
   [fullpath_bk, filename_bk] = backupfile(testCase.TestData.filename);
   assert(~isfile(fullpath_bk), 'Backup should not exist');
   assert(contains(filename_bk, testCase.TestData.tempprfx), ...
      'Backup filename should contain original filename');
end

% Test a file with a copy (without zip)
function test_with_copy(testCase)
   [fullpath_bk, ~] = backupfile(testCase.TestData.filename, true, false);
   assert(isfile(fullpath_bk), 'Backup should exist');
   delete(fullpath_bk);  % Delete the backup file after test
end

% Test a file with a copy (with zip)
function test_with_zip(testCase)
   [fullpath_bk, ~] = backupfile(testCase.TestData.filename, true, true);
   assert(isfile(fullpath_bk), 'Zip backup should exist');
   delete(fullpath_bk);  % Delete the backup zip file after test
end

% Test a folder without making a copy
function test_folder_no_copy(testCase)
   [~, tmpDirName] = fileparts(testCase.TestData.tmpDir);
   [fullpath_bk, foldername_bk] = backupfile(testCase.TestData.tmpDir);
   assert(~isfolder(fullpath_bk), 'Backup folder should not exist');
   assert(contains(foldername_bk, tmpDirName), 'Backup foldername should contain original foldername');
end

% Test a folder with making a copy (no zip)
function test_folder_with_copy(testCase)
   [fullpath_bk, ~] = backupfile(testCase.TestData.tmpDir, true, false);
   assert(isfolder(fullpath_bk), 'Backup folder should exist');
   rmdir(fullpath_bk, 's');  % Delete the backup folder after test
end

% Test a folder with making a copy (with zip)
function test_folder_with_zip(testCase)
   % pause for one second otherwise (i think) this test will fail b/c the prior
   % test bk file will match this one and since it exists, the function refuses
   % to make a new one with identical name. 
   % Instead of pausing, see rmdir(fullpath_bk, s) in test_folder_with_copy, but
   % keep the pause as a reminder when debugging future tests. 
   % pause(1)  
   [fullpath_bk, ~] = backupfile(testCase.TestData.tmpDir, true, true);
   assert(isfile(fullpath_bk), 'Zip backup should exist');
   
   % Strip out the .zip and ensure the backup folder does not exist
   [parent_bk_nozip, foldername_bk_nozip] = fileparts(fullpath_bk);
   fullpath_bk_nozip = fullfile(parent_bk_nozip, foldername_bk_nozip);
   assert(~isfile(fullpath_bk_nozip), 'Unzipped backup folder should not exist');
   
   delete(fullpath_bk);  % Delete the backup zip file after test
end

% Test warnings
function test_warnings(testCase)
   backupfile(testCase.TestData.filename, true);
   lastwarn('');
   backupfile(testCase.TestData.filename, true);
   [msg, id] = lastwarn;
   assert(strcmp(msg, 'Backup already exists. No copy made.'), 'Warning for existing backup not triggered');
end
