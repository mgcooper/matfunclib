classdef testManagerBoot < matlab.unittest.TestCase
   %TESTMANAGERBOOT Boot-order acceptance for manager (matfunclib-juq.41).
   %
   % manager vendors no matfunclib file. mconfig adds MATLAB_FUNCTION_PATH
   % to the path as its first act, so the matfunclib helpers resolve. These
   % tests prove that in a session that holds manager and MATLAB and
   % nothing else.
   %
   % Each test runs a fresh headless MATLAB, because the check needs
   % restoredefaultpath and a redirected HOME, and neither is safe inside
   % the suite's own session. Each fresh session costs roughly 7 seconds.
   %
   % HOME is the lever. mconfig derives the whole path family from
   % $HOME/MATLAB, so an isolated HOME redirects the registries as well and
   % no test here reads or writes the real ones. The isolated tree reaches
   % the real checkout through a symlink at
   % $HOME/MATLAB/projects/matfunclib.

   properties
      % Absolute path to the matfunclib checkout under test.
      repoRoot string
      % The isolated HOME for one test, removed in teardown.
      fakeHome string
      % Absolute path to the MATLAB executable that runs the child session.
      matlabExe string
   end

   methods (TestClassSetup)
      function resolveRepoAndExecutable(testCase)
         %RESOLVEREPOANDEXECUTABLE Locate the checkout and the MATLAB binary.
         %
         % The parent session gets the repository on its path, as every
         % class suite here does, so anything this file calls resolves
         % without a manual addpath. Each child session calls
         % restoredefaultpath, so the parent's path never reaches it and
         % the isolation these tests need is unaffected.
         import matlab.unittest.fixtures.PathFixture

         % The child sessions are launched through a POSIX shell: an
         % environment-variable prefix, ln -s and rm -f. cmd.exe has none
         % of the three, so the suite does not run on Windows. The
         % behaviour under test is platform-independent; only this
         % harness is not.
         testCase.assumeTrue(isunix, ...
            "testManagerBoot launches its child sessions through a " + ...
            "POSIX shell and does not run on Windows");

         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         testCase.repoRoot = string(fileparts(libraryFolder));
         testCase.applyFixture(PathFixture(testCase.repoRoot, ...
            "IncludingSubfolders", true));

         % matlabroot names the running installation, so the child session
         % is the same release as the parent with no hard-coded path.
         exe = fullfile(matlabroot, "bin", "matlab");
         testCase.assumeTrue(isfile(exe), ...
            "the MATLAB executable must be present to run a child session");
         testCase.matlabExe = string(exe);
      end
   end

   methods (TestMethodSetup)
      function makeIsolatedHome(testCase)
         %MAKEISOLATEDHOME A fresh HOME tree with the folders mconfig derives.
         scratch = string(tempname);

         % Cleanup before the first write, so a mkdir that fails part way
         % still leaves a registered teardown (AGENTS.md).
         testCase.addTeardown(@() testManagerBoot.removeTree(scratch));
         mkdir(fullfile(scratch, "MATLAB", "projects"))
         mkdir(fullfile(scratch, "MATLAB", "directory"))
         mkdir(fullfile(scratch, "MATLAB", "toolboxes"))

         % Record the resolved spelling. tempname returns a path under
         % /var, and macOS resolves that to /private/var. The MATLAB path
         % and pwd hold the resolved form, so a name built from the
         % unresolved form would not match them.
         %
         % An earlier test class can leave a deleted current folder, and
         % the cd back to it would fail. Start from the checkout instead.
         if ~isfolder(pwd)
            cd(testCase.repoRoot)
         end
         here = cd(scratch);
         testCase.fakeHome = string(pwd);
         cd(here)
      end
   end

   methods (Test)

      function testMconfigBootstrapsWithManagerAloneOnThePath(testCase)
         % restoredefaultpath removes matfunclib, then the session adds
         % manager with one literal, the way the startup shim does. No
         % matfunclib helper resolves until mconfig has run, and every one
         % of them resolves afterwards. This is the claim vendoring was
         % rejected in favour of.
         testCase.linkCheckout();

         managerPath = ['fullfile(getenv(''HOME''), ''MATLAB'', ' ...
            '''projects'', ''matfunclib'', ''manager'')'];
         names = ['{''isoneof'', ''islogicalscalar'', ''isscalartext'', ' ...
            '''pathadd'', ''isoctave'', ''optionParser'', ''getlist'', ' ...
            '''withwarnoff''}'];
         script = [ ...
            "restoredefaultpath"; ...
            "addpath(" + managerPath + ")"; ...
            "fprintf('before=%d\n', ~isempty(which('isoneof')));"; ...
            "mconfig();"; ...
            "names = " + names + ";"; ...
            "unresolved = sum(cellfun(@(n) isempty(which(n)), names));"; ...
            "fprintf('after_unresolved=%d\n', unresolved);"];
         out = testCase.runChild(script);

         testCase.verifySubstring(out, "before=0", ...
            "matfunclib must be off the path before mconfig runs")
         testCase.verifySubstring(out, "after_unresolved=0", ...
            "every boot-path helper must resolve after mconfig runs")
      end

      function testWorkonRunsWithMatfunclibAsASibling(testCase)
         % The integrated smoke: boot through mconfig, seed a registry in
         % the isolated tree, then run the calls the acceptance names. The
         % criterion is zero MATLAB:UndefinedFunction errors, which is what
         % the out-of-manager call class would produce if the bootstrap did
         % not resolve it.
         testCase.linkCheckout();
         projectFolder = fullfile(testCase.fakeHome, "MATLAB", ...
            "projects", "smokeproj");
         mkdir(projectFolder)
         writelines("function smokefun(), disp('smoke'), end", ...
            fullfile(projectFolder, "smokefun.m"))

         managerPath = ['fullfile(getenv(''HOME''), ''MATLAB'', ' ...
            '''projects'', ''matfunclib'', ''manager'')'];
         seed = ['writeprjdirectory(table(cellstr(projects), ' ...
            'cellstr(folders), {{}; {}}, [false; true], cellstr(folders), ' ...
            'VariableNames={''name'', ''folder'', ''activefiles'', ' ...
            '''activeproject'', ''activefolder''}));'];
         calls = ['{@() workon(''smokeproj'', ''updatefiles'', false), ' ...
            '@() activate(''matfunclib'', ''asproject'', true), ' ...
            '@() workoff(''smokeproj'', ''updatefiles'', false), ' ...
            '@() mkproject(''smokeproj2'')}'];
         script = [ ...
            "restoredefaultpath"; ...
            "addpath(" + managerPath + ")"; ...
            "mconfig();"; ...
            "projects = [""smokeproj""; ""default""];"; ...
            "folders = fullfile(getenv('MATLAB_PROJECT_PATH'), projects);"; ...
            seed; ...
            "names = {'workon', 'activate', 'workoff', 'mkproject'};"; ...
            "calls = " + calls + ";"; ...
            "undefined = 0;"; ...
            "for k = 1:numel(calls)"; ...
            "   try"; ...
            "      calls{k}();"; ...
            "      fprintf('%s=ok\n', names{k});"; ...
            "   catch ME"; ...
            "      fprintf('%s=failed:%s\n', names{k}, ME.identifier);"; ...
            "      undefined = undefined + ..."; ...
            "         strcmp(ME.identifier, 'MATLAB:UndefinedFunction');"; ...
            "   end"; ...
            "end"; ...
            "fprintf('undefined=%d\n', undefined);"];
         out = testCase.runChild(script);

         % The criterion. Every helper the four calls reach resolved.
         testCase.verifySubstring(out, "undefined=0", ...
            "no call may raise MATLAB:UndefinedFunction after the bootstrap")

         % The two calls the seeded registry supports must also succeed,
         % so a call that fails with no undefined function cannot pass
         % the criterion above.
         testCase.verifySubstring(out, "workon=ok", "workon must succeed")
         testCase.verifySubstring(out, "workoff=ok", "workoff must succeed")

         % activate and mkproject are not asserted to succeed here, and
         % both are still called, because the criterion is that every
         % helper they reach resolves. activate reads the toolbox
         % registry, which this fixture does not seed, and mkproject
         % rebuilds the project registry from the filesystem, which needs
         % columns the fixture does not carry. Neither raises an undefined
         % function. matfunclib-juq.63 records the registry-schema gap that
         % keeps a minimal fixture from satisfying either.
      end
   end

   methods (Access = private)
      function linkCheckout(testCase)
         %LINKCHECKOUT Point the isolated HOME at the real checkout.
         %
         % A symlink, not a copy: the child session must exercise the
         % working tree under test, and copying 1,500 files per test would
         % dominate the run.
         link = fullfile(testCase.fakeHome, "MATLAB", "projects", ...
            "matfunclib");
         command = "ln -s " + testManagerBoot.shellQuote(testCase.repoRoot) ...
            + " " + testManagerBoot.shellQuote(link);
         [status, msg] = system(command);
         testCase.assertEqual(status, 0, "symlink failed: " + string(msg))
      end

      function out = runChild(testCase, scriptLines)
         %RUNCHILD Run SCRIPTLINES in a fresh headless MATLAB, return stdout.
         %
         % The child gets the isolated HOME, so mconfig derives its whole
         % path family there and never reads the caller's registries.
         % Every child ends by printing this marker, so a session that
         % died part way is visible whether or not its status is checked.
         scriptFile = fullfile(testCase.fakeHome, "child.m");
         writelines([scriptLines(:); "fprintf('child_done\n');"], scriptFile)

         command = "HOME=" ...
            + testManagerBoot.shellQuote(testCase.fakeHome) + " " ...
            + testManagerBoot.shellQuote(testCase.matlabExe) ...
            + " -nodisplay -nosplash -batch " ...
            + testManagerBoot.shellQuote("run(" ...
            + testManagerBoot.matlabLiteral(scriptFile) + ")");
         [status, out] = system(command);
         out = string(out);

         % A child that prints every expected marker and then exits
         % nonzero has still failed, and the substring checks alone would
         % not see it.
         testCase.assertEqual(status, 0, ...
            "the child MATLAB exited " + status + ": " + out)
         testCase.assertSubstring(out, "child_done", ...
            "the child MATLAB did not reach the end of its script: " + out)
      end
   end

   methods (Static, Access = private)
      function quoted = shellQuote(text)
         %SHELLQUOTE Wrap TEXT in single quotes for a POSIX shell.
         %
         % Single quotes, not double: the checkout path is whatever the
         % user cloned into, and a double-quoted "$", backtick or
         % backslash would be expanded by the shell. A single quote inside
         % the text ends the quoting, so each one is closed, escaped and
         % reopened, which is the POSIX-safe form.
         quoted = "'" + replace(string(text), "'", "'\''") + "'";
      end

      function literal = matlabLiteral(text)
         %MATLABLITERAL TEXT as a single-quoted MATLAB character literal.
         %
         % Shell quoting cannot repair a MATLAB character literal, so an
         % apostrophe in the checkout path is doubled here before the
         % child script is composed.
         literal = "'" + replace(string(text), "'", "''") + "'";
      end

      function removeTree(folder)
         %REMOVETREE Remove the isolated HOME, symlink first.
         %
         % rmdir follows a directory symlink on some platforms, so the link
         % must be gone before the tree is removed. rm -f removes the link
         % itself and never the checkout behind it. A failed unlink stops
         % the teardown: one temp tree left behind is recoverable, and a
         % deleted checkout is not.
         link = fullfile(folder, "MATLAB", "projects", "matfunclib");
         if isfolder(link) || isfile(link)
            status = system("rm -f " + testManagerBoot.shellQuote(link));
            if status ~= 0 || isfolder(link) || isfile(link)
               warning('testManagerBoot:unlinkFailed', ...
                  ['could not remove the checkout symlink at %s, so %s ' ...
                  'is left in place rather than removed'], link, folder);
               return
            end
         end
         if isfolder(folder)
            rmdir(folder, 's')
         end
      end
   end
end
