classdef testWithcd < matlab.unittest.TestCase
   %TESTWITHCD Unit tests for the scoped current-folder guard (juq.58.1).
   %
   % withcd is the one current-folder guard in matfunclib. These tests
   % cover its input validation, which the arguments block carries under
   % MATLAB and inputParser repeats under Octave, and its restore, which
   % gives up when it cannot enter the start folder.
   %
   % The Octave test runs a child octave-cli and skips when the machine has
   % none.

   properties
      % Every test changes the working folder, so each one saves it and
      % teardown puts it back even after a failure.
      savedDir char = ''
      % Absolute path to the matfunclib checkout under test.
      repoRoot string
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so withcd resolves from the repo
         % root without a manual addpath.
         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.repoRoot = string(projectFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (TestMethodSetup)
      function saveWorkingFolder(testCase)
         testCase.savedDir = pwd;
         testCase.addTeardown(@() cd(testCase.savedDir));
      end
   end

   methods (Test)

      function testEntersAndRestores(testCase)
         % The guard makes the named folder current, and deleting the
         % cleanup object puts the caller's folder back.
         start = pwd;
         target = testCase.makeFolder();

         guard = withcd(target);
         returned = testCase.canonical(pwd);
         expected = testCase.canonical(target);
         testCase.verifyEqual(returned, expected)

         delete(guard)
         returned = pwd;
         expected = start;
         testCase.verifyEqual(returned, expected)
      end

      function testRestoresAfterAnError(testCase)
         % The cleanup runs when the caller's frame unwinds, so an error
         % inside the guarded block still leaves the caller where it was.
         start = pwd;
         target = testCase.makeFolder();

         testCase.verifyError(@() errorUnderGuard(target), ...
            'testWithcd:deliberate')

         returned = pwd;
         expected = start;
         testCase.verifyEqual(returned, expected)
      end

      function testNoOutputStillRestoresOnReturn(testCase)
         % Called with no output, the cleanup object is temporary and
         % dies when withcd returns, so the folder never changes for the
         % caller. This is the documented nargout==0 behavior.
         start = pwd;
         target = testCase.makeFolder();

         withcd(target);

         returned = pwd;
         expected = start;
         testCase.verifyEqual(returned, expected)
      end

      function testMissingStartFolderDoesNotRaise(testCase)
         % The start folder can be gone by the time the cleanup runs: a
         % test fixture removed, a checkout deleted. cd to a missing
         % folder raises, and an error from an onCleanup destructor is
         % not catchable at the call site, so the restore skips it.
         start = testCase.makeFolder();
         target = testCase.makeFolder();
         cd(start)

         guard = withcd(target);
         rmdir(start, 's')

         % Deleting the guard runs the restore. It must not raise.
         testCase.verifyWarningFree(@() delete(guard))
      end

      function testRejectsAMissingFolder(testCase)
         % mustBeFolder in the arguments block rejects it. tempname
         % reserves an unused path and does not create it, so no earlier
         % run can have left this folder behind. Under Octave the block is
         % skipped and inputParser raises instead; see
         % testOctaveValidatesAndRestores.
         testCase.verifyError(@() withcd(tempname), ...
            'MATLAB:validators:mustBeFolder')
      end

      function testRejectsANonTextInput(testCase)
         % The arguments block rejects both: a number converts to a
         % string that names no folder, and a 1-by-2 string fails the
         % declared size.
         testCase.verifyError(@() withcd(42), ...
            'MATLAB:validators:mustBeFolder')
         testCase.verifyError(@() withcd(["a", "b"]), ...
            'MATLAB:validation:IncompatibleSize')
      end

      function testAcceptsAScalarCellOfText(testCase)
         % An arguments block declaring (1, 1) string converted a 1-by-1
         % cell holding text before any validator ran, so a caller could
         % pass {folder}. That form still works.
         target = testCase.makeFolder();

         guard = withcd({char(target)});
         returned = testCase.canonical(pwd);
         expected = testCase.canonical(target);
         testCase.verifyEqual(returned, expected)
         delete(guard)

         guard = withcd({string(target)});
         returned = testCase.canonical(pwd);
         testCase.verifyEqual(returned, expected)
         delete(guard)
      end

      function testRejectsEmptyText(testCase)
         % mustBeFolder tests for non-empty text first, so empty text is
         % rejected by that check rather than by the folder test.
         testCase.verifyError(@() withcd(''), ...
            'MATLAB:validators:mustBeNonzeroLengthText')
         testCase.verifyError(@() withcd(""), ...
            'MATLAB:validators:mustBeNonzeroLengthText')
      end

      function testRejectsNoInput(testCase)
         % The arguments block carries the arity check.
         testCase.verifyError(@() withcd(), ...
            'MATLAB:minrhs')
      end

      function testAcceptsCharAndString(testCase)
         % Both text types are accepted.
         target = testCase.makeFolder();

         guard = withcd(char(target));
         returned = testCase.canonical(pwd);
         expected = testCase.canonical(target);
         testCase.verifyEqual(returned, expected)
         delete(guard)

         guard = withcd(string(target));
         returned = testCase.canonical(pwd);
         testCase.verifyEqual(returned, expected)
         delete(guard)
      end

      function testOctaveValidatesAndRestores(testCase)
         % Octave skips the arguments block, so inputParser must reject a
         % missing folder and a number, including 47, which char would turn
         % into the root folder '/'. A valid folder must still be entered
         % and restored when the guard is cleared. A string object from the
         % datatypes package must be accepted.
         [status, out] = system("command -v octave-cli");
         exe = strtrim(string(out));
         testCase.assumeTrue(status == 0 && strlength(exe) > 0, ...
            "octave-cli is not installed, so the Octave branch of withcd " + ...
            "cannot run here");

         target = testCase.canonical(testCase.makeFolder());
         script = [ ...
            "start = pwd;"; ...
            "for bad = {'/no/such/folder', 42, 47}"; ...
            "  try"; ...
            "    withcd(bad{1});"; ...
            "    printf('rejected=no\n');"; ...
            "  catch e"; ...
            "    printf('rejected=%d\n', ..."; ...
            "      ~isempty(strfind(e.message, 'failed validation')));"; ...
            "  end"; ...
            "end"; ...
            "guard = withcd('" + target + "');"; ...
            "printf('entered=%d\n', strcmp(pwd, '" + target + "'));"; ...
            "clear guard"; ...
            "printf('restored=%d\n', strcmp(pwd, start));"; ...
            "if isempty(pkg('list', 'datatypes'))"; ...
            "  printf('string=nopkg\n');"; ...
            "else"; ...
            "  pkg load datatypes"; ...
            "  guard = withcd(string('" + target + "'));"; ...
            "  printf('string=%d\n', strcmp(pwd, '" + target + "'));"; ...
            "  clear guard"; ...
            "end"; ...
            "printf('child_done\n');"];
         scriptFile = fullfile(target, "child.m");
         writelines(script, scriptFile)

         % The child gets libsys and liboctave, which hold withcd and
         % isoctave. Warnings are off because Octave reports every
         % arguments block it parses, and these checks do not read them.
         adds = "addpath('" + fullfile(testCase.repoRoot, "libsys") ...
            + "'); addpath('" + fullfile(testCase.repoRoot, "liboctave") ...
            + "'); ";
         command = """" + exe + """ --norc --eval """ + adds ...
            + "warning('off', 'all'); source('" + scriptFile + "')""";
         [status, out] = system(command);
         out = string(out);

         % A child that failed after printing a marker has still failed.
         testCase.assertEqual(status, 0, ...
            "octave-cli exited " + status + ": " + out)
         testCase.assertSubstring(out, "child_done", out)
         testCase.verifyEqual(count(out, "rejected=1"), 3, ...
            "inputParser must reject a missing folder and two numbers, " + ...
            "one of which char converts to '/': " + out)
         testCase.verifySubstring(out, "entered=1", out)
         testCase.verifySubstring(out, "restored=1", out)

         % A string object needs the datatypes package. Where it is
         % installed, withcd must accept one, as MATLAB does.
         if ~contains(out, "string=nopkg")
            testCase.verifySubstring(out, "string=1", out)
         end
      end
   end

   methods (Access = private)
      function folder = makeFolder(testCase)
         %MAKEFOLDER A fresh scratch folder, removed after the test.
         %
         % tempname reserves an unused name, so two calls in one test
         % cannot collide. Teardown removes it unless the test already
         % did, which testMissingStartFolderDoesNotRaise does.
         folder = tempname;
         testCase.addTeardown(@() testWithcd.removeIfPresent(folder));
         mkdir(folder)
      end

      function path = canonical(~, path)
         %CANONICAL Resolve an alias so a comparison with pwd holds.
         %
         % tempname returns a path under "/var" on macOS, and pwd reports
         % its "/private/var" target, so the two spellings differ for the
         % same folder.
         here = pwd;
         cleanup = onCleanup(@() cd(here));
         cd(path)
         path = pwd;
         clear cleanup
      end
   end

   methods (Static, Access = private)
      function removeIfPresent(folder)
         %REMOVEIFPRESENT Remove a scratch folder a test may have removed.
         %
         % Teardowns run last-registered-first, so this one runs before the
         % method setup restores the working folder. A test that ends
         % inside the folder would otherwise ask the platform to delete the
         % current directory, which some refuse. Leave it first.
         if ~isfolder(folder)
            return
         end
         % Compare resolved spellings: on macOS tempname returns a
         % "/var/..." path while the shell reports its "/private/var/..."
         % target, so a raw comparison can miss the current folder. Enter
         % the folder to read the spelling the file system reports, then
         % compare whole path components.
         here = pwd;
         restore = onCleanup(@() cd(here));
         cd(folder);
         canonicalFolder = pwd;
         clear restore
         canonicalHere = pwd;
         inside = strcmp(canonicalHere, canonicalFolder) || ...
            strncmp(canonicalHere, [canonicalFolder filesep], ...
            numel(canonicalFolder) + 1);
         if inside
            cd(tempdir)
         end
         rmdir(folder, 's')
      end
   end
end

function errorUnderGuard(target)
   %ERRORUNDERGUARD Raise inside a guarded block, so the cleanup unwinds it.
   %
   % The guard stays in scope when the error is raised. MATLAB destroys it
   % as the frame unwinds, which is the restore path under test. The
   % isvalid test reads the variable, so the guard is not an unused
   % assignment, and it documents that the guard is live at the raise.
   guard = withcd(target);
   assert(isvalid(guard), 'testWithcd:guardNotLive', 'guard must be live')
   error('testWithcd:deliberate', 'deliberate failure inside the guard')
end
