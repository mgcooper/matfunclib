classdef testConfigureproject < matlab.unittest.TestCase
   %TESTCONFIGUREPROJECT Unit tests for configureproject (matfunclib-juq.38).
   %
   % configureproject runs a project's Config/Setup/Install/Startup script.
   % Audit HIGH #2: an outer catch that turns a real error inside the
   % script into a successful activation. These tests drive fixture
   % projects under a temp folder. They also redirect the registry
   % environment (the testRegistrySafety pattern), so no test touches the
   % real registries in $HOME/MATLAB/directory. configureproject itself
   % reads no registry.

   properties
      regDir string
      % The struct() default matters: a bare typed struct property
      % initializes 0x0, and dot assignment into an empty struct errors.
      savedEnv struct = struct()
   end

   properties (Constant)
      % Env vars every test saves, redirects and restores.
      envNames = ["MATLAB_DIRECTORY_PATH", "MATLAB_PROJECT_PATH"]
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

         for name = testCase.envNames
            testCase.savedEnv.(matlab.lang.makeValidName(name)) = getenv(name);
         end
         testCase.addTeardown(@() testCase.restoreEnv())

         % Other manager test classes leave the current folder inside a
         % fixture that their teardown then deletes. run (used for
         % userhooks/ scripts) restores the current folder when it
         % finishes and errors when that folder is gone. So the setup
         % moves to the repo root before it creates the fixture, and a
         % teardown restores the folder after the fixture is removed
         % (teardowns run last-in first-out).
         if ~isfolder(pwd)
            cd(fileparts(fileparts(fileparts(mfilename("fullpath")))))
         end
         startFolder = pwd;
         testCase.addTeardown(@() cd(startFolder))

         tmp = testCase.applyFixture(TemporaryFolderFixture);
         testCase.regDir = string(tmp.Folder);
         setenv('MATLAB_DIRECTORY_PATH', testCase.regDir);
         setenv('MATLAB_PROJECT_PATH', testCase.regDir);
      end
   end

   methods (Access = private)
      function restoreEnv(testCase)
         for name = testCase.envNames
            setenv(name, testCase.savedEnv.(matlab.lang.makeValidName(name)));
         end
      end

      function projectpath = fixtureProject(testCase, configLines)
         %FIXTUREPROJECT A project folder holding the given Config.m lines.
         %
         % This helper does not add the folder to the path: configureproject
         % makes the project folder current, and the current folder
         % resolves the script's bare name ahead of the path.
         projectpath = char(fullfile(testCase.regDir, "fixproj"));
         mkdir(projectpath)
         if ~isempty(configLines)
            writelines(configLines, fullfile(projectpath, "Config.m"))
         end
      end
   end

   methods (Test)
      function testRealErrorIsWarnedAndOkIsFalse(testCase)
         % A Config.m that raises a real error yields a warning with that
         % error's own identifier and ok == false.
         projectpath = testCase.fixtureProject([ ...
            "function Config(varargin)"; ...
            "error('fixture:configBoom', 'the configuration is broken')"; ...
            "end"]);

         returned = testCase.verifyWarning( ...
            @() configureproject(projectpath), 'fixture:configBoom');
         expected = false;
         testCase.verifyEqual(returned, expected)
      end

      function testUndefinedHelperInsideScriptIsARealError(testCase)
         % An undefined name raised from inside the script is the script's
         % error, not an absent script: configureproject warns with
         % MATLAB:UndefinedFunction and ok is false.
         projectpath = testCase.fixtureProject([ ...
            "function Config(varargin)"; ...
            "cp_test_no_such_helper_xyz()"; ...
            "end"]);

         returned = testCase.verifyWarning( ...
            @() configureproject(projectpath), 'MATLAB:UndefinedFunction');
         expected = false;
         testCase.verifyEqual(returned, expected)
      end

      function testAbsentScriptSkipsQuietly(testCase)
         % A project with no script is skipped: no warning, and ok stays
         % false because nothing ran.
         projectpath = testCase.fixtureProject(string.empty);

         returned = testCase.verifyWarningFree( ...
            @() configureproject(projectpath));
         expected = false;
         testCase.verifyEqual(returned, expected)
      end

      function testScriptWithoutInputsRunsThroughTheRetry(testCase)
         % A function that accepts no inputs takes the TooManyInputs retry
         % and, when it succeeds, reports ok == true with no warning.
         projectpath = testCase.fixtureProject([ ...
            "function Config()"; ...
            "setenv('CP_TEST_RAN', 'yes')"; ...
            "end"]);
         testCase.addTeardown(@() setenv('CP_TEST_RAN', ''))

         returned = testCase.verifyWarningFree( ...
            @() configureproject(projectpath));
         expected = true;
         testCase.verifyEqual(returned, expected)
         returned = getenv('CP_TEST_RAN');
         expected = 'yes';
         testCase.verifyEqual(returned, expected)
      end

      function testRetryFailureIsSurfaced(testCase)
         % A no-input function whose body raises fails inside the retry.
         % configureproject warns with that error's identifier and ok is
         % false.
         projectpath = testCase.fixtureProject([ ...
            "function Config()"; ...
            "error('fixture:retryBoom', 'broken in the retry')"; ...
            "end"]);

         returned = testCase.verifyWarning( ...
            @() configureproject(projectpath), 'fixture:retryBoom');
         expected = false;
         testCase.verifyEqual(returned, expected)
      end

      function testTooManyInputsInsideScriptIsNotRetried(testCase)
         % A varargin function whose body calls a helper with too many
         % inputs raises MATLAB:TooManyInputs from inside the script. That
         % is the script's error: configureproject warns, ok is false, and
         % the script does not run a second time (the marker counts one
         % run).
         projectpath = testCase.fixtureProject([ ...
            "function Config(varargin)"; ...
            "runs = str2double(getenv('CP_TEST_RUNS')) + 1;"; ...
            "setenv('CP_TEST_RUNS', num2str(runs))"; ...
            "cp_test_noinput_helper(1)"; ...
            "end"]);
         writelines(["function cp_test_noinput_helper()"; "end"], ...
            fullfile(projectpath, "cp_test_noinput_helper.m"))
         setenv('CP_TEST_RUNS', '0')
         testCase.addTeardown(@() setenv('CP_TEST_RUNS', ''))

         returned = testCase.verifyWarning( ...
            @() configureproject(projectpath), 'MATLAB:TooManyInputs');
         expected = false;
         testCase.verifyEqual(returned, expected)
         returned = getenv('CP_TEST_RUNS');
         expected = '1';
         testCase.verifyEqual(returned, expected)
      end

      function testUndefinedCaseVariantInsideScriptIsARealError(testCase)
         % An UndefinedFunction error raised inside Config whose message
         % quotes a name spelled like the script ('config') is not the
         % absent-script skip: the error carries the script's frame, so
         % configureproject warns and ok is false. The fixture raises the
         % error directly so the test does not depend on what 'config'
         % resolves to on the path.
         projectpath = testCase.fixtureProject([ ...
            "function Config(varargin)"; ...
            "error('MATLAB:UndefinedFunction', ..."; ...
            "   'Unrecognized function or variable ''config''.')"; ...
            "end"]);

         returned = testCase.verifyWarning( ...
            @() configureproject(projectpath), 'MATLAB:UndefinedFunction');
         expected = false;
         testCase.verifyEqual(returned, expected)
      end

      function testScriptVariablesCannotAlterTheResult(testCase)
         % A plain script (not a function) runs in a helper workspace, so
         % its own ran and failed variables do not change ok. A later
         % script that raises is still reported. Config.m is the script
         % and Setup.m raises, in the order the loop tries them.
         projectpath = testCase.fixtureProject([ ...
            "failed = false;"; ...
            "ran = false;"; ...
            "setenv('CP_TEST_RAN', 'script')"]);
         writelines(["function Setup(varargin)"; ...
            "error('fixture:setupBoom', 'setup is broken')"; "end"], ...
            fullfile(projectpath, "Setup.m"))
         testCase.addTeardown(@() setenv('CP_TEST_RAN', ''))

         returned = testCase.verifyWarning( ...
            @() configureproject(projectpath), 'fixture:setupBoom');
         expected = false;
         testCase.verifyEqual(returned, expected)
         returned = getenv('CP_TEST_RAN');
         expected = 'script';
         testCase.verifyEqual(returned, expected)
      end

      function testFailingUserHookIsReported(testCase)
         % A userhooks/ script that raises produces a warning with its
         % identifier and makes ok false even though Config.m succeeded.
         projectpath = testCase.fixtureProject([ ...
            "function Config(varargin)"; ...
            "end"]);
         mkdir(fullfile(projectpath, "userhooks"))
         writelines("error('fixture:hookBoom', 'the hook is broken')", ...
            fullfile(projectpath, "userhooks", "hook.m"))

         returned = testCase.verifyWarning( ...
            @() configureproject(projectpath), 'fixture:hookBoom');
         expected = false;
         testCase.verifyEqual(returned, expected)
      end

      function testUserHookAloneCountsAsRan(testCase)
         % A project with only a userhooks/ script reports ok when the
         % hook completes.
         projectpath = testCase.fixtureProject(string.empty);
         mkdir(fullfile(projectpath, "userhooks"))
         writelines("setenv('CP_TEST_RAN', 'hook')", ...
            fullfile(projectpath, "userhooks", "hook.m"))
         testCase.addTeardown(@() setenv('CP_TEST_RAN', ''))

         returned = testCase.verifyWarningFree( ...
            @() configureproject(projectpath));
         expected = true;
         testCase.verifyEqual(returned, expected)
      end

      function testRelativeProjectPathClassifiesByFrame(testCase)
         % A relative project path (and one spelled with "..") still finds
         % the script's frame in the error stack: an undefined name inside
         % Config produces a warning, not a skip, and ok is false.
         projectpath = testCase.fixtureProject([ ...
            "function Config(varargin)"; ...
            "cp_test_no_such_helper_xyz()"; ...
            "end"]);
         cd(testCase.regDir)

         returned = testCase.verifyWarning( ...
            @() configureproject('fixproj'), 'MATLAB:UndefinedFunction');
         expected = false;
         testCase.verifyEqual(returned, expected)

         dotted = fullfile('fixproj', '..', 'fixproj');
         returned = testCase.verifyWarning( ...
            @() configureproject(dotted), 'MATLAB:UndefinedFunction');
         testCase.verifyEqual(returned, expected)
         returned = isfolder(projectpath);
         expected = true;
         testCase.verifyEqual(returned, expected)

         % The caller's folder is restored after each call.
         returned = string(pwd);
         expected = testCase.regDir;
         testCase.verifyEqual(returned, expected)
      end

      function testPlainErrorMessageUsesTheFallbackIdentifier(testCase)
         % A script that raises error('message') has no identifier. The
         % warning then carries configureproject's own identifier, and ok
         % is false.
         projectpath = testCase.fixtureProject([ ...
            "function Config(varargin)"; ...
            "error('the configuration is broken, no identifier')"; ...
            "end"]);

         returned = testCase.verifyWarning( ...
            @() configureproject(projectpath), ...
            'matfunclib:configureproject:scriptFailed');
         expected = false;
         testCase.verifyEqual(returned, expected)
      end

      function testProjectScriptWinsOverSameNameOnPath(testCase)
         % A Config.m earlier on the path (a decoy) must not be the one
         % that runs: the project folder is current, so MATLAB resolves
         % the project's own Config.m first, as a script and as a function.
         % The temp project path is longer than namelengthmax, the case a
         % bare-name fallback gets wrong.
         decoy = fullfile(testCase.regDir, "decoy");
         mkdir(decoy)
         writelines("setenv('CP_TEST_RAN', 'decoy')", ...
            fullfile(decoy, "Config.m"))
         addpath(decoy, '-begin')
         testCase.addTeardown(@() rmpath(decoy))
         testCase.addTeardown(@() setenv('CP_TEST_RAN', ''))

         projectpath = testCase.fixtureProject( ...
            "setenv('CP_TEST_RAN', 'project script')");
         returned = testCase.verifyWarningFree( ...
            @() configureproject(projectpath));
         expected = true;
         testCase.verifyEqual(returned, expected)
         returned = getenv('CP_TEST_RAN');
         expected = 'project script';
         testCase.verifyEqual(returned, expected)

         writelines(["function Config(varargin)"; ...
            "setenv('CP_TEST_RAN', 'project function')"; "end"], ...
            fullfile(projectpath, "Config.m"))
         returned = testCase.verifyWarningFree( ...
            @() configureproject(projectpath));
         expected = true;
         testCase.verifyEqual(returned, expected)
         returned = getenv('CP_TEST_RAN');
         expected = 'project function';
         testCase.verifyEqual(returned, expected)
      end

      function testScriptThatChangesFolderDoesNotRedirectTheNext(testCase)
         % Config.m changes the current folder into a decoy folder that
         % holds its own Setup.m and a fullfile.m that errors. The
         % project's Setup.m must still be the one that runs, and the
         % decoy's fullfile must never run. configureproject enters the
         % project folder again before each candidate and each call.
         decoy = fullfile(testCase.regDir, "decoy");
         mkdir(decoy)
         writelines(["function Setup(varargin)"; ...
            "setenv('CP_TEST_RAN', 'decoy setup')"; "end"], ...
            fullfile(decoy, "Setup.m"))
         writelines(["function varargout = fullfile(varargin)"; ...
            "error('shadow:hit', 'decoy fullfile was called')"; "end"], ...
            fullfile(decoy, "fullfile.m"))
         testCase.addTeardown(@() setenv('CP_TEST_RAN', ''))
         conflict = warning('off', 'MATLAB:dispatcher:nameConflict');
         testCase.addTeardown(@() warning(conflict))

         projectpath = testCase.fixtureProject([ ...
            "function Config(varargin)"; ...
            "cd('" + string(decoy) + "')"; ...
            "end"]);
         writelines(["function Setup(varargin)"; ...
            "setenv('CP_TEST_RAN', 'project setup')"; "end"], ...
            fullfile(projectpath, "Setup.m"))

         returned = testCase.verifyWarningFree( ...
            @() configureproject(projectpath));
         expected = true;
         testCase.verifyEqual(returned, expected)
         returned = getenv('CP_TEST_RAN');
         expected = 'project setup';
         testCase.verifyEqual(returned, expected)
      end

      function testScriptCreatedByAnEarlierOneRuns(testCase)
         % Config.m writes Setup.m. configureproject lists the folder per
         % candidate, so the new Setup.m runs in the same call.
         projectpath = testCase.fixtureProject([ ...
            "function Config(varargin)"; ...
            "writelines([""function Setup(varargin)""; ..."; ...
            "   ""setenv('CP_TEST_RAN', 'generated setup')""; ""end""], ..."; ...
            "   fullfile(pwd, 'Setup.m'))"; ...
            "end"]);
         testCase.addTeardown(@() setenv('CP_TEST_RAN', ''))

         returned = testCase.verifyWarningFree( ...
            @() configureproject(projectpath));
         expected = true;
         testCase.verifyEqual(returned, expected)
         returned = getenv('CP_TEST_RAN');
         expected = 'generated setup';
         testCase.verifyEqual(returned, expected)
      end

      function testFolderNamedLikeAScriptIsNotOne(testCase)
         % A folder called Config.m is not a script: nothing runs, no
         % warning, and ok is false.
         projectpath = testCase.fixtureProject(string.empty);
         mkdir(fullfile(projectpath, "Config.m"))

         returned = testCase.verifyWarningFree( ...
            @() configureproject(projectpath));
         expected = false;
         testCase.verifyEqual(returned, expected)
      end

      function testFolderInUserhooksIsNotAHook(testCase)
         % A folder called archive.m inside userhooks/ is not a hook: the
         % real hook runs, no warning, ok is true.
         projectpath = testCase.fixtureProject(string.empty);
         mkdir(fullfile(projectpath, "userhooks", "archive.m"))
         writelines("setenv('CP_TEST_RAN', 'hook beside folder')", ...
            fullfile(projectpath, "userhooks", "hook.m"))
         testCase.addTeardown(@() setenv('CP_TEST_RAN', ''))

         returned = testCase.verifyWarningFree( ...
            @() configureproject(projectpath));
         expected = true;
         testCase.verifyEqual(returned, expected)
         returned = getenv('CP_TEST_RAN');
         expected = 'hook beside folder';
         testCase.verifyEqual(returned, expected)
      end

      function testHookCreatedOrRemovedByAnEarlierHookIsHonored(testCase)
         % The first hook (by name) writes a later hook and deletes
         % another. The written hook runs, the deleted one is not reported,
         % and ok is true.
         projectpath = testCase.fixtureProject(string.empty);
         hooks = fullfile(projectpath, "userhooks");
         mkdir(hooks)
         writelines([ ...
            "writelines(""setenv('CP_TEST_RAN', 'generated hook')"", ..."; ...
            "   fullfile(pwd, 'z_generated.m'))"; ...
            "delete(fullfile(pwd, 'm_doomed.m'))"], ...
            fullfile(hooks, "a_first.m"))
         writelines("setenv('CP_TEST_RAN', 'doomed')", ...
            fullfile(hooks, "m_doomed.m"))
         testCase.addTeardown(@() setenv('CP_TEST_RAN', ''))

         returned = testCase.verifyWarningFree( ...
            @() configureproject(projectpath));
         expected = true;
         testCase.verifyEqual(returned, expected)
         returned = getenv('CP_TEST_RAN');
         expected = 'generated hook';
         testCase.verifyEqual(returned, expected)
      end

      function testWildcardInProjectNameDoesNotListASibling(testCase)
         % A project folder whose name holds '*' must not have a sibling's
         % Config.m attributed to it: nothing runs, no warning, ok false.
         sibling = fullfile(testCase.regDir, "fixaproj");
         mkdir(sibling)
         writelines(["function Config(varargin)"; ...
            "setenv('CP_TEST_RAN', 'sibling')"; "end"], ...
            fullfile(sibling, "Config.m"))
         % Windows forbids '*' in a folder name, so the scenario cannot
         % occur there and the test has nothing to check.
         if ispc
            return
         end
         projectpath = char(fullfile(testCase.regDir, "fix*proj"));
         mkdir(projectpath)
         testCase.addTeardown(@() setenv('CP_TEST_RAN', ''))

         returned = testCase.verifyWarningFree( ...
            @() configureproject(projectpath));
         expected = false;
         testCase.verifyEqual(returned, expected)
         returned = getenv('CP_TEST_RAN');
         expected = '';
         testCase.verifyEqual(returned, expected)
      end

      function testHelperNameIsRefused(testCase)
         % configureproject refuses a script name equal to an internal
         % helper before anything runs, even when the project holds such a
         % file.
         projectpath = testCase.fixtureProject(string.empty);
         writelines("setenv('CP_TEST_RAN', 'should not run')", ...
            fullfile(projectpath, "runscript.m"))
         testCase.addTeardown(@() setenv('CP_TEST_RAN', ''))

         testCase.verifyError(@() configureproject(projectpath, 'runscript'), ...
            'matfunclib:configureproject:reservedName')
         testCase.verifyError(@() configureproject(projectpath, 'entrykind'), ...
            'matfunclib:configureproject:reservedName')
         returned = getenv('CP_TEST_RAN');
         expected = '';
         testCase.verifyEqual(returned, expected)

         % The function's own name is reserved as well: feval would
         % recurse into it instead of running a project file of that name.
         testCase.verifyError( ...
            @() configureproject(projectpath, 'configureproject'), ...
            'matfunclib:configureproject:reservedName')
      end

      function testMissingProjectFolderRaisesAndKeepsTheFolder(testCase)
         % A project folder that does not exist is an error from withcd.
         % workon checks the folder before it calls configureproject, so
         % this function does not repeat the check. The caller's folder is
         % untouched.
         projectpath = char(fullfile(testCase.regDir, "gone"));
         cd(testCase.regDir)

         testCase.verifyError(@() configureproject(projectpath), ...
            'MATLAB:validators:mustBeFolder')
         returned = string(pwd);
         expected = testCase.regDir;
         testCase.verifyEqual(returned, expected)
      end

      function testLowerCaseScriptNameRunsOnce(testCase)
         % The loop tries each name and its lower-case form. A name that is
         % already lower case, such as configfile in the default list, must
         % not run twice.
         projectpath = testCase.fixtureProject([]);
         writelines([ ...
            "function configfile(varargin)"; ...
            "setenv('CP_TEST_RAN', [getenv('CP_TEST_RAN') 'x'])"; ...
            "end"], fullfile(projectpath, "configfile.m"))
         setenv('CP_TEST_RAN', '')
         testCase.addTeardown(@() setenv('CP_TEST_RAN', ''))

         testCase.verifyTrue(configureproject(projectpath))
         returned = getenv('CP_TEST_RAN');
         expected = 'x';
         testCase.verifyEqual(returned, expected)
      end

      function testSucceedingScriptReportsOk(testCase)
         % The normal case: a varargin function that completes gives ok ==
         % true.
         projectpath = testCase.fixtureProject([ ...
            "function Config(varargin)"; ...
            "setenv('CP_TEST_RAN', 'ok')"; ...
            "end"]);
         testCase.addTeardown(@() setenv('CP_TEST_RAN', ''))

         returned = configureproject(projectpath);
         expected = true;
         testCase.verifyEqual(returned, expected)
      end
   end
end
