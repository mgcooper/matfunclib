classdef testToolboxRegistryReads < matlab.unittest.TestCase
   %TESTTOOLBOXREGISTRYREADS readtbdirectory error default (matfunclib-b7u).
   %
   % readtbdirectory errors when neither the canonical CSV nor a tbd_*.mat
   % backup can be read, like readprjdirectory. It returns the empty
   % table only on the opt-in that buildtoolboxdirectory's rebuild uses.
   % Every test redirects the registry environment (the
   % testRegistrySafety pattern) so no test touches the real registries.

   properties
      regDir string
      savedEnv struct = struct()
   end

   properties (Constant)
      envNames = ["MATLAB_DIRECTORY_PATH", "MATLAB_PROJECT_PATH", ...
         "MATLAB_TOOLBOX_PATH"]
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (TestMethodSetup)
      function redirectRegistries(testCase)
         import matlab.unittest.fixtures.TemporaryFolderFixture

         for name = testCase.envNames
            testCase.savedEnv.(matlab.lang.makeValidName(name)) = getenv(name);
         end
         testCase.addTeardown(@() testCase.restoreEnv())

         tmp = testCase.applyFixture(TemporaryFolderFixture);
         testCase.regDir = string(tmp.Folder);
         setenv('MATLAB_DIRECTORY_PATH', testCase.regDir);
         setenv('MATLAB_PROJECT_PATH', testCase.regDir);
         % One stand-alone toolbox folder for the rebuild scan.
         setenv('MATLAB_TOOLBOX_PATH', fullfile(testCase.regDir, "toolboxes"));
         mkdir(fullfile(testCase.regDir, "toolboxes", "tbone"))
      end
   end

   methods (Access = private)
      function restoreEnv(testCase)
         for name = testCase.envNames
            setenv(name, testCase.savedEnv.(matlab.lang.makeValidName(name)));
         end
      end

      function canonical = canonicalPath(testCase)
         canonical = char(fullfile(testCase.regDir, "toolboxdirectory.csv"));
      end
   end

   methods (Test)
      function testMissingRegistryErrorsByDefault(testCase)
         % No CSV and no backup: the default read errors with rebuild
         % guidance and returns no empty table.
         testCase.verifyError(@() readtbdirectory(testCase.canonicalPath()), ...
            'matfunclib:readtbdirectory:noUsableDirectory')
      end

      function testCorruptRegistryWithoutBackupErrors(testCase)
         % An unparseable CSV with no backup errors the same way.
         writelines("garbage", testCase.canonicalPath())
         testCase.verifyError(@() readtbdirectory(testCase.canonicalPath()), ...
            'matfunclib:readtbdirectory:noUsableDirectory')
      end

      function testOptInReturnsEmptyTable(testCase)
         % The opt-in returns the schema-correct empty table with source
         % 'empty' and the returnedEmpty warning. A [] first argument
         % selects the default registry path.
         [returned, source] = testCase.verifyWarning( ...
            @() readtbdirectory([], true), ...
            'matfunclib:readtbdirectory:returnedEmpty');
         expected = table('Size', [0 4], ...
            'VariableTypes', {'cellstr', 'cellstr', 'logical', 'string'}, ...
            'VariableNames', {'name', 'source', 'active', 'library'});
         testCase.verifyEqual(returned, expected)
         returned = source;
         expected = 'empty';
         testCase.verifyEqual(returned, expected)
      end

      function testRebuildBootstrapsWithoutARegistry(testCase)
         % buildtoolboxdirectory('rebuild') on a machine with no registry
         % takes the opt-in, warns that there is no active state to keep,
         % and writes the scanned toolbox as inactive.
         testCase.verifyWarning(@() buildtoolboxdirectory('rebuild'), ...
            'matfunclib:buildtoolboxdirectory:rebuildEmptyOld')
         % The CSV round trip returns active as double, so the test
         % compares the columns one by one.
         toolboxes = readtbdirectory(testCase.canonicalPath());
         returned = {toolboxes.name, toolboxes.source, ...
            logical(toolboxes.active), toolboxes.library};
         expected = {{'tbone'}, ...
            {char(fullfile(testCase.regDir, "toolboxes", "tbone"))}, ...
            false, "tbone"};
         testCase.verifyEqual(returned, expected)
      end

      function testRebuildKeepsActiveStateFromAGoodRegistry(testCase)
         % With a readable registry the rebuild keeps active = true for a
         % name the scan finds again.
         toolboxes = table({'tbone'}, {'/old/place'}, true, "tbone", ...
            VariableNames={'name', 'source', 'active', 'library'});
         writetbdirectory(toolboxes, testCase.canonicalPath())
         buildtoolboxdirectory('rebuild')
         returned = logical(readtbdirectory(testCase.canonicalPath()).active);
         expected = true;
         testCase.verifyEqual(returned, expected)
      end

      function testDeactivateAllRefusesToWriteOnADegradedRead(testCase)
         % A write-back consumer on a corrupt registry with no backup:
         % deactivate('all') errors from the read, leaves the CSV
         % untouched, and creates no backup file.
         canonical = testCase.canonicalPath();
         writelines("garbage", canonical)
         before = dir(canonical);
         testCase.verifyError(@() deactivate('all'), ...
            'matfunclib:readtbdirectory:noUsableDirectory')
         after = dir(canonical);
         returned = after.bytes;
         expected = before.bytes;
         testCase.verifyEqual(returned, expected)
         returned = numel(dir(fullfile(testCase.regDir, "tbd_*.mat")));
         expected = 0;
         testCase.verifyEqual(returned, expected)
      end
   end
end
