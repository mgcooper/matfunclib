classdef testInstallRequiredFiles < matlab.unittest.TestCase
   %TESTINSTALLREQUIREDFILES Unit tests for functools/installRequiredFiles.
   %
   % Runs offline. The remote-mode cases use dryrun=true, which resolves
   % and prints the install plan without downloading anything. The
   % local-mode cases copy from a scratch source tree.
   % testRemoteInstallLandsThroughTheStagingFile is the same offline dry
   % run unless the environment variable MATFUNCLIB_LIVE_TESTS is set.
   % Then it does a real download from GitHub and fails, not skips, if
   % GitHub is unreachable.

   properties
      % Canonical fixture paths, resolved via which() so they match the
      % canonical paths matlab.codetools.requiredFilesAndProducts reports
      % (avoids the macOS /var vs /private/var tempdir alias mismatch).
      localSource string
      projFolder string
      dep1 string
      dep2 string

      % Per-call installer inputs, carried as properties so the evalc
      % capture references only testCase; local variables mentioned solely
      % inside evalc strings look unused to the code analyzer.
      positionalList string = string.empty
      extraArgs cell = {}
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so installRequiredFiles and the
         % library functions it calls by name (withcd from libsys,
         % undersource, foldscase and getRequiredFiles from functools)
         % resolve from the repo root.
         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end

      function buildFixtureTree(testCase)
         import matlab.unittest.fixtures.TemporaryFolderFixture
         import matlab.unittest.fixtures.PathFixture

         % A fake "local source" tree (stands in for matfunclib) with two
         % dependency functions in separate subfolders, and a fake project
         % that requires both.
         tmp = testCase.applyFixture(TemporaryFolderFixture);
         base = tmp.Folder;

         mkdir(fullfile(base, "localSource", "libA"))
         mkdir(fullfile(base, "localSource", "libB"))
         mkdir(fullfile(base, "proj"))

         writelines(["function y = irft_dep1(x)"; "y = x + 1;"; "end"], ...
            fullfile(base, "localSource", "libA", "irft_dep1.m"));
         writelines(["function y = irft_dep2(x)"; "y = x + 2;"; "end"], ...
            fullfile(base, "localSource", "libB", "irft_dep2.m"));
         writelines([ ...
            "function y = irft_main(x)"; ...
            "y = irft_dep1(x) + irft_dep2(x);"; ...
            "end"], ...
            fullfile(base, "proj", "irft_main.m"));

         % The dependency walk resolves deps through the path.
         testCase.applyFixture(PathFixture( ...
            fullfile(base, "localSource"), "IncludingSubfolders", true));
         testCase.applyFixture(PathFixture(fullfile(base, "proj")));

         % Canonicalize every fixture path through which()/dir() so string
         % containment checks agree with the analyzer's canonical paths.
         testCase.dep1 = string(which("irft_dep1"));
         testCase.dep2 = string(which("irft_dep2"));
         testCase.localSource = fileparts(fileparts(testCase.dep1));
         mainInfo = dir(which("irft_main"));
         testCase.projFolder = string(mainInfo.folder);
      end
   end

   methods (Access = private)
      function [proj, src] = makeLocalInstallFixture(testCase)
         %MAKELOCALINSTALLFIXTURE A project calling a helper in a source tree.
         %
         % proj/irft_lcaller.m calls irft_lhelper, which lives in src/lib.
         % Everything lives under one fresh scratch root outside the
         % worktree. The teardown that removes it is registered before the
         % first write. Both folders go on the path for the test so the
         % static scan can resolve the call, and come off at teardown. The
         % returned paths are resolved through which, so they compare
         % equal to the paths the analyzer reports.
         scratch = tempname();
         testCase.addTeardown(@() rmdir(scratch, "s"))
         mkdir(scratch)
         proj = fullfile(scratch, "proj");
         src = fullfile(scratch, "src");
         mkdir(proj)
         mkdir(fullfile(src, "lib"))
         writelines("function irft_lcaller(), irft_lhelper(), end", ...
            fullfile(proj, "irft_lcaller.m"))
         writelines("function irft_lhelper(), end", ...
            fullfile(src, "lib", "irft_lhelper.m"))
         addpath(proj, fullfile(src, "lib"))
         testCase.addTeardown(@() rmpath(proj, fullfile(src, "lib")))
         proj = string(fileparts(which("irft_lcaller")));
         src = string(fileparts(fileparts(which("irft_lhelper"))));
      end

      function alias = aliasOf(~, folder)
         %ALIASOF The macOS /var alias of a /private/var folder, when that
         % alias exists, and otherwise the folder itself. A test that
         % exercises an aliased path then runs (through the resolved path)
         % on a host without the alias.
         alias = folder;
         if startsWith(folder, "/private/var/")
            candidate = replace(folder, "/private/var/", "/var/");
            if isfolder(candidate)
               alias = candidate;
            end
         end
      end

      function [requirementsList, urlList] = invokeInstaller(testCase)
         % The real dry-run call, built from the fixture defaults plus the
         % per-call properties set by callInstaller.
         args = [{ ...
            "projectPath", testCase.projFolder, ...
            "localSourcePath", testCase.localSource, ...
            "GitHubUserName", "tuser", ...
            "remoteRepoName", "trepo", ...
            "remoteBranch", "tbranch", ...
            "dryrun", true}, testCase.extraArgs];
         [requirementsList, urlList] = installRequiredFiles( ...
            testCase.positionalList, args{:});
      end

      function [returned, output] = callInstaller( ...
            testCase, positionalList, varargin)
         % Dry-run call with captured printed output. positionalList is the
         % positional requiredFiles input (string.empty to omit); varargin
         % overrides or extends the name-value defaults.
         testCase.positionalList = positionalList;
         testCase.extraArgs = varargin;
         [output, requirementsList, urlList] = ...
            evalc('testCase.invokeInstaller()');
         returned = struct( ...
            "requirementsList", requirementsList, "urlList", urlList);
      end
   end

   methods (Test)
      function testDependencyWalkResolvesProjectDeps(testCase)
         % The generated walk finds both external deps of the project.
         returned = testCase.callInstaller(string.empty);
         expected = ["irft_dep1.m"; "irft_dep2.m"];
         testCase.verifyEqual(sort(returned.requirementsList), expected)

         % URLs mirror the local layout onto the remote raw-content scheme.
         expectedUrls = [ ...
            "https://raw.githubusercontent.com/tuser/trepo/tbranch/libA/irft_dep1.m"; ...
            "https://raw.githubusercontent.com/tuser/trepo/tbranch/libB/irft_dep2.m"];
         testCase.verifyEqual(sort(returned.urlList), expectedUrls)
      end

      function testBranchOverrideChangesUrls(testCase)
         % remoteBranch lands verbatim in the raw-content URL.
         returned = testCase.callInstaller(string.empty, ...
            "remoteBranch", "otherbranch");
         expected = true(numel(returned.urlList), 1);
         testCase.verifyEqual( ...
            contains(returned.urlList, "/otherbranch/"), expected)
      end

      function testExplicitListSkipsGeneration(testCase)
         % A positional requiredFiles list is used as-is (dep2 is a real
         % project dependency but is absent because it is not listed).
         returned = testCase.callInstaller(testCase.dep1);
         expected = "irft_dep1.m";
         testCase.verifyEqual(returned.requirementsList, expected)
      end

      function testSkipsFilesInsideProject(testCase)
         % Entries already inside projectPath are satisfied, so nothing is
         % resolved for them.
         returned = testCase.callInstaller( ...
            fullfile(testCase.projFolder, "irft_main.m"));
         testCase.verifyEmpty(returned.requirementsList)
      end

      function testSkipsMexAndDuplicateEntries(testCase)
         % A .mex entry is skipped and a duplicate resolves only once.
         fakeMex = fullfile(testCase.localSource, "libA", "irft_fake.mex");
         returned = testCase.callInstaller( ...
            [testCase.dep1; testCase.dep1; fakeMex]);
         expected = "irft_dep1.m";
         testCase.verifyEqual(returned.requirementsList, expected)
      end

      function testRequirementsFileMat(testCase)
         % The .mat format written by getRequiredFiles round-trips.
         missingFiles = testCase.dep2;
         matFile = fullfile(tempname() + ".mat");
         save(matFile, "missingFiles")
         cleanup = onCleanup(@() delete(matFile));

         returned = testCase.callInstaller(string.empty, ...
            "requirementsFile", matFile);
         expected = "irft_dep2.m";
         testCase.verifyEqual(returned.requirementsList, expected)
      end

      function testRequirementsFileText(testCase)
         % Plain-text lists work, with blank and # comment lines ignored.
         txtFile = fullfile(tempname() + ".txt");
         writelines([testCase.dep1; ""; "# a comment"; testCase.dep2], txtFile)
         cleanup = onCleanup(@() delete(txtFile));

         returned = testCase.callInstaller(string.empty, ...
            "requirementsFile", txtFile);
         expected = ["irft_dep1.m"; "irft_dep2.m"];
         testCase.verifyEqual(sort(returned.requirementsList), expected)
      end

      function testPositionalListBeatsRequirementsFile(testCase)
         % Documented precedence: positional requiredFiles wins.
         txtFile = fullfile(tempname() + ".txt");
         writelines(testCase.dep2, txtFile)
         cleanup = onCleanup(@() delete(txtFile));

         returned = testCase.callInstaller(testCase.dep1, ...
            "requirementsFile", txtFile);
         expected = "irft_dep1.m";
         testCase.verifyEqual(returned.requirementsList, expected)
      end

      function testMissingRequirementsFileErrors(testCase)
         missingPath = fullfile(tempname() + ".txt");
         testCase.verifyError( ...
            @() installRequiredFiles( ...
            requirementsFile=missingPath, ...
            projectPath=testCase.projFolder, ...
            localSourcePath=testCase.localSource, ...
            GitHubUserName="tuser", dryrun=true), ...
            'installRequiredFiles:requirementsFileNotFound')
      end

      function testInstallPathDefaultFollowsProjectPath(testCase)
         % The documented default install location is the "dependencies"
         % subfolder of projectPath, not of pwd().
         [returned, output] = testCase.callInstaller(string.empty);
         expected = fullfile(testCase.projFolder, "dependencies");
         testCase.verifySubstring(output, expected)
         testCase.verifyNotEmpty(returned.requirementsList)
      end

      %% Local-source mode (harvested from groupstats commit 81ead4db)

      function testLocalCopiesFromTheSource(testCase)
         % source="local" copies each required file from the local source
         % checkout into the install folder, with no network and no GitHub
         % user name. It reports the source paths in the second output.
         [proj, src] = testCase.makeLocalInstallFixture();

         [names, from, failed, skipped] = installRequiredFiles( ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), ...
            ignoreFolder="nosuchfolder", GitHubUserName="", ...
            source="local");

         returned = names;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)

         returned = from;
         expected = fullfile(src, "lib", "irft_lhelper.m");
         testCase.verifyEqual(returned, expected)

         returned = isfile(fullfile(proj, "private", "irft_lhelper.m"));
         expected = true;
         testCase.verifyEqual(returned, expected)

         returned = failed;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = skipped;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
      end

      function testSourceDefaultsToRemote(testCase)
         % Without source=, the URLs are GitHub raw-content URLs, never
         % local paths. Callers that omit source= keep the remote behavior
         % they had before local mode existed.
         result = testCase.callInstaller(string.empty);
         returned = startsWith(result.urlList, "https://");
         expected = true(numel(result.urlList), 1);
         testCase.verifyEqual(returned, expected)
      end

      function testLocalLooksUpAShadowedName(testCase)
         % A copy elsewhere on the path can shadow the source checkout's
         % copy. The installer then looks the file up by name under the
         % source, so the checkout's copy is what gets vendored.
         [proj, src] = testCase.makeLocalInstallFixture();

         % The shadow tree lives under the fixture's one scratch root, so
         % the fixture's teardown removes it.
         shadow = fullfile(fileparts(proj), "shadow");
         mkdir(shadow)
         writelines("function irft_lhelper(), end", ...
            fullfile(shadow, "irft_lhelper.m"))
         addpath(shadow)
         testCase.addTeardown(@() rmpath(shadow))

         [~, from] = installRequiredFiles( ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), ...
            ignoreFolder="nosuchfolder", source="local");

         returned = from;
         expected = fullfile(src, "lib", "irft_lhelper.m");
         testCase.verifyEqual(returned, expected)
      end

      function testLocalResolvesARelativeSource(testCase)
         % The installer makes a relative localSourcePath absolute against
         % the caller's working folder, so the copy lands.
         [proj, src] = testCase.makeLocalInstallFixture();
         here = pwd;
         testCase.addTeardown(@() cd(here))
         cd(fileparts(src))

         [names, from] = installRequiredFiles( ...
            projectPath=proj, localSourcePath="src", ...
            installPath=fullfile(proj, "private"), ...
            ignoreFolder="nosuchfolder", source="local");

         returned = names;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)

         returned = from;
         expected = fullfile(src, "lib", "irft_lhelper.m");
         testCase.verifyEqual(returned, expected)
      end

      function testLocalSkipsANameNotUnderTheSource(testCase)
         % The installer skips a required name with no copy under the
         % source with a warning and returns it in skippedList. Nothing is
         % installed or downloaded for it.
         [proj, src] = testCase.makeLocalInstallFixture();

         [names, ~, ~, skipped] = testCase.verifyWarning(@() ...
            installRequiredFiles("irft_no_such_file.m", ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"), ...
            'installRequiredFiles:notUnderLocalSource');

         returned = names;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)

         returned = skipped;
         expected = "irft_no_such_file.m";
         testCase.verifyEqual(returned, expected)

         returned = isfile(fullfile(proj, "private", "irft_no_such_file.m"));
         expected = false;
         testCase.verifyEqual(returned, expected)
      end

      function testLocalSkipsANameWithSeveralCopies(testCase)
         % Two copies under the source leave no one file to vendor, so the
         % installer skips the name with a warning that lists them.
         [proj, src] = testCase.makeLocalInstallFixture();
         mkdir(fullfile(src, "lib2"))
         copyfile(fullfile(src, "lib", "irft_lhelper.m"), ...
            fullfile(src, "lib2", "irft_lhelper.m"))

         [names, ~, ~, skipped] = testCase.verifyWarning(@() ...
            installRequiredFiles("irft_lhelper.m", ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"), ...
            'installRequiredFiles:severalUnderLocalSource');

         returned = names;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = skipped;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
      end

      function testLocalSkipsAMatlabFileQuietly(testCase)
         % A MATLAB file under matlabroot is not a dependency to vendor.
         % It is common enough that no warning should name it, and it is
         % not listed as skipped.
         [proj, src] = testCase.makeLocalInstallFixture();
         matlabfile = fullfile(matlabroot, "toolbox", "local", "userpath.m");

         [names, ~, ~, skipped] = testCase.verifyWarningFree(@() ...
            installRequiredFiles(matlabfile, ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"));

         returned = names;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = skipped;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
      end

      function testLocalLeavesAFailedCopyOut(testCase)
         % A folder where the copy should land is a failure before any
         % write, so no nested copy appears inside it. The installer warns
         % about the name, lists it in failedList, and leaves it out of
         % requirementsList.
         [proj, src] = testCase.makeLocalInstallFixture();
         inTheWay = fullfile(proj, "private", "irft_lhelper.m");
         mkdir(inTheWay)

         [names, ~, failed] = testCase.verifyWarning(@() ...
            installRequiredFiles( ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), ...
            ignoreFolder="nosuchfolder", source="local"), ...
            'installRequiredFiles:installFailed');

         returned = names;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = failed;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)

         returned = isfile(fullfile(inTheWay, "irft_lhelper.m"));
         expected = false;
         testCase.verifyEqual(returned, expected)
      end

      function testLocalLeavesAFailedOverwriteOut(testCase)
         % A destination that existed before and survived a failed copy is
         % not this call's file, so the installer warns about it and
         % leaves it out.
         [proj, src] = testCase.makeLocalInstallFixture();
         mkdir(fullfile(proj, "private"))
         writelines("old", fullfile(proj, "private", "irft_lhelper.m"))

         % An unreadable source makes the copy fail. chmod removes read
         % permission, which fileattrib cannot do on this platform, so the
         % case runs on the Unix-like hosts the suite runs on. No
         % mechanism makes a source unreadable on Windows or for a
         % privileged process, so those two hosts record this one case as
         % filtered and do not pass a check that cannot fail.
         testCase.assumeFalse(ispc, "chmod is not available on Windows.")
         % A privileged process (root, or CAP_DAC_OVERRIDE in a container)
         % reads a mode-000 file anyway, so the failure cannot be staged.
         [~, uid] = system('id -u');
         testCase.assumeTrue(str2double(uid) ~= 0, ...
            "a privileged process ignores file modes")
         sourcefile = char(fullfile(src, "lib", "irft_lhelper.m"));
         system(['chmod 000 "' sourcefile '"']);
         testCase.addTeardown(@() system(['chmod 644 "' sourcefile '"']))

         [names, ~, failed] = testCase.verifyWarning(@() ...
            installRequiredFiles("irft_lhelper.m", ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"), ...
            'installRequiredFiles:installFailed');

         returned = names;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = failed;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)

         % The destination that existed before survives untouched.
         returned = strtrim(readlines( ...
            fullfile(proj, "private", "irft_lhelper.m")));
         expected = "old";
         testCase.verifyEqual(returned(1), expected)
      end

      function testReferenceListCountsAsPresent(testCase)
         % A folder named as the reference counts as present, so a call
         % into it is not vendored: with the first project as the
         % reference, only the helper under the source is missing.
         [proj, src] = testCase.makeLocalInstallFixture();

         proj2 = fullfile(fileparts(proj), "proj2");
         mkdir(proj2)
         writelines("function irft_lsecond(), irft_lcaller(), end", ...
            fullfile(proj2, "irft_lsecond.m"))
         addpath(proj2)
         testCase.addTeardown(@() rmpath(proj2))

         names = installRequiredFiles( ...
            projectPath=proj2, referenceList=proj, ...
            localSourcePath=src, ...
            installPath=fullfile(proj2, "private"), ...
            ignoreFolder="nosuchfolder", source="local");

         returned = names;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
      end

      function testFileAtTheSourceRoot(testCase)
         % A file at the source root has no subfolder, so its url has no
         % middle segment and its local copy lands.
         [proj, src] = testCase.makeLocalInstallFixture();
         movefile(fullfile(src, "lib", "irft_lhelper.m"), ...
            fullfile(src, "irft_lhelper.m"))
         addpath(src)
         testCase.addTeardown(@() rmpath(src))

         [names, urls] = installRequiredFiles( ...
            fullfile(src, "irft_lhelper.m"), ...
            projectPath=proj, localSourcePath=src, ...
            GitHubUserName="tuser", remoteRepoName="trepo", ...
            remoteBranch="tbranch", dryrun=true);
         returned = names;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
         returned = urls;
         expected = "https://raw.githubusercontent.com/tuser/trepo/tbranch/irft_lhelper.m";
         testCase.verifyEqual(returned, expected)

         [names, from] = installRequiredFiles( ...
            fullfile(src, "irft_lhelper.m"), ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local");
         returned = names;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
         returned = from;
         expected = fullfile(src, "irft_lhelper.m");
         testCase.verifyEqual(returned, expected)
         returned = isfile(fullfile(proj, "private", "irft_lhelper.m"));
         expected = true;
         testCase.verifyEqual(returned, expected)
      end

      function testSkipfileMatchesOnFolderBoundaries(testCase)
         % A source folder whose name starts with the project folder's
         % name is not inside the project, so its file is vendored. (A
         % substring test would accept proj-src as inside proj.)
         [proj, src] = testCase.makeLocalInstallFixture();
         sibling = proj + "-src";
         mkdir(sibling)
         movefile(fullfile(src, "lib", "irft_lhelper.m"), ...
            fullfile(sibling, "irft_lhelper.m"))
         addpath(sibling)
         testCase.addTeardown(@() rmpath(sibling))

         [names, from] = installRequiredFiles( ...
            projectPath=proj, localSourcePath=sibling, ...
            installPath=fullfile(proj, "private"), ...
            ignoreFolder="nosuchfolder", source="local");

         returned = names;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
         returned = from;
         expected = fullfile(sibling, "irft_lhelper.m");
         testCase.verifyEqual(returned, expected)
      end

      function testRequirementsFileSourceRelativeEntry(testCase)
         % A requirements-file line written relative to the source names
         % one file even when the bare name has several copies under the
         % source, so the installer installs it.
         [proj, src] = testCase.makeLocalInstallFixture();
         mkdir(fullfile(src, "lib2"))
         copyfile(fullfile(src, "lib", "irft_lhelper.m"), ...
            fullfile(src, "lib2", "irft_lhelper.m"))
         txtFile = fullfile(fileparts(proj), "requirements.txt");
         writelines("lib2/irft_lhelper.m", txtFile)

         [names, from, ~, skipped] = testCase.verifyWarningFree(@() ...
            installRequiredFiles(requirementsFile=txtFile, ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"));

         returned = names;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
         returned = from;
         expected = fullfile(src, "lib2", "irft_lhelper.m");
         testCase.verifyEqual(returned, expected)
         returned = skipped;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
      end

      function testAliasedPathsCompareEqual(testCase)
         % On macOS, /var is a symbolic link to /private/var. A required
         % file and a source given through different aliases count as the
         % same tree, so the installer uses the file from its given path
         % and does not look it up by name (where two copies would skip
         % it).
         [proj, src] = testCase.makeLocalInstallFixture();
         % On a host without the /var alias the test makes the same call
         % through the resolved path, which exercises the full-path branch
         % and keeps the suite deterministic there.
         alias = testCase.aliasOf(src);
         mkdir(fullfile(src, "lib2"))
         copyfile(fullfile(src, "lib", "irft_lhelper.m"), ...
            fullfile(src, "lib2", "irft_lhelper.m"))

         [names, from] = testCase.verifyWarningFree(@() ...
            installRequiredFiles( ...
            fullfile(alias, "lib", "irft_lhelper.m"), ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"));

         returned = names;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
         returned = from;
         expected = fullfile(src, "lib", "irft_lhelper.m");
         testCase.verifyEqual(returned, expected)
      end

      function testSourceRelativeEntryBeatsAProjectFolderOfTheSameName(testCase)
         % A source-relative entry resolves under the source even when the
         % project holds a folder of the same name, so a duplicate bare
         % name installs.
         [proj, src] = testCase.makeLocalInstallFixture();
         mkdir(fullfile(src, "lib2"))
         copyfile(fullfile(src, "lib", "irft_lhelper.m"), ...
            fullfile(src, "lib2", "irft_lhelper.m"))
         mkdir(fullfile(proj, "lib2"))

         [names, from] = testCase.verifyWarningFree(@() ...
            installRequiredFiles("lib2/irft_lhelper.m", ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"));

         returned = names;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
         returned = from;
         expected = fullfile(src, "lib2", "irft_lhelper.m");
         testCase.verifyEqual(returned, expected)
      end

      function testStaleSourceRelativeEntryIsSkippedNotMatchedByName(testCase)
         % The installer skips a source-relative entry whose file is
         % absent at that place, with a warning. It never matches the
         % entry by bare name to another copy under the source, and a
         % same-named project folder does not count it as satisfied.
         [proj, src] = testCase.makeLocalInstallFixture();
         mkdir(fullfile(proj, "lib3"))

         [names, ~, ~, skipped] = testCase.verifyWarning(@() ...
            installRequiredFiles("lib3/irft_lhelper.m", ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"), ...
            'installRequiredFiles:notUnderLocalSource');

         returned = names;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = skipped;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
         returned = isfile(fullfile(proj, "private", "irft_lhelper.m"));
         expected = false;
         testCase.verifyEqual(returned, expected)
      end

      function testEscapingRelativeEntryIsSkipped(testCase)
         % A relative entry that climbs out of the source with ".." names
         % a file the source does not own, so the installer skips it with
         % a warning even when that outside file exists and the source
         % holds a same-named file.
         [proj, src] = testCase.makeLocalInstallFixture();
         outside = fullfile(fileparts(src), "outside");
         mkdir(outside)
         copyfile(fullfile(src, "lib", "irft_lhelper.m"), ...
            fullfile(outside, "irft_lhelper.m"))

         [names, ~, ~, skipped] = testCase.verifyWarning(@() ...
            installRequiredFiles("../outside/irft_lhelper.m", ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"), ...
            'installRequiredFiles:notUnderLocalSource');

         returned = names;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = skipped;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
         returned = isfile(fullfile(proj, "private", "irft_lhelper.m"));
         expected = false;
         testCase.verifyEqual(returned, expected)
      end

      function testRootEntryWithDotPrefixNamesTheRootFile(testCase)
         % "./name.m" names the file at the source root even when a
         % subfolder holds the same name, where a bare name would be
         % ambiguous and skipped.
         [proj, src] = testCase.makeLocalInstallFixture();
         copyfile(fullfile(src, "lib", "irft_lhelper.m"), ...
            fullfile(src, "irft_lhelper.m"))

         [names, from] = testCase.verifyWarningFree(@() ...
            installRequiredFiles("./irft_lhelper.m", ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"));
         returned = names;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
         returned = from;
         expected = fullfile(src, "irft_lhelper.m");
         testCase.verifyEqual(returned, expected)

         [names, ~, ~, skipped] = testCase.verifyWarning(@() ...
            installRequiredFiles("irft_lhelper.m", ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"), ...
            'installRequiredFiles:severalUnderLocalSource');
         returned = names;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = skipped;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
      end

      function testRemoteInstallLandsThroughTheStagingFile(testCase)
         % When the environment variable MATFUNCLIB_LIVE_TESTS is set,
         % this test exercises the remote path (websave into a staging
         % file that keeps the destination's extension, then a move into
         % place) against the real matfunclib repository. That run is the
         % direct evidence that websave's returned name is the file that
         % moves. Without it the same call runs as a dry run, which checks
         % the planned url deterministically and keeps the suite free of
         % network and of assumption-skipped (incomplete) results.
         url = "https://raw.githubusercontent.com/mgcooper/matfunclib/main/functools/isoneof.m";
         live = strlength(string(getenv("MATFUNCLIB_LIVE_TESTS"))) > 0;

         [proj, src] = testCase.makeLocalInstallFixture();
         installPath = fullfile(proj, "dependencies");
         % The required file must exist under the local source: the url
         % mirrors the checkout's layout, so the local copy is the
         % evidence that the path exists in the repository.
         mkdir(fullfile(src, "functools"))
         writelines("function tf = isoneof(varargin), tf = false; end", ...
            fullfile(src, "functools", "isoneof.m"))
         [names, urls, failed] = installRequiredFiles( ...
            fullfile(src, "functools", "isoneof.m"), ...
            projectPath=proj, localSourcePath=src, ...
            GitHubUserName="mgcooper", remoteRepoName="matfunclib", ...
            remoteBranch="main", installPath=installPath, dryrun=~live);

         returned = names;
         expected = "isoneof.m";
         testCase.verifyEqual(returned, expected)
         returned = urls;
         expected = url;
         testCase.verifyEqual(returned, expected)
         returned = failed;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = isfile(fullfile(installPath, "isoneof.m"));
         expected = live;
         testCase.verifyEqual(returned, expected)
      end

      function testRelativeReferenceListResolvesFromTheCaller(testCase)
         % The installer resolves a referenceList given relative to the
         % caller's working folder against that folder, so a sibling
         % folder counts as present. The fixture's source path is not
         % needed: the call names it relative, as "src".
         [proj, ~] = testCase.makeLocalInstallFixture();
         parent = fileparts(proj);
         proj2 = fullfile(parent, "proj2");
         mkdir(proj2)
         writelines("function irft_lsecond(), irft_lcaller(), end", ...
            fullfile(proj2, "irft_lsecond.m"))
         addpath(proj2)
         testCase.addTeardown(@() rmpath(proj2))
         here = pwd;
         testCase.addTeardown(@() cd(here))
         cd(parent)

         names = installRequiredFiles( ...
            projectPath="proj2", referenceList="proj", ...
            localSourcePath="src", ...
            installPath=fullfile(proj2, "private"), ...
            ignoreFolder="nosuchfolder", source="local");

         returned = names;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
      end

      function testAliasedProjectFileIsSkippedAsSatisfied(testCase)
         % The installer recognizes a required file inside the project,
         % given through the /var alias, as the project's own and never
         % installs it, even though the source also holds that name.
         [proj, src] = testCase.makeLocalInstallFixture();
         alias = testCase.aliasOf(proj);
         copyfile(fullfile(proj, "irft_lcaller.m"), ...
            fullfile(src, "lib", "irft_lcaller.m"))

         [names, ~, ~, skipped] = installRequiredFiles( ...
            fullfile(alias, "irft_lcaller.m"), ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local");

         returned = names;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = skipped;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = isfile(fullfile(proj, "private", "irft_lcaller.m"));
         expected = false;
         testCase.verifyEqual(returned, expected)
      end

      function testNoStagingFileIsLeftBehind(testCase)
         % After a successful and a failed install, the install folder
         % holds only the landed file: no staging file remains.
         [proj, src] = testCase.makeLocalInstallFixture();
         installPath = fullfile(proj, "private");
         installRequiredFiles(projectPath=proj, localSourcePath=src, ...
            installPath=installPath, ignoreFolder="nosuchfolder", ...
            source="local");
         mkdir(fullfile(installPath, "irft_second.m"))
         writelines("function irft_second(), end", ...
            fullfile(src, "lib", "irft_second.m"))
         testCase.verifyWarning(@() installRequiredFiles( ...
            "irft_second.m", projectPath=proj, localSourcePath=src, ...
            installPath=installPath, source="local"), ...
            'installRequiredFiles:installFailed');

         listing = dir(installPath);
         returned = sort(string({listing(~[listing.isdir]).name}))';
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
      end

      function testSameNameFromTwoFoldersWarnsAndKeepsTheFirst(testCase)
         % Two different source files with one name cannot both land at
         % one destination: the installer installs the first, warns
         % installRequiredFiles:duplicateName for the second, and lists it
         % as skipped.
         [proj, src] = testCase.makeLocalInstallFixture();
         mkdir(fullfile(src, "lib2"))
         writelines("function irft_lhelper(), disp(2), end", ...
            fullfile(src, "lib2", "irft_lhelper.m"))

         [names, from, ~, skipped] = testCase.verifyWarning(@() ...
            installRequiredFiles( ...
            ["lib/irft_lhelper.m", "lib2/irft_lhelper.m"], ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"), ...
            'installRequiredFiles:duplicateName');

         returned = names;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
         returned = from;
         expected = fullfile(src, "lib", "irft_lhelper.m");
         testCase.verifyEqual(returned, expected)
         returned = skipped;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
      end

      function testMissingExplicitFileUnderTheSourceIsSkipped(testCase)
         % A path under the source whose file does not exist names nothing
         % to copy, so the installer skips it with a warning and does not
         % report a failed install.
         [proj, src] = testCase.makeLocalInstallFixture();

         [names, ~, failed, skipped] = testCase.verifyWarning(@() ...
            installRequiredFiles(fullfile(src, "lib", "irft_gone.m"), ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"), ...
            'installRequiredFiles:notUnderLocalSource');

         returned = names;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = failed;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = skipped;
         expected = "irft_gone.m";
         testCase.verifyEqual(returned, expected)
      end

      function testRepeatedBareNameIsListedOnce(testCase)
         % The same bare name twice resolves to the same source file and
         % is listed once, with no duplicate-name warning.
         [proj, src] = testCase.makeLocalInstallFixture();

         [names, ~, ~, skipped] = testCase.verifyWarningFree(@() ...
            installRequiredFiles(["irft_lhelper.m", "irft_lhelper.m"], ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"));

         returned = names;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
         returned = skipped;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
      end

      function testAbsentExplicitProjectFileIsSkippedWithWarning(testCase)
         % A path inside the project whose file is absent names nothing.
         % The installer skips it with a warning and does not look its
         % bare name up under the source.
         [proj, src] = testCase.makeLocalInstallFixture();

         [names, ~, ~, skipped] = testCase.verifyWarning(@() ...
            installRequiredFiles(fullfile(proj, "irft_lhelper.m"), ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"), ...
            'installRequiredFiles:notUnderLocalSource');

         returned = names;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = skipped;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
      end

      function testRootedAndDriveRelativeEntriesAreClassified(testCase)
         % A rooted entry (leading backslash, or a drive root such as
         % "C:/") is not source-relative, so it takes the lookup by name
         % and installs the source's copy. A drive-relative entry such as
         % "C:lib/name.m" is source-relative: the installer anchors it
         % under the source, where no such folder exists, and skips it.
         % The classification is lexical, so it holds on every host. The
         % folder part uses "/" after the root marker so fileparts splits
         % it on this host too.
         [proj, src] = testCase.makeLocalInstallFixture();

         [names, from] = testCase.verifyWarningFree(@() ...
            installRequiredFiles( ...
            ["\lib/irft_lhelper.m", "C:/lib/irft_lhelper.m"], ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"));
         returned = names;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
         returned = from;
         expected = fullfile(src, "lib", "irft_lhelper.m");
         testCase.verifyEqual(returned, expected)

         [names, ~, ~, skipped] = testCase.verifyWarning(@() ...
            installRequiredFiles("C:lib/irft_lhelper.m", ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"), ...
            'installRequiredFiles:notUnderLocalSource');
         returned = names;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = skipped;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
      end

      function testProjectFolderNamedLikeAFileIsNotSatisfied(testCase)
         % A folder inside the project whose name looks like the required
         % file is not that file: the installer skips the entry with a
         % warning and does not count it as satisfied.
         [proj, src] = testCase.makeLocalInstallFixture();
         mkdir(fullfile(proj, "irft_lhelper.m"))

         [names, ~, ~, skipped] = testCase.verifyWarning(@() ...
            installRequiredFiles(fullfile(proj, "irft_lhelper.m"), ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"), ...
            'installRequiredFiles:notUnderLocalSource');

         returned = names;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = skipped;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
      end

      function testMissingMatlabRootEntryIsNotHidden(testCase)
         % Only an existing MATLAB file is dropped with no warning. The
         % installer looks a path under matlabroot that names no file up
         % like any other name, so it finds and installs the source's copy.
         [proj, src] = testCase.makeLocalInstallFixture();
         ghost = fullfile(matlabroot, "toolbox", "local", "irft_lhelper.m");

         [names, from] = testCase.verifyWarningFree(@() ...
            installRequiredFiles(ghost, ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"));

         returned = names;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
         returned = from;
         expected = fullfile(src, "lib", "irft_lhelper.m");
         testCase.verifyEqual(returned, expected)
      end

      function testMissingAliasedFolderUnderTheSourceIsSkipped(testCase)
         % A path through the /var alias whose folder does not exist
         % resolves as inside the source (through its deepest existing
         % ancestor). The installer reports it missing there and does not
         % match it by name to the source's other copy.
         [proj, src] = testCase.makeLocalInstallFixture();
         alias = testCase.aliasOf(src);

         [names, ~, ~, skipped] = testCase.verifyWarning(@() ...
            installRequiredFiles( ...
            fullfile(alias, "gone", "irft_lhelper.m"), ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"), ...
            'installRequiredFiles:notUnderLocalSource');

         returned = names;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = skipped;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
      end

      function testEntryEndingInASeparatorIsSkipped(testCase)
         % The installer reports and skips an entry that names a folder,
         % not a file, and does not resolve it to whatever that folder
         % holds.
         [proj, src] = testCase.makeLocalInstallFixture();

         [names, ~, ~, skipped] = testCase.verifyWarning(@() ...
            installRequiredFiles(fullfile(src, "lib") + "/", ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"), ...
            'installRequiredFiles:notUnderLocalSource');

         returned = names;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = numel(skipped);
         expected = 1;
         testCase.verifyEqual(returned, expected)
      end

      function testLocalModeNeedsNoRemoteRepositoryName(testCase)
         % A local install never builds a url, so an empty remoteRepoName
         % is not an error there.
         [proj, src] = testCase.makeLocalInstallFixture();

         names = installRequiredFiles( ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), ...
            ignoreFolder="nosuchfolder", remoteRepoName="", ...
            GitHubUserName="", source="local");

         returned = names;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
      end

      function testAnchoredEntryInsideAProjectUnderTheSourceIsSatisfied(testCase)
         % When the project lives under the source, a source-relative entry
         % that resolves inside the project names the project's own file,
         % which is satisfied and never installed.
         [~, src] = testCase.makeLocalInstallFixture();
         nested = fullfile(src, "nested");
         mkdir(nested)
         writelines("function irft_nested(), end", ...
            fullfile(nested, "irft_nested.m"))

         [names, ~, ~, skipped] = testCase.verifyWarningFree(@() ...
            installRequiredFiles("nested/irft_nested.m", ...
            projectPath=nested, localSourcePath=src, ...
            installPath=fullfile(nested, "private"), source="local"));

         returned = names;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = skipped;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = isfile(fullfile(nested, "private", "irft_nested.m"));
         expected = false;
         testCase.verifyEqual(returned, expected)
      end

      function testWildcardEntryIsSkipped(testCase)
         % A pattern is not a file name. The installer reports and skips
         % it and never expands it to whatever matches first.
         [proj, src] = testCase.makeLocalInstallFixture();

         [names, ~, ~, skipped] = testCase.verifyWarning(@() ...
            installRequiredFiles("lib/*.m", ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"), ...
            'installRequiredFiles:notUnderLocalSource');

         returned = names;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = skipped;
         expected = "*.m";
         testCase.verifyEqual(returned, expected)
      end

      function testCaseVariantNamesFollowTheFileSystem(testCase)
         % Two files whose names differ only by case are one destination
         % on a case-folding volume, where the second warns duplicateName.
         % They are two destinations on a case-sensitive volume, where
         % both install. The test reads which case applies from the
         % destination volume the way the installer reads it: a mixed-case
         % file found under its lower-case name.
         [proj, src] = testCase.makeLocalInstallFixture();
         mkdir(fullfile(src, "lib2"))
         copyfile(fullfile(src, "lib", "irft_lhelper.m"), ...
            fullfile(src, "lib2", "IRFT_lhelper.m"))
         entries = ["lib/irft_lhelper.m", "lib2/IRFT_lhelper.m"];
         call = @() installRequiredFiles(entries, ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local");
         folds = isfile(fullfile(src, "lib2", "irft_lhelper.m"));

         if folds
            [names, ~, ~, skipped] = testCase.verifyWarning(call, ...
               'installRequiredFiles:duplicateName');
            returned = names;
            expected = "irft_lhelper.m";
            testCase.verifyEqual(returned, expected)
            returned = skipped;
            expected = "IRFT_lhelper.m";
            testCase.verifyEqual(returned, expected)
         else
            [names, ~, ~, skipped] = testCase.verifyWarningFree(call);
            returned = sort(names);
            expected = ["IRFT_lhelper.m"; "irft_lhelper.m"];
            testCase.verifyEqual(returned, expected)
            returned = skipped;
            expected = strings(0, 1);
            testCase.verifyEqual(returned, expected)
         end
      end

      function testWildcardInAFolderComponentIsSkipped(testCase)
         % A pattern in the folder part is rejected the same way as one
         % in the file name.
         [proj, src] = testCase.makeLocalInstallFixture();

         [names, ~, ~, skipped] = testCase.verifyWarning(@() ...
            installRequiredFiles("li*/irft_lhelper.m", ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"), ...
            'installRequiredFiles:notUnderLocalSource');

         returned = names;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = skipped;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
      end

      function testMissingRelativeReferenceListIsAnError(testCase)
         % A relative referenceList absent from the caller's folder stays
         % fixed to that folder, so a same-named folder inside the project
         % cannot stand in for it, and the validation fails.
         [proj, src] = testCase.makeLocalInstallFixture();
         mkdir(fullfile(proj, "refs"))
         here = pwd;
         testCase.addTeardown(@() cd(here))
         cd(fileparts(proj))

         testCase.verifyError(@() installRequiredFiles( ...
            projectPath=proj, referenceList="refs", ...
            localSourcePath=src, ...
            installPath=fullfile(proj, "private"), ...
            ignoreFolder="nosuchfolder", source="local"), ...
            'MATLAB:validators:mustBeFolder')
      end

      function testSourceFolderNamedLikeAFileIsSkipped(testCase)
         % A source entry that names a non-empty folder is not a file. The
         % installer skips it with a warning and never enumerates the
         % folder's contents as candidates.
         [proj, src] = testCase.makeLocalInstallFixture();
         mkdir(fullfile(src, "lib", "irft_folder.m"))
         writelines("function irft_inner(), end", ...
            fullfile(src, "lib", "irft_folder.m", "irft_inner.m"))

         [names, ~, ~, skipped] = testCase.verifyWarning(@() ...
            installRequiredFiles(fullfile(src, "lib", "irft_folder.m"), ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"), ...
            'installRequiredFiles:notUnderLocalSource');

         returned = names;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = skipped;
         expected = "irft_folder.m";
         testCase.verifyEqual(returned, expected)
      end

      function testAnchoredFolderNamedLikeAFileIsSkipped(testCase)
         % The installer skips a source-relative entry that names a
         % non-empty folder with a warning and never enumerates the folder.
         [proj, src] = testCase.makeLocalInstallFixture();
         mkdir(fullfile(src, "lib", "irft_folder.m"))
         writelines("function irft_inner(), end", ...
            fullfile(src, "lib", "irft_folder.m", "irft_inner.m"))

         [names, ~, ~, skipped] = testCase.verifyWarning(@() ...
            installRequiredFiles("lib/irft_folder.m", ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"), ...
            'installRequiredFiles:notUnderLocalSource');

         returned = names;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = skipped;
         expected = "irft_folder.m";
         testCase.verifyEqual(returned, expected)
      end

      function testRemoteModeRejectsEmptyIdentifiers(testCase)
         % An empty GitHub user name or repository name in remote mode is
         % an error before any url is built. The arguments block turns an
         % unset environment variable into "", which isempty would accept.
         testCase.verifyError(@() installRequiredFiles(testCase.dep1, ...
            projectPath=testCase.projFolder, ...
            localSourcePath=testCase.localSource, ...
            GitHubUserName="", remoteRepoName="trepo", dryrun=true), ...
            'installRequiredFiles:missingGitHubUserName')
         testCase.verifyError(@() installRequiredFiles(testCase.dep1, ...
            projectPath=testCase.projFolder, ...
            localSourcePath=testCase.localSource, ...
            GitHubUserName="tuser", remoteRepoName="", dryrun=true), ...
            'installRequiredFiles:missingRemoteRepoName')
      end

      function testCaseVariantSourcesCollideByDestinationRule(testCase)
         % Whether two entries are one file is decided on the source
         % volume. On a case-sensitive source, "lib" and "LIB" are two
         % folders, and their same-named files are two sources that
         % collide at one destination name. The second warns duplicateName
         % and is listed as skipped, never dropped as a repeat. On a
         % case-folding source, "LIB" is "lib", so the two entries name
         % one file, listed once with no warning.
         [proj, src] = testCase.makeLocalInstallFixture();
         folds = isfile(fullfile(src, "lib", "IRFT_LHELPER.m"));
         if ~folds
            mkdir(fullfile(src, "LIB"))
            copyfile(fullfile(src, "lib", "irft_lhelper.m"), ...
               fullfile(src, "LIB", "irft_lhelper.m"))
         end
         entries = ["lib/irft_lhelper.m", "LIB/irft_lhelper.m"];
         call = @() installRequiredFiles(entries, ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local");

         if folds
            [names, ~, ~, skipped] = testCase.verifyWarningFree(call);
            returned = skipped;
            expected = strings(0, 1);
            testCase.verifyEqual(returned, expected)
         else
            [names, ~, ~, skipped] = testCase.verifyWarning(call, ...
               'installRequiredFiles:duplicateName');
            returned = skipped;
            expected = "irft_lhelper.m";
            testCase.verifyEqual(returned, expected)
         end
         returned = names;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
      end

      function testRelativeInstallPathResolvesFromTheCaller(testCase)
         % The installer creates a relative installPath that does not
         % exist yet under the caller's folder, and the file lands there.
         [proj, src] = testCase.makeLocalInstallFixture();
         here = builtin('cd');
         testCase.addTeardown(@() builtin('cd', here))
         builtin('cd', fileparts(proj))

         names = installRequiredFiles( ...
            projectPath=proj, localSourcePath=src, ...
            installPath="new/deps", ignoreFolder="nosuchfolder", ...
            source="local");

         returned = names;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
         returned = isfile(fullfile(fileparts(proj), "new", "deps", ...
            "irft_lhelper.m"));
         expected = true;
         testCase.verifyEqual(returned, expected)
      end

      function testBareMatlabNameIsSkippedQuietly(testCase)
         % A MATLAB file named bare, with no copy under the source, is
         % MATLAB's own: it is dropped with no warning and is not listed
         % as skipped, the same as the full-path form.
         [proj, src] = testCase.makeLocalInstallFixture();

         [names, ~, ~, skipped] = testCase.verifyWarningFree(@() ...
            installRequiredFiles("userpath.m", ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"));

         returned = names;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = skipped;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
      end

      function testSourceCopyOfAMatlabNameWins(testCase)
         % A source copy of a name MATLAB also ships, such as userpath.m,
         % is the dependency to vendor when the source holds one. The
         % MATLAB-file exemption applies only when the source has none.
         [proj, src] = testCase.makeLocalInstallFixture();
         writelines("function p = userpath(), p = 'x'; end", ...
            fullfile(src, "lib", "userpath.m"))

         [names, from] = testCase.verifyWarningFree(@() ...
            installRequiredFiles("userpath.m", ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), source="local"));

         returned = names;
         expected = "userpath.m";
         testCase.verifyEqual(returned, expected)
         returned = from;
         expected = fullfile(src, "lib", "userpath.m");
         testCase.verifyEqual(returned, expected)
      end

      function testDryRunIntoAReadOnlyFolderStillPlans(testCase)
         % A dry run into a folder that cannot be written returns the
         % planned list: the case probe falls back to the host convention
         % and does not fail.
         [proj, src] = testCase.makeLocalInstallFixture();
         testCase.assumeFalse(ispc, "chmod is not available on Windows.")
         [~, uid] = system('id -u');
         testCase.assumeTrue(str2double(uid) ~= 0, ...
            "a privileged process ignores folder modes")
         installPath = fullfile(proj, "readonly");
         mkdir(installPath)
         system(['chmod 555 "' char(installPath) '"']);
         testCase.addTeardown(@() system(['chmod 755 "' char(installPath) '"']))

         names = installRequiredFiles( ...
            projectPath=proj, localSourcePath=src, ...
            installPath=installPath, ignoreFolder="nosuchfolder", ...
            source="local", dryrun=true);

         returned = names;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
      end

      function testDryRunReturnsThePlannedListInLocalMode(testCase)
         % dryrun=true reports what would be installed, in both modes,
         % and writes nothing (the A2 condition on matfunclib-juq.45).
         [proj, src] = testCase.makeLocalInstallFixture();

         [names, from, failed, skipped] = installRequiredFiles( ...
            projectPath=proj, localSourcePath=src, ...
            installPath=fullfile(proj, "private"), ...
            ignoreFolder="nosuchfolder", source="local", dryrun=true);
         returned = names;
         expected = "irft_lhelper.m";
         testCase.verifyEqual(returned, expected)
         returned = from;
         expected = fullfile(src, "lib", "irft_lhelper.m");
         testCase.verifyEqual(returned, expected)
         returned = failed;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = skipped;
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
         returned = isfolder(fullfile(proj, "private"));
         expected = false;
         testCase.verifyEqual(returned, expected)
      end
   end
end
