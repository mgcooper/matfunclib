classdef testGetRequiredFiles < matlab.unittest.TestCase
   %TESTGETREQUIREDFILES Unit tests for functools/getRequiredFiles.

   properties
      % Canonical fixture paths (see testInstallRequiredFiles for why these
      % are resolved through which()/dir() rather than kept as tempdir
      % literals).
      localSource string
      projFolder string
      dep1 string
      dep2 string
      dep3 string
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so getRequiredFiles and its helpers
         % (listfiles, isfullfile, ...) resolve from the repo root.
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

         % A fake local-source tree with three dependency functions, and a
         % fake project whose main function needs dep1/dep2 while a
         % testbed/ script needs dep3 (to exercise ignoreList).
         tmp = testCase.applyFixture(TemporaryFolderFixture);
         base = tmp.Folder;

         mkdir(fullfile(base, "localSource", "libA"))
         mkdir(fullfile(base, "localSource", "libB"))
         mkdir(fullfile(base, "localSource", "libC"))
         mkdir(fullfile(base, "proj", "testbed"))

         writelines(["function y = grft_dep1(x)"; "y = x + 1;"; "end"], ...
            fullfile(base, "localSource", "libA", "grft_dep1.m"));
         writelines(["function y = grft_dep2(x)"; "y = x + 2;"; "end"], ...
            fullfile(base, "localSource", "libB", "grft_dep2.m"));
         writelines(["function y = grft_dep3(x)"; "y = x + 3;"; "end"], ...
            fullfile(base, "localSource", "libC", "grft_dep3.m"));
         writelines([ ...
            "function y = grft_main(x)"; ...
            "y = grft_dep1(x) + grft_dep2(x);"; ...
            "end"], ...
            fullfile(base, "proj", "grft_main.m"));
         writelines([ ...
            "function y = grft_scratch(x)"; ...
            "y = grft_dep3(x);"; ...
            "end"], ...
            fullfile(base, "proj", "testbed", "grft_scratch.m"));

         % The dependency walk resolves deps through the path.
         testCase.applyFixture(PathFixture( ...
            fullfile(base, "localSource"), "IncludingSubfolders", true));
         testCase.applyFixture(PathFixture( ...
            fullfile(base, "proj"), "IncludingSubfolders", true));

         % Canonicalize fixture paths (macOS /var vs /private/var).
         testCase.dep1 = string(which("grft_dep1"));
         testCase.dep2 = string(which("grft_dep2"));
         testCase.dep3 = string(which("grft_dep3"));
         testCase.localSource = fileparts(fileparts(testCase.dep1));
         mainInfo = dir(which("grft_main"));
         testCase.projFolder = string(mainInfo.folder);
      end
   end

   methods (Test)
      function testWalkFindsMissingFiles(testCase)
         % Deps outside the reference (project) folder are missing;
         % testbed/ requirements are included when nothing is ignored.
         Requirements = getRequiredFiles(testCase.projFolder, ...
            "referenceList", testCase.projFolder);
         [~, names, exts] = fileparts(Requirements.missingFiles);
         returned = sort(names + exts);
         expected = ["grft_dep1.m"; "grft_dep2.m"; "grft_dep3.m"];
         testCase.verifyEqual(reshape(returned, [], 1), expected)
      end

      function testIgnoreListExcludesFolder(testCase)
         % Ignoring testbed/ removes its file (and so its dep3 requirement)
         % from the walk.
         Requirements = getRequiredFiles(testCase.projFolder, ...
            "referenceList", testCase.projFolder, ...
            "ignoreList", fullfile(testCase.projFolder, "testbed"));
         [~, names, exts] = fileparts(Requirements.missingFiles);
         returned = sort(names + exts);
         expected = ["grft_dep1.m"; "grft_dep2.m"];
         testCase.verifyEqual(reshape(returned, [], 1), expected)
      end

      function testReferenceSatisfiesRequirements(testCase)
         % When the local source tree itself is the reference, every
         % requirement is already satisfied.
         Requirements = getRequiredFiles(testCase.projFolder, ...
            "referenceList", testCase.localSource);
         returned = Requirements.missingFiles;
         expected = strings(0, 1);
         testCase.verifyEqual(reshape(returned, [], 1), expected)
      end

      function testSaveRequirementsFileWritesMat(testCase)
         % saveRequirementsFile writes the .mat file installRequiredFiles'
         % requirementsFile input reads back.
         matFile = fullfile(tempname() + ".mat");
         cleanup = onCleanup(@() delete(matFile));

         getRequiredFiles(testCase.projFolder, ...
            "referenceList", testCase.projFolder, ...
            "requirementsFileName", matFile, ...
            "saveRequirementsFile", true);

         testCase.verifyTrue(isfile(matFile))
         vars = load(matFile);
         testCase.verifyTrue(isfield(vars, "missingFiles"))
         testCase.verifyTrue(isfield(vars, "requiredFiles"))
      end
   end
end
