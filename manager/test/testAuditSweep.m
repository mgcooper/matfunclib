classdef testAuditSweep < matlab.unittest.TestCase
   %TESTAUDITSWEEP Regression tests for the juq.40 degradation-audit sweep.
   %
   % Each test names the audit finding it covers (MEDIUM 17, 27, 30, 34;
   % LOW 40, 53). Every test redirects the registry environment (the
   % testRegistrySafety pattern) so no test touches the real registries.
   % Tests shadow interactive or path helpers with fixture files where a
   % headless run needs to control them.

   properties
      regDir string
      tbRoot string
      shadowDir string
      savedEnv struct = struct()
   end

   properties (Constant)
      envNames = ["MATLAB_DIRECTORY_PATH", "MATLAB_PROJECT_PATH", ...
         "MATLAB_TOOLBOX_PATH", "MATLAB_ACTIVE_PROJECT", ...
         "MATLAB_ACTIVE_PROJECT_PATH", "MATLAB_ACTIVE_PROJECT_DATA_PATH"]
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
         testCase.tbRoot = fullfile(testCase.regDir, "toolboxes");
         setenv('MATLAB_DIRECTORY_PATH', testCase.regDir);
         setenv('MATLAB_PROJECT_PATH', testCase.regDir);
         setenv('MATLAB_TOOLBOX_PATH', testCase.tbRoot);
         mkdir(fullfile(testCase.tbRoot, "tbone"))
         mkdir(fullfile(testCase.regDir, "alpha"))
         mkdir(fullfile(testCase.regDir, "default"))

         % Shadow folder for fixture versions of input and path helpers.
         testCase.shadowDir = fullfile(testCase.regDir, "shadow");
         mkdir(testCase.shadowDir)
      end
   end

   methods (Access = private)
      function restoreEnv(testCase)
         for name = testCase.envNames
            setenv(name, testCase.savedEnv.(matlab.lang.makeValidName(name)));
         end
      end

      function shadow(testCase, name, lines)
         %SHADOW Put a fixture NAME.m ahead of everything on the path.
         writelines(lines, fullfile(testCase.shadowDir, name + ".m"))
         addpath(testCase.shadowDir, '-begin')
         testCase.addTeardown(@() rmpath(testCase.shadowDir))
         % MATLAB announces a shadow of a built-in once; that notice is
         % the fixture's, not the code under test's.
         conflict = warning('off', 'MATLAB:dispatcher:nameConflict');
         testCase.addTeardown(@() warning(conflict))
         rehash
      end

      function writeToolboxes(testCase, names)
         %WRITETOOLBOXES A registry with NAMES as stand-alone toolboxes.
         sources = cellfun(@(n) char(fullfile(testCase.tbRoot, n)), ...
            names, 'UniformOutput', false);
         toolboxes = table(names(:), sources(:), false(numel(names), 1), ...
            string(names(:)), ...
            VariableNames={'name', 'source', 'active', 'library'});
         writetbdirectory(toolboxes)
      end

      function canonical = canonicalPath(testCase)
         canonical = char(fullfile(testCase.regDir, "toolboxdirectory.csv"));
      end

      function projectlist = fixtureProjectList(testCase)
         folders = [fullfile(testCase.regDir, "alpha"); ...
            fullfile(testCase.regDir, "default")];
         projectlist = table({'alpha'; 'default'}, cellstr(folders), ...
            {{}; {}}, [true; false], cellstr(folders), ...
            VariableNames={'name', 'folder', 'activefiles', ...
            'activeproject', 'activefolder'});
      end
   end

   methods (Test)
      function testDeclinedMoveKeepsRegistryAndFolder(testCase)
         % MEDIUM 17: a requested source move the user declines leaves
         % the folder and the registry row unchanged, with a warning.
         testCase.writeToolboxes({'tbone'})
         testCase.shadow("input", ["function str = input(varargin)"; ...
            "str = 'n';"; "end"])

         returned = testCase.verifyWarning( ...
            @() renametoolbox('tbone', 'tbtwo', 'renamesource', true), ...
            'matfunclib:renametoolbox:moveDeclined');
         % The documented output form still returns the unchanged table.
         expected = {'tbone'};
         testCase.verifyEqual(returned.name, expected)
         returned = isfolder(fullfile(testCase.tbRoot, "tbone"));
         expected = true;
         testCase.verifyEqual(returned, expected)
         returned = readtbdirectory().name;
         expected = {'tbone'};
         testCase.verifyEqual(returned, expected)
      end

      function testFailedMoveErrorsAndKeepsRegistry(testCase)
         % A move that mv cannot do (the destination is an existing file)
         % raises an error, and the row is unchanged.
         testCase.writeToolboxes({'tbone'})
         writelines("in the way", fullfile(testCase.tbRoot, "tbtwo"))

         testCase.verifyError(@() renametoolbox('tbone', 'tbtwo', ...
            'renamesource', true, 'force', true), ...
            'matfunclib:renametbsourcedir:moveFailed')
         returned = isfolder(fullfile(testCase.tbRoot, "tbone"));
         expected = true;
         testCase.verifyEqual(returned, expected)
         returned = readtbdirectory().name;
         expected = {'tbone'};
         testCase.verifyEqual(returned, expected)
      end

      function testOptInNeedsAnExplicitTrue(testCase)
         % Only true opts in to the empty table: [] and 1 still error.
         canonical = char(fullfile(testCase.regDir, "toolboxdirectory.csv"));
         testCase.verifyError(@() readtbdirectory(canonical, []), ...
            'matfunclib:readtbdirectory:noUsableDirectory')
         testCase.verifyError(@() readtbdirectory(canonical, 1), ...
            'matfunclib:readtbdirectory:noUsableDirectory')
      end

      function testForcedMoveUpdatesRegistry(testCase)
         % The completed move (force skips the prompt) moves the folder
         % and rewrites the registry row.
         testCase.writeToolboxes({'tbone'})

         renametoolbox('tbone', 'tbtwo', 'renamesource', true, 'force', true)
         returned = isfolder(fullfile(testCase.tbRoot, "tbtwo"));
         expected = true;
         testCase.verifyEqual(returned, expected)
         toolboxes = readtbdirectory();
         returned = {toolboxes.name, toolboxes.source};
         expected = {{'tbtwo'}, {char(fullfile(testCase.tbRoot, "tbtwo"))}};
         testCase.verifyEqual(returned, expected)
      end

      function testProjectReaderRethrowsSchemaDefect(testCase)
         % MEDIUM 27 and LOW 50: a MAT file without the projectlist
         % variable is a schema defect and errors, even though a valid
         % backup exists that the fallback could have returned.
         projectlist = testCase.fixtureProjectList();
         writeprjdirectory(projectlist)
         writeprjdirectory(projectlist)   % second write makes a tp backup
         returned = numel(dir(fullfile(testCase.regDir, "tp*.mat")));
         expected = 1;
         testCase.verifyEqual(returned, expected)
         other = 1;
         save(getprjdirectorypath(), 'other')

         raised = [];
         try
            readprjdirectory();
         catch raised
         end
         returned = ~isempty(raised) && isreaderdefect(raised);
         expected = true;
         testCase.verifyEqual(returned, expected)
      end

      function testToolboxReaderRethrowsSchemaDefect(testCase)
         % MEDIUM 29 and 30: a CSV without the library column errors as a
         % schema defect; the reader does not fall back to the MAT backup.
         testCase.writeToolboxes({'tbone'})
         testCase.writeToolboxes({'tbone'})   % second write makes a backup
         returned = numel(dir(fullfile(testCase.regDir, "tbd_*.mat")));
         expected = 1;
         testCase.verifyEqual(returned, expected)
         canonical = char(fullfile(testCase.regDir, "toolboxdirectory.csv"));
         writelines(["name,source,active"; "tbone,/src,0"], canonical)

         raised = [];
         try
            readtbdirectory(canonical);
         catch raised
         end
         returned = ~isempty(raised) && isreaderdefect(raised);
         expected = true;
         testCase.verifyEqual(returned, expected)
      end

      function testUpdateKeepsUnreachableRows(testCase)
         % MEDIUM 34: a row whose folder cannot be found keeps its
         % recorded source and library on a real write, with a warning
         % naming it. The library-nested ghost keeps 'plotting' even
         % though the resolver resets a missing row's library.
         ghostsource = char(fullfile(testCase.tbRoot, "libraries", ...
            "plotting", "ghost"));
         toolboxes = table({'tbone'; 'ghost'}, ...
            {char(fullfile(testCase.tbRoot, "tbone")); ghostsource}, ...
            [false; false], ["tbone"; "plotting"], ...
            VariableNames={'name', 'source', 'active', 'library'});
         writetbdirectory(toolboxes)

         testCase.verifyWarning( ...
            @() updatetbdirectory('paths', 'dryrun', false), ...
            'matfunclib:updatetbdirectory:unreachable')
         toolboxes = readtbdirectory();
         returned = {toolboxes.name, toolboxes.source, toolboxes.library};
         expected = {{'tbone'; 'ghost'}, ...
            {char(fullfile(testCase.tbRoot, "tbone")); ghostsource}, ...
            ["tbone"; "plotting"]};
         testCase.verifyEqual(returned, expected)
      end

      function testRebuildRethrowsAReaderDefect(testCase)
         % A registry CSV with a partial schema is a writer defect, not a
         % missing registry. The rebuild raises the error, writes nothing,
         % and leaves the CSV untouched.
         canonical = testCase.canonicalPath();
         writelines(["name,source,active"; "tbone,/src,1"], canonical)
         before = dir(canonical);
         testCase.verifyError(@() buildtoolboxdirectory('rebuild'), ...
            'matfunclib:readtbdirectory:schemaDrift')
         after = dir(canonical);
         returned = after.datenum;
         expected = before.datenum;
         testCase.verifyEqual(returned, expected)
      end

      function testOpentbdirectoryWarnsWhenOpenFails(testCase)
         % LOW 40: with no registry file the OS open command fails by
         % status, and opentbdirectory warns.
         testCase.verifyWarning(@() opentbdirectory(), ...
            'matfunclib:opentbdirectory:openFailed')
      end

      function testOpentbdirectoryPropagatesPathDefect(testCase)
         % LOW 40: a missing path helper raises its own error before the
         % open runs.
         testCase.shadow("gettbdirectorypath", [ ...
            "function p = gettbdirectorypath()"; ...
            "error('MATLAB:UndefinedFunction', 'Unrecognized function.')"; ...
            "end"])
         testCase.verifyError(@() opentbdirectory(), ...
            'MATLAB:UndefinedFunction')
      end

      function testRevertConsidersProjectFilesOnly(testCase)
         % LOW 53: a newer toolbox backup in the same folder is not a
         % candidate, so the newest project file is still
         % projectdirectory.mat and the declined prompt returns the list.
         projectlist = testCase.fixtureProjectList();
         writeprjdirectory(projectlist)
         % The second write differs on purpose: MAT bytes saved within one
         % second can be identical, and the writer skips an identical
         % backup.
         projectlist.activeproject(:) = false;
         writeprjdirectory(projectlist)   % makes the tp backup
         writelines("x", fullfile(testCase.regDir, "tbd_newest.mat"))
         testCase.shadow("input", ["function str = input(varargin)"; ...
            "str = 'n';"; "end"])

         returned = revertprojectdirectory().name;
         expected = projectlist.name;
         testCase.verifyEqual(returned, expected)
      end

      function testRevertRejectsAFolderAtTheCanonicalPath(testCase)
         % A folder named projectdirectory.mat is not the canonical file.
         mkdir(fullfile(testCase.regDir, "projectdirectory.mat"))
         writelines("x", fullfile(testCase.regDir, "tp_old.mat"))
         testCase.verifyError(@() revertprojectdirectory(), ...
            'matfunclib:revertprojectdirectory:noCanonical')
      end

      function testRevertSkipsABackupIdenticalToTheCanonical(testCase)
         % Registry A, then B (whose write backs up A). The revert skips a
         % newer snapshot identical to B, so an accepted default revert
         % restores A, not B onto itself.
         listA = testCase.fixtureProjectList();
         writeprjdirectory(listA)
         listB = listA;
         listB.name{1} = 'alphaB';
         listB.activeproject(:) = false;
         writeprjdirectory(listB)
         copyfile(getprjdirectorypath(), fullfile(testCase.regDir, ...
            "projectdirectory_revert_same.mat"))
         testCase.shadow("input", ["function str = input(varargin)"; ...
            "str = 'y';"; "end"])

         revertprojectdirectory();
         returned = readprjdirectory().name;
         expected = listA.name;
         testCase.verifyEqual(returned, expected)
      end

      function testEmptyBackupDoesNotSatisfyTheDefaultRead(testCase)
         % An unreadable CSV with a zero-row tbd_*.mat backup: the backup
         % is no restore target, so the default read still errors.
         canonical = char(fullfile(testCase.regDir, "toolboxdirectory.csv"));
         writelines("garbage", canonical)
         toolboxes_backup = table('Size', [0 4], ...
            'VariableTypes', {'cellstr', 'cellstr', 'logical', 'string'}, ...
            'VariableNames', {'name', 'source', 'active', 'library'});
         save(fullfile(testCase.regDir, "tbd_empty.mat"), 'toolboxes_backup')
         testCase.verifyError(@() readtbdirectory(canonical), ...
            'matfunclib:readtbdirectory:noUsableDirectory')
      end

      function testBackupMissingAColumnDoesNotSatisfyTheDefaultRead(testCase)
         % A nonempty tbd_*.mat backup without the source column is not a
         % restore target: the default read still errors.
         canonical = char(fullfile(testCase.regDir, "toolboxdirectory.csv"));
         writelines("garbage", canonical)
         toolboxes_backup = table({'tb1'}, true, "lib1", ...
            VariableNames={'name', 'active', 'library'});
         save(fullfile(testCase.regDir, "tbd_bad.mat"), 'toolboxes_backup')
         testCase.verifyError(@() readtbdirectory(canonical), ...
            'matfunclib:readtbdirectory:noUsableDirectory')
      end

      function testReaderDefectClassifierCoversBothPlatforms(testCase)
         % MEDIUM 27 and 30: the classes both readers rethrow, in MATLAB's
         % and Octave's forms. A plain read failure is not a defect. The
         % Octave forms are structs with the two fields the function reads.
         cases = {struct('identifier', 'MATLAB:nonExistentField', 'message', 'x'), ...
            struct('identifier', 'Octave:invalid-indexing', ...
            'message', "structure has no member 'projectlist'"), ...
            struct('identifier', 'Octave:undefined-function', 'message', 'x'), ...
            struct('identifier', 'matfunclib:readtbdirectory:schemaDrift', ...
            'message', 'x')};
         returned = cellfun(@isreaderdefect, cases);
         expected = true(1, 4);
         testCase.verifyEqual(returned, expected)
         cases = {struct('identifier', 'MATLAB:load:couldNotReadFile', ...
            'message', 'x'), ...
            struct('identifier', 'Octave:invalid-indexing', ...
            'message', 'index out of bound')};
         returned = cellfun(@isreaderdefect, cases);
         expected = false(1, 2);
         testCase.verifyEqual(returned, expected)
      end

      function testRevertSnapshotIsACandidate(testCase)
         % A projectdirectory_revert_*.mat snapshot (the registry state a
         % revert saves before restoring) is a candidate. A snapshot newer
         % than the canonical file (as it is after a completed revert)
         % does not displace the canonical file from first place. With no
         % tp backup at all, the declined prompt still returns the list.
         projectlist = testCase.fixtureProjectList();
         writeprjdirectory(projectlist)   % first write, no tp backup
         writelines("newer snapshot", fullfile(testCase.regDir, ...
            "projectdirectory_revert_old.mat"))
         testCase.shadow("input", ["function str = input(varargin)"; ...
            "str = 'n';"; "end"])

         returned = revertprojectdirectory().name;
         expected = projectlist.name;
         testCase.verifyEqual(returned, expected)
      end
   end
end
