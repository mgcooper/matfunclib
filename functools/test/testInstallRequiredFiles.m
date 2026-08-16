classdef testInstallRequiredFiles < matlab.unittest.TestCase
   %TESTINSTALLREQUIREDFILES Unit tests for functools/installRequiredFiles.
   %
   % Network-free by design: every call uses dryrun=true, which resolves and
   % prints the install plan without downloading anything.

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

         % Put matfunclib on the path so installRequiredFiles and its
         % helpers (withcd, listfiles, ...) resolve from the repo root.
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
   end
end
