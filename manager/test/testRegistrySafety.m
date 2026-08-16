classdef testRegistrySafety < matlab.unittest.TestCase
   %TESTREGISTRYSAFETY Unit tests for manager registry hardening (juq.6).
   %
   % Every test redirects PROJECTDIRECTORYPATH/TBDIRECTORYPATH to a fresh
   % temp folder, so the real registries in $HOME/MATLAB/directory are never
   % touched. The MATLAB_ACTIVE_* env family is saved and restored around
   % each test for the same reason.

   properties
      regDir string
      % Explicit scalar default: a bare typed struct property initializes
      % 0x0, and dot assignment into an empty struct errors.
      savedEnv struct = struct()
   end

   properties (Constant)
      % Env vars every test saves, redirects or mutates, and restores.
      % MATLAB_PROJECT_PATH is included because rmproject's name validation
      % scans that folder (validateProjectName -> projectdirectorylist).
      envNames = ["PROJECTDIRECTORYPATH", "TBDIRECTORYPATH", ...
         "MATLAB_PROJECT_PATH", "MATLAB_ACTIVE_PROJECT", ...
         "MATLAB_ACTIVE_PROJECT_PATH", "MATLAB_ACTIVE_PROJECT_DATA_PATH", ...
         "MATLAB_ACTIVE_PROJECT_TESTBED_PATH"]
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so the manager functions resolve from
         % the repo root.
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

         % Save the real env values, then point both registry paths at a
         % fresh temp folder for this test.
         for name = testCase.envNames
            testCase.savedEnv.(matlab.lang.makeValidName(name)) = getenv(name);
         end
         testCase.addTeardown(@() testCase.restoreEnv())

         tmp = testCase.applyFixture(TemporaryFolderFixture);
         testCase.regDir = string(tmp.Folder);
         setenv('PROJECTDIRECTORYPATH', testCase.regDir);
         setenv('TBDIRECTORYPATH', testCase.regDir);
         % Fixture project folders, so name validation that scans
         % MATLAB_PROJECT_PATH accepts the fixture names.
         setenv('MATLAB_PROJECT_PATH', testCase.regDir);
         mkdir(fullfile(testCase.regDir, "alpha"))
         mkdir(fullfile(testCase.regDir, "default"))
      end
   end

   methods (Access = private)
      function restoreEnv(testCase)
         for name = testCase.envNames
            setenv(name, testCase.savedEnv.(matlab.lang.makeValidName(name)));
         end
      end

      function projectlist = fixtureProjectList(testCase)
         % Two-row registry with the columns writeprjdirectory requires:
         % alpha (active) and the default row rmproject falls back to.
         folders = [fullfile(testCase.regDir, "alpha"); ...
            fullfile(testCase.regDir, "default")];
         projectlist = table( ...
            {'alpha'; 'default'}, ...
            cellstr(folders), ...
            {{}; {}}, ...
            [true; false], ...
            cellstr(folders), ...
            VariableNames={'name', 'folder', 'activefiles', ...
            'activeproject', 'activefolder'});
      end
   end

   methods (Test)
      function testPrjRoundTripAndFirstWrite(testCase)
         % A first write into a fresh folder must succeed (the old code's
         % unconditional copyfile backup errored without a canonical file),
         % and the round trip must come back from the canonical source.
         expected = testCase.fixtureProjectList();
         writeprjdirectory(expected)
         [returned, source] = readprjdirectory();
         testCase.verifyEqual(returned.name, expected.name)
         testCase.verifyEqual(source, 'canonical')
      end

      function testPrjEmptyWriteRefused(testCase)
         % An empty table must be refused with a warning, leaving the
         % canonical registry intact.
         expected = testCase.fixtureProjectList();
         writeprjdirectory(expected)
         testCase.verifyWarning( ...
            @() writeprjdirectory(expected(1:0, :)), ...
            'matfunclib:writeprjdirectory:emptyWrite')
         returned = readprjdirectory();
         testCase.verifyEqual(returned.name, expected.name)
      end

      function testPrjMissingFieldsRejected(testCase)
         badTable = table({'alpha'}, VariableNames={'name'});
         testCase.verifyError( ...
            @() writeprjdirectory(badTable), ...
            'matfunclib:writeprjdirectory:missingFields')
      end

      function testPrjBackupFallback(testCase)
         % Corrupting the canonical file must fall back to the newest
         % tp*.mat backup (created by the second write).
         expected = testCase.fixtureProjectList();
         writeprjdirectory(expected)
         writeprjdirectory(expected)   % second write backs up the first
         canonical = fullfile(testCase.regDir, "projectdirectory.mat");
         writelines("corrupt", canonical)
         [returned, source] = testCase.verifyWarning( ...
            @() readprjdirectory(), ...
            'matfunclib:readprjdirectory:canonicalFailed');
         testCase.verifyEqual(returned.name, expected.name)
         testCase.verifyEqual(source, 'backup')
      end

      function testPrjNoUsableDirectoryErrors(testCase)
         % No canonical file and no backups: a clear error, not a
         % fabricated empty table.
         testCase.verifyError( ...
            @() readprjdirectory(), ...
            'matfunclib:readprjdirectory:noUsableDirectory')
      end

      function testBackupRotationCap(testCase)
         % The rotation helper keeps the requested number of newest files.
         for n = 1:6
            writelines("x", fullfile(testCase.regDir, "tp_fake" + n + ".mat"))
         end
         prunedirectorybackups(testCase.regDir, "tp*.mat", 3);
         returned = numel(dir(fullfile(testCase.regDir, "tp*.mat")));
         expected = 3;
         testCase.verifyEqual(returned, expected)
      end

      function testTbEmptyWriteStillGuarded(testCase)
         % Parity regression: the toolbox-side guard stays intact.
         emptyToolboxes = table( ...
            'Size', [0 4], ...
            'VariableTypes', {'cellstr', 'cellstr', 'logical', 'string'}, ...
            'VariableNames', {'name', 'source', 'active', 'library'});
         testCase.verifyWarning( ...
            @() writetbdirectory(emptyToolboxes), ...
            'matfunclib:writetbdirectory:emptyWrite')
      end

      function testSetprojectactiveEnvTrio(testCase)
         % setprojectactive writes exactly the canonical env trio.
         writeprjdirectory(testCase.fixtureProjectList())
         setprojectactive('default')
         setprojectactive('alpha')
         expectedFolder = char(fullfile(testCase.regDir, "alpha"));
         testCase.verifyEqual(getenv('MATLAB_ACTIVE_PROJECT'), 'alpha')
         testCase.verifyEqual( ...
            getenv('MATLAB_ACTIVE_PROJECT_PATH'), expectedFolder)
         testCase.verifyEqual( ...
            getenv('MATLAB_ACTIVE_PROJECT_DATA_PATH'), ...
            fullfile(expectedFolder, 'data'))
         % The removed _TESTBED_PATH variant must no longer be written.
         setenv('MATLAB_ACTIVE_PROJECT_TESTBED_PATH', '')
         setprojectactive('alpha')
         testCase.verifyEmpty(getenv('MATLAB_ACTIVE_PROJECT_TESTBED_PATH'))
      end

      function testTbWriteBacksUpAndPrunes(testCase)
         % A real toolbox write round-trips, backs up the prior CSV, and
         % rotates the tbd_*.mat pool down to the cap.
         toolboxes = table({'b17'}, {'somewhere'}, false, "hydro", ...
            VariableNames={'name', 'source', 'active', 'library'});
         writetbdirectory(toolboxes)
         for n = 1:30
            writelines("x", fullfile(testCase.regDir, "tbd_fake" + n + ".mat"))
         end
         writetbdirectory(toolboxes)   % backs up, writes, prunes
         returned = numel(dir(fullfile(testCase.regDir, "tbd_*.mat")));
         expected = 25;
         testCase.verifyEqual(returned, expected)
         testCase.verifyEqual(readtbdirectory().name, toolboxes.name)
      end

      function testPrjSelfReadRewrite(testCase)
         % The nargin<1 form re-reads the current directory and re-writes
         % it unchanged.
         expected = testCase.fixtureProjectList();
         writeprjdirectory(expected)
         writeprjdirectory()
         returned = readprjdirectory();
         testCase.verifyEqual(returned.name, expected.name)
      end

      function testCorruptBackupTierErrors(testCase)
         % A corrupt canonical file plus a corrupt backup exhausts both
         % tiers: the backup-restore warning fires and the final error is
         % the rebuild-guidance error.
         writelines("corrupt", ...
            fullfile(testCase.regDir, "projectdirectory.mat"))
         writelines("corrupt", fullfile(testCase.regDir, "tp_bad.mat"))
         testCase.verifyError( ...
            @() readprjdirectory(), ...
            'matfunclib:readprjdirectory:noUsableDirectory')
      end

      function testRotationDeleteFailureWarns(testCase)
         % A write-protected folder makes deletion fail: the helper warns
         % per file and keeps going instead of erroring.
         subdir = fullfile(testCase.regDir, "locked");
         mkdir(subdir)
         for n = 1:3
            writelines("x", fullfile(subdir, "tp_fake" + n + ".mat"))
         end
         fileattrib(subdir, '-w')
         testCase.addTeardown(@() fileattrib(subdir, '+w'))
         testCase.verifyWarning( ...
            @() prunedirectorybackups(subdir, "tp*.mat", 1), ...
            'matfunclib:prunedirectorybackups:deleteFailed')
      end

      function testRmprojectActiveFallsBackToDefault(testCase)
         % Removing the active project reassigns default and fixes the env
         % name (the old code set a misspelled variable). The path vars
         % deliberately keep the removed project's still-existing folders:
         % blanking them would break readers for which a set-but-empty var
         % counts as usable (cddata's isenv guard).
         writeprjdirectory(testCase.fixtureProjectList())
         setprojectactive('alpha')
         expected = getenv('MATLAB_ACTIVE_PROJECT_PATH');
         rmproject('alpha')
         returned = readprjdirectory();
         testCase.verifyFalse(any(strcmp(returned.name, 'alpha')))
         testCase.verifyTrue( ...
            returned.activeproject(strcmp(returned.name, 'default')))
         testCase.verifyEqual(getenv('MATLAB_ACTIVE_PROJECT'), 'default')
         testCase.verifyEqual(getenv('MATLAB_ACTIVE_PROJECT_PATH'), expected)
      end
   end
end
