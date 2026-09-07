classdef testBuildprojectdirectory < matlab.unittest.TestCase
   %TESTBUILDPROJECTDIRECTORY Unit tests for the project-directory builder.
   %
   % Every test redirects MATLAB_PROJECT_PATH (the scan root) and
   % MATLAB_DIRECTORY_PATH (the registry folder) to fresh temp folders, so
   % the real project directory is never touched. A fresh dry run supplies
   % a schema-correct seed that each test customizes and writes as the
   % saved registry before rebuilding.

   properties
      projDir string
      regDir string
      % Explicit scalar default: a bare typed struct property initializes
      % 0x0, and dot assignment into an empty struct errors.
      savedEnv struct = struct()
      savedPath char = ''
   end

   properties (Constant)
      envNames = ["MATLAB_PROJECT_PATH", "MATLAB_DIRECTORY_PATH", ...
         "MATLAB_HOME_PATH"]
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so the builder and its helpers
         % resolve from the repo root.
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

         for name = testCase.envNames
            testCase.savedEnv.(matlab.lang.makeValidName(name)) = getenv(name);
         end
         testCase.savedPath = path();
         testCase.addTeardown(@() testCase.restoreState())

         proj = testCase.applyFixture(TemporaryFolderFixture);
         reg = testCase.applyFixture(TemporaryFolderFixture);
         testCase.projDir = string(proj.Folder);
         testCase.regDir = string(reg.Folder);
         setenv('MATLAB_PROJECT_PATH', testCase.projDir);
         setenv('MATLAB_DIRECTORY_PATH', testCase.regDir);
         setenv('MATLAB_HOME_PATH', testCase.regDir);

         % Two scannable project folders for every test.
         mkdir(fullfile(testCase.projDir, "projA"))
         mkdir(fullfile(testCase.projDir, "projB"))
      end
   end

   methods (Access = private)
      function restoreState(testCase)
         %RESTORESTATE Put back the saved env values and search path.
         path(testCase.savedPath);
         for name = testCase.envNames
            saved = testCase.savedEnv.(matlab.lang.makeValidName(name));
            if isempty(saved)
               unsetenv(name);
            else
               setenv(name, saved);
            end
         end
      end

      function seed = freshSeed(~)
         %FRESHSEED A schema-correct registry list from a fresh dry run.
         seed = buildprojectdirectory('fresh', 'dryrun');
      end

      function rownum = rowOf(~, list, name)
         %ROWOF Index of the row for a project name.
         rownum = find(strcmp(list.name, name), 1);
      end
   end

   methods (Test)
      function testFreshBuildWritesEmptyState(testCase)
         % A fresh build scans the project folders and writes a registry
         % with empty state for every project.
         buildprojectdirectory('fresh');
         returned = readprjdirectory();
         testCase.verifyTrue(ismember('projA', returned.name));
         testCase.verifyTrue(ismember('projB', returned.name));
         testCase.verifyTrue(ismember('default', returned.name));
         a = testCase.rowOf(returned, 'projA');
         testCase.verifyEmpty(returned.activefiles{a});
         testCase.verifyFalse(returned.activeproject(a));
      end

      function testFreshBacksUpExistingCanonical(testCase)
         % A fresh build over an existing registry writes through
         % writeprjdirectory, so the canonical file is backed up first
         % instead of being clobbered by a raw save.
         writeprjdirectory(testCase.freshSeed())
         before = numel(dir(fullfile(testCase.regDir, "tp*.mat")));
         buildprojectdirectory('fresh');
         returned = numel(dir(fullfile(testCase.regDir, "tp*.mat")));
         testCase.verifyGreaterThan(returned, before)
      end

      function testDefaultModeIsRebuild(testCase)
         % No argument rebuilds (preserves saved state) rather than doing
         % a destructive fresh wipe.
         seed = testCase.freshSeed();
         a = testCase.rowOf(seed, 'projA');
         seed.activefiles{a} = {'foo.m'};
         writeprjdirectory(seed)

         buildprojectdirectory();
         result = readprjdirectory();
         a = testCase.rowOf(result, 'projA');
         returned = result.activefiles{a};
         expected = {'foo.m'};
         testCase.verifyEqual(returned, expected);
      end

      function testRebuildPreservesActiveStateAndFiles(testCase)
         % Rebuild carries activefiles and the active flag forward by
         % name.
         seed = testCase.freshSeed();
         a = testCase.rowOf(seed, 'projA');
         seed.activefiles{a} = {'foo.m'; 'bar.m'};
         seed.activeproject(a) = true;
         writeprjdirectory(seed)

         buildprojectdirectory('rebuild');
         result = readprjdirectory();
         a = testCase.rowOf(result, 'projA');
         returned = result.activefiles{a};
         expected = {'foo.m'; 'bar.m'};
         testCase.verifyEqual(returned, expected);
         testCase.verifyTrue(result.activeproject(a));
      end

      function testRebuildUpdatesFolderAfterMove(testCase)
         % The scan is authoritative for the folder: a stale saved folder
         % is replaced while the saved state is kept.
         seed = testCase.freshSeed();
         a = testCase.rowOf(seed, 'projA');
         seed.folder{a} = '/old/stale/path';
         seed.activefiles{a} = {'foo.m'};
         writeprjdirectory(seed)

         buildprojectdirectory('rebuild');
         result = readprjdirectory();
         a = testCase.rowOf(result, 'projA');
         returned = result.folder{a};
         expected = char(testCase.projDir);
         testCase.verifyEqual(returned, expected);
         returned = result.activefiles{a};
         expected = {'foo.m'};
         testCase.verifyEqual(returned, expected);
      end

      function testRebuildDeactivatesMissingActiveProject(testCase)
         % A saved active project with no folder in the scan does not
         % block the rebuild: it is warned about, deactivated, and kept
         % because it still holds activefiles.
         seed = testCase.freshSeed();
         ghost = seed(testCase.rowOf(seed, 'projA'), :);
         ghost.name = {'ghost'};
         ghost.activeproject = true;
         ghost.activefiles = {{'keep.m'}};
         seed = [seed; ghost];
         writeprjdirectory(seed)

         testCase.verifyWarning(@() buildprojectdirectory('rebuild'), ...
            'matfunclib:buildprojectdirectory:activeProjectMissing')
         result = readprjdirectory();
         g = testCase.rowOf(result, 'ghost');
         testCase.verifyNotEmpty(g);
         testCase.verifyFalse(result.activeproject(g));
         returned = result.activefiles{g};
         expected = {'keep.m'};
         testCase.verifyEqual(returned, expected);
      end

      function testRebuildDropsMissingProjectWithoutState(testCase)
         % A saved project missing from the scan with no state is dropped.
         seed = testCase.freshSeed();
         ghost = seed(testCase.rowOf(seed, 'projA'), :);
         ghost.name = {'ghost'};
         seed = [seed; ghost];
         writeprjdirectory(seed)

         buildprojectdirectory('rebuild');
         returned = readprjdirectory();
         testCase.verifyFalse(ismember('ghost', returned.name));
      end

      function testRebuildPreservesActivefolderOffset(testCase)
         % A saved activefolder that extends past folder/name keeps its
         % trailing offset under the new parent (the icom-msd case).
         seed = testCase.freshSeed();
         a = testCase.rowOf(seed, 'projA');
         seed.activefolder{a} = fullfile('/old/stale/path', 'projA', 'sub');
         seed.folder{a} = '/old/stale/path';
         writeprjdirectory(seed)

         buildprojectdirectory('rebuild');
         result = readprjdirectory();
         a = testCase.rowOf(result, 'projA');
         returned = result.activefolder{a};
         expected = char(fullfile(testCase.projDir, 'projA', 'sub'));
         testCase.verifyEqual(returned, expected);
      end

      function testRebuildStripsTrailingSepFromOffset(testCase)
         % A saved activefolder offset with a trailing separator rebuilds
         % to a clean path (no trailing separator), so it matches the
         % fullfile-built activefolder of every other project.
         seed = testCase.freshSeed();
         a = testCase.rowOf(seed, 'projA');
         seed.activefolder{a} = [fullfile('/old/stale/path', 'projA', ...
            'sub') filesep];
         seed.folder{a} = '/old/stale/path';
         writeprjdirectory(seed)

         buildprojectdirectory('rebuild');
         result = readprjdirectory();
         a = testCase.rowOf(result, 'projA');
         returned = result.activefolder{a};
         expected = char(fullfile(testCase.projDir, 'projA', 'sub'));
         testCase.verifyEqual(returned, expected);
      end

      function testAbbreviatedFlagIsHonored(testCase)
         % validatestring accepts an unambiguous prefix; the flag must
         % resolve to its full name, so 'dry' honors the dry run and
         % writes nothing rather than silently performing a real write.
         canonical = fullfile(testCase.regDir, "projectdirectory.mat");
         buildprojectdirectory('fresh', 'dry');
         testCase.verifyFalse(isfile(canonical));
      end

      function testRebuildDefaultsActivefolderToScan(testCase)
         % A saved activefolder equal to folder/name tracks the scanned
         % folder, so a move updates it with no offset applied.
         seed = testCase.freshSeed();
         a = testCase.rowOf(seed, 'projA');
         seed.activefolder{a} = fullfile('/old/stale/path', 'projA');
         seed.folder{a} = '/old/stale/path';
         writeprjdirectory(seed)

         buildprojectdirectory('rebuild');
         result = readprjdirectory();
         a = testCase.rowOf(result, 'projA');
         returned = result.activefolder{a};
         expected = char(fullfile(testCase.projDir, 'projA'));
         testCase.verifyEqual(returned, expected);
      end

      function testDuplicateNameErrors(testCase)
         % A duplicate project name in the saved list makes the name
         % match ambiguous, so rebuild fails loud.
         seed = testCase.freshSeed();
         dup = seed(testCase.rowOf(seed, 'projA'), :);
         seed = [seed; dup];
         writeprjdirectory(seed)

         testCase.verifyError(@() buildprojectdirectory('rebuild'), ...
            'matfunclib:buildprojectdirectory:duplicateName')
      end

      function testDryrunDoesNotWrite(testCase)
         % A dry run returns the list without writing the registry.
         canonical = fullfile(testCase.regDir, "projectdirectory.mat");
         returned = buildprojectdirectory('fresh', 'dryrun');
         testCase.verifyGreaterThan(height(returned), 0);
         testCase.verifyFalse(isfile(canonical));
      end

      function testFreshRejectsDuplicateScannedName(testCase)
         % A real folder colliding with the synthetic 'default' row is a
         % duplicate name; the check runs on the fresh path too, so it
         % errors instead of writing an ambiguous registry.
         mkdir(fullfile(testCase.projDir, "default"))
         testCase.verifyError(@() buildprojectdirectory('fresh'), ...
            'matfunclib:buildprojectdirectory:duplicateName')
      end

      function testConflictingOptionsError(testCase)
         % fresh and rebuild are opposite modes; asking for both errors.
         testCase.verifyError( ...
            @() buildprojectdirectory('fresh', 'rebuild'), ...
            'matfunclib:buildprojectdirectory:conflictingOptions')
      end
   end
end
