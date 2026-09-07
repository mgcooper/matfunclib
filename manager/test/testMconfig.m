classdef testMconfig < matlab.unittest.TestCase
   %TESTMCONFIG Unit tests for the mconfig path-family choke point (juq.7)
   %and for mgetenv with the path builders that resolve through it
   %(matfunclib-47r).
   %
   % Every test saves the real path-family env values and restores them in
   % teardown, so running the suite never leaves a mutated environment.

   properties
      % Explicit scalar default: a bare typed struct property initializes
      % 0x0, and dot assignment into an empty struct errors.
      savedEnv struct = struct()
   end

   properties (Constant)
      % The full path family mconfig owns; saved and restored around each
      % test because mconfig calls setenv on every one of them.
      envNames = ["MATLAB_HOME_PATH", "MATLAB_PROJECT_PATH", ...
         "MATLAB_TOOLBOX_PATH", "MATLAB_DIRECTORY_PATH", ...
         "MATLAB_FUNCTION_PATH", "MATLAB_TEMPLATE_PATH", ...
         "MATLAB_TOOLBOX_TEMPLATE_PATH", "MATLAB_FEX_PATH"]
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so mconfig resolves from the repo root.
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
         % Save the real env values so each test starts from and returns to
         % the caller's environment.
         for name = testCase.envNames
            testCase.savedEnv.(matlab.lang.makeValidName(name)) = getenv(name);
         end
         testCase.addTeardown(@() testCase.restoreEnv())
      end
   end

   methods (Access = private)
      function restoreEnv(testCase)
         %RESTOREENV Put back the saved path-family env values.
         % Teardown hook: every test calls mconfig, which setenvs the whole
         % family, so each saved value must be written back one by one.
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
      function testReturnsAllFamilyFields(testCase)
         % The struct carries exactly the path family, one field per var.
         returned = sort(string(fieldnames(mconfig())));
         expected = sort(testCase.envNames)';
         testCase.verifyEqual(returned, expected);
      end

      function testSetsEveryVariable(testCase)
         % Every family variable is exported and matches the struct field.
         cfg = mconfig();
         for name = testCase.envNames
            returned = getenv(name);
            expected = cfg.(name);
            testCase.verifyEqual(returned, expected, name);
         end
      end

      function testDerivationFromHome(testCase)
         % The family derives from $HOME/MATLAB with the documented layout.
         cfg = mconfig();
         homepath = fullfile(getenv('HOME'), 'MATLAB');
         testCase.verifyEqual(cfg.MATLAB_HOME_PATH, homepath);
         testCase.verifyEqual(cfg.MATLAB_PROJECT_PATH, ...
            fullfile(homepath, 'projects'));
         testCase.verifyEqual(cfg.MATLAB_TOOLBOX_PATH, ...
            fullfile(homepath, 'toolboxes'));
         testCase.verifyEqual(cfg.MATLAB_DIRECTORY_PATH, ...
            fullfile(homepath, 'directory'));
         testCase.verifyEqual(cfg.MATLAB_FUNCTION_PATH, ...
            fullfile(homepath, 'projects', 'matfunclib'));
         testCase.verifyEqual(cfg.MATLAB_TEMPLATE_PATH, ...
            fullfile(homepath, 'projects', 'matfunclib', 'templates'));
         testCase.verifyEqual(cfg.MATLAB_TOOLBOX_TEMPLATE_PATH, ...
            fullfile(homepath, 'projects', 'matfunclib', 'toolbox'));
         testCase.verifyEqual(cfg.MATLAB_FEX_PATH, ...
            fullfile(homepath, 'projects', 'fexlib'));
      end

      function testOverwritesStaleValues(testCase)
         % A stale pre-set value is replaced, so re-running converges.
         setenv('MATLAB_DIRECTORY_PATH', tempdir);
         cfg = mconfig();
         returned = getenv('MATLAB_DIRECTORY_PATH');
         expected = cfg.MATLAB_DIRECTORY_PATH;
         testCase.verifyEqual(returned, expected);
         testCase.verifyNotEqual(returned, tempdir);
      end

      function testIdempotent(testCase)
         % Two calls return identical structs and leave identical env state.
         first = mconfig();
         second = mconfig();
         testCase.verifyEqual(second, first);
         for name = testCase.envNames
            returned = getenv(name);
            expected = first.(name);
            testCase.verifyEqual(returned, expected, name);
         end
      end

      function testEmptyHomeErrors(testCase)
         % An empty HOME must error instead of deriving a relative
         % 'MATLAB/...' family that passes isempty guards yet resolves
         % against cwd (matfunclib-47r).
         savedHome = getenv('HOME');
         testCase.addTeardown(@() setenv('HOME', savedHome));
         setenv('HOME', '');
         testCase.verifyError(@() mconfig(), ...
            'matfunclib:manager:mconfig:emptyHome');
      end

      function testMgetenvPrefersSetValue(testCase)
         % A set variable wins over the mconfig default. Test fixtures
         % rely on this order when they redirect family members to temp
         % folders.
         redirect = fullfile(tempdir, 'mgetenv-redirect');
         setenv('MATLAB_DIRECTORY_PATH', redirect);
         returned = mgetenv('MATLAB_DIRECTORY_PATH');
         expected = redirect;
         testCase.verifyEqual(returned, expected);
      end

      function testMgetenvFallsBackWhenUnset(testCase)
         % An unset variable resolves to the mconfig default, and the
         % fallback re-exports the family so later direct getenv reads
         % are repaired too.
         unsetenv('MATLAB_DIRECTORY_PATH');
         returned = mgetenv('MATLAB_DIRECTORY_PATH');
         expected = fullfile(getenv('HOME'), 'MATLAB', 'directory');
         testCase.verifyEqual(returned, expected);
         testCase.verifyEqual(getenv('MATLAB_DIRECTORY_PATH'), expected);
      end

      function testMgetenvUnknownNameErrors(testCase)
         % An unset name outside the family errors instead of degrading
         % to '', so a typo cannot produce a relative path.
         unsetenv('MATLAB_NO_SUCH_PATH_VAR');
         testCase.verifyError( ...
            @() mgetenv('MATLAB_NO_SUCH_PATH_VAR'), ...
            'matfunclib:manager:mgetenv:unknownVariable');
      end

      function testPathBuildersAbsoluteWhenUnset(testCase)
         % With MATLAB_DIRECTORY_PATH unset, every registry path builder
         % must return an absolute path under the mconfig default. The
         % unguarded getenv versions degraded to bare relative names, so
         % a shutdown save landed in cwd (matfunclib-47r). Each builder
         % self-heals the family, so the variable is unset again before
         % each call to exercise each builder's own fallback.
         dirfolder = fullfile(getenv('HOME'), 'MATLAB', 'directory');

         unsetenv('MATLAB_DIRECTORY_PATH');
         returned = getprjdirectorypath();
         expected = fullfile(dirfolder, 'projectdirectory.mat');
         testCase.verifyEqual(returned, expected);

         unsetenv('MATLAB_DIRECTORY_PATH');
         returned = gettbdirectorypath();
         expected = fullfile(dirfolder, 'toolboxdirectory.csv');
         testCase.verifyEqual(returned, expected);

         unsetenv('MATLAB_DIRECTORY_PATH');
         returned = gettbbackuppath();
         testCase.verifyTrue( ...
            startsWith(returned, fullfile(dirfolder, 'tbd_')));
         testCase.verifyTrue(endsWith(returned, '.mat'));

         unsetenv('MATLAB_DIRECTORY_PATH');
         returned = gettmpdirectorypath();
         testCase.verifyTrue(startsWith(returned, [dirfolder filesep]));
         testCase.verifyTrue(endsWith(returned, '.mat'));
      end

      function testPathBuildersHonorRedirect(testCase)
         % With MATLAB_DIRECTORY_PATH redirected, every builder resolves
         % under the redirect, preserving the fixture-redirect order.
         redirect = fullfile(tempdir, 'mgetenv-builders');
         setenv('MATLAB_DIRECTORY_PATH', redirect);
         testCase.verifyEqual(getprjdirectorypath(), ...
            fullfile(redirect, 'projectdirectory.mat'));
         testCase.verifyEqual(gettbdirectorypath(), ...
            fullfile(redirect, 'toolboxdirectory.csv'));
         testCase.verifyTrue( ...
            startsWith(gettbbackuppath(), fullfile(redirect, 'tbd_')));
         testCase.verifyTrue( ...
            startsWith(gettmpdirectorypath(), [redirect filesep]));
      end
   end
end
