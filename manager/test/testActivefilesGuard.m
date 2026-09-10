classdef testActivefilesGuard < matlab.unittest.TestCase
   %TESTACTIVEFILESGUARD Tests for the guarded activefiles write (juq.39).
   %
   % Audit HIGH #11 and MEDIUM #38: workoff, and workon on the already
   % active project, call setprojectfiles with the editor's open files.
   % A session that never reopened the project's files would then replace
   % a curated list with a near-empty one. The guard lives in
   % setprojectfiles: it refuses an editor-derived write when the stored
   % list is non-empty and none of its files is open. Every test
   % redirects the registry environment (the testRegistrySafety pattern)
   % so no test touches the real registries. Every test also shadows
   % getopenfiles with a fixture so the headless run controls what "the
   % editor holds".

   properties
      regDir string
      savedEnv struct = struct()
      savedPath char = ''
      % The folder holding the fixture getopenfiles.m; its contents decide
      % what the shadowed editor reports.
      shadowDir string
   end

   properties (Constant)
      envNames = ["MATLAB_DIRECTORY_PATH", "MATLAB_PROJECT_PATH", ...
         "MATLAB_TOOLBOX_PATH", "MATLAB_ACTIVE_PROJECT", ...
         "MATLAB_ACTIVE_PROJECT_PATH", "MATLAB_ACTIVE_PROJECT_DATA_PATH"]
      storedFiles = {'/fixture/alpha/one.m'; '/fixture/alpha/two.m'; ...
         '/fixture/alpha/three.m'}
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
      function buildFixtureWorld(testCase)
         import matlab.unittest.fixtures.TemporaryFolderFixture

         for name = testCase.envNames
            testCase.savedEnv.(matlab.lang.makeValidName(name)) = getenv(name);
         end
         testCase.savedPath = path();
         testCase.addTeardown(@() testCase.restoreState())
         clear('depledger')

         % workon and workoff change the current folder into a fixture
         % project. The setup moves to the repo root first when another
         % class left a current folder whose fixture is gone. A teardown
         % restores the folder after the fixture is removed (teardowns run
         % last-in first-out) so later classes do not inherit a deleted one.
         if ~isfolder(pwd)
            cd(fileparts(fileparts(fileparts(mfilename("fullpath")))))
         end
         startFolder = pwd;
         testCase.addTeardown(@() cd(startFolder))

         tmp = testCase.applyFixture(TemporaryFolderFixture);
         testCase.regDir = string(tmp.Folder);
         setenv('MATLAB_DIRECTORY_PATH', testCase.regDir);
         setenv('MATLAB_PROJECT_PATH', testCase.regDir);
         setenv('MATLAB_TOOLBOX_PATH', fullfile(testCase.regDir, "toolboxes"));
         mkdir(fullfile(testCase.regDir, "toolboxes"))

         % Two projects: alpha (active, with a stored file list) and
         % default (what workoff activates afterwards).
         folders = {char(fullfile(testCase.regDir, "alpha")); ...
            char(fullfile(testCase.regDir, "default"))};
         cellfun(@mkdir, folders)
         projectlist = table( ...
            {'alpha'; 'default'}, folders, ...
            {testCase.storedFiles; {}}, [true; false], folders, ...
            VariableNames={'name', 'folder', 'activefiles', ...
            'activeproject', 'activefolder'});
         writeprjdirectory(projectlist)
         setenv('MATLAB_ACTIVE_PROJECT', 'alpha')

         % The shadow editor: a getopenfiles.m ahead of libsys on the path.
         testCase.shadowDir = fullfile(testCase.regDir, "shadow");
         mkdir(testCase.shadowDir)
      end
   end

   methods (Access = private)
      function restoreState(testCase)
         path(testCase.savedPath)
         for name = testCase.envNames
            setenv(name, testCase.savedEnv.(matlab.lang.makeValidName(name)));
         end
      end

      function editorHolds(testCase, files)
         %EDITORHOLDS Make the shadowed getopenfiles report FILES.
         lines = ["function filenames = getopenfiles()"; ...
            "filenames = {" + strjoin("'" + string(files) + "'", "; ") + "};"; ...
            "end"];
         if isempty(files)
            lines(2) = "filenames = {};";
         end
         writelines(lines, fullfile(testCase.shadowDir, "getopenfiles.m"))
         addpath(testCase.shadowDir, '-begin')
      end

      function files = storedFor(~, name)
         %STOREDFOR The activefiles list the registry holds for NAME.
         projectlist = readprjdirectory();
         files = projectlist.activefiles{getprjidx(name, projectlist)};
      end
   end

   methods (Test)
      function testWorkoffKeepsListWhenEditorIsEmpty(testCase)
         % A plain workoff (default updatefiles=true) in a session whose
         % editor holds nothing keeps the stored list and warns.
         testCase.editorHolds({})

         testCase.verifyWarning(@() workoff('alpha'), ...
            'matfunclib:setprojectfiles:unpopulatedSession')
         returned = testCase.storedFor('alpha');
         expected = testCase.storedFiles;
         testCase.verifyEqual(returned, expected)
      end

      function testWorkoffKeepsListWhenEditorHoldsOtherFiles(testCase)
         % An editor holding only unrelated files also counts as a session
         % that never reopened the project: the stored list survives.
         testCase.editorHolds({'/elsewhere/scratch.m'})

         testCase.verifyWarning(@() workoff('alpha'), ...
            'matfunclib:setprojectfiles:unpopulatedSession')
         returned = testCase.storedFor('alpha');
         expected = testCase.storedFiles;
         testCase.verifyEqual(returned, expected)
      end

      function testWorkonOnActiveProjectKeepsList(testCase)
         % workon on the already active project takes the setprojectfiles
         % branch (workon.m line 73), so the same guard applies.
         testCase.editorHolds({})

         testCase.verifyWarning(@() workon('alpha'), ...
            'matfunclib:setprojectfiles:unpopulatedSession')
         returned = testCase.storedFor('alpha');
         expected = testCase.storedFiles;
         testCase.verifyEqual(returned, expected)
      end

      function testPopulatedSessionStillUpdates(testCase)
         % A session holding one of the stored files is a real editing
         % session: the stored list becomes what the editor holds.
         open = {'/fixture/alpha/two.m'; '/fixture/alpha/new.m'};
         testCase.editorHolds(open)

         testCase.verifyWarningFree(@() workoff('alpha'))
         returned = testCase.storedFor('alpha');
         expected = open;
         testCase.verifyEqual(returned, expected)
      end

      function testCaseVariantOfStoredFileCountsOnFoldingSystems(testCase)
         % On a volume that folds case, the editor may report a stored file
         % in a different case. That is the same open file, so the list
         % updates. On a case-sensitive volume the spellings are different
         % files and the guard keeps the list. The branch asks the stored
         % files' volume the same question the guard asks.
         open = {'/FIXTURE/ALPHA/TWO.M'};
         testCase.editorHolds(open)

         if foldscase(testCase.storedFiles{1})
            testCase.verifyWarningFree(@() workoff('alpha'))
            expected = open;
         else
            testCase.verifyWarning(@() workoff('alpha'), ...
               'matfunclib:setprojectfiles:unpopulatedSession')
            expected = testCase.storedFiles;
         end
         returned = testCase.storedFor('alpha');
         testCase.verifyEqual(returned, expected)
      end

      function testSeparatorVariantOfStoredFileCounts(testCase)
         % Windows accepts either separator, so a stored file the editor
         % reports with backslashes is the same open file there. Elsewhere
         % a backslash is an ordinary character, so the spellings differ
         % and the guard keeps the list.
         open = {'\fixture\alpha\two.m'};
         testCase.editorHolds(open)

         if ispc
            testCase.verifyWarningFree(@() workoff('alpha'))
            expected = open;
         else
            testCase.verifyWarning(@() workoff('alpha'), ...
               'matfunclib:setprojectfiles:unpopulatedSession')
            expected = testCase.storedFiles;
         end
         returned = testCase.storedFor('alpha');
         testCase.verifyEqual(returned, expected)
      end

      function testExplicitUpdatefilesFalseIsUnchanged(testCase)
         % startup.m passes updatefiles=false; that call never touches the
         % list and issues no warning.
         testCase.editorHolds({})

         testCase.verifyWarningFree(@() workoff('alpha', 'updatefiles', false))
         returned = testCase.storedFor('alpha');
         expected = testCase.storedFiles;
         testCase.verifyEqual(returned, expected)
      end

      function testExplicitFileListIsNeverGuarded(testCase)
         % A caller that names the list replaces the stored one on purpose,
         % even with an empty list.
         setprojectfiles('alpha', {})
         returned = testCase.storedFor('alpha');
         expected = {};
         testCase.verifyEqual(returned, expected)
      end
   end
end
