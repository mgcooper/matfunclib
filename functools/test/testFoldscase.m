classdef testFoldscase < matlab.unittest.TestCase
   %TESTFOLDSCASE Unit tests for functools/foldscase.

   properties
      folder string
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
      function makeFolder(testCase)
         import matlab.unittest.fixtures.TemporaryFolderFixture
         tmp = testCase.applyFixture(TemporaryFolderFixture);
         testCase.folder = string(tmp.Folder);
      end
   end

   methods (Test)
      function testAnswerMatchesTheVolume(testCase)
         % The probe agrees with a direct check of the same volume: the
         % volume finds a file written in one case under the other case
         % only where it folds. A file target and a folder target answer
         % the same, and the probe leaves no folder behind.
         file = fullfile(testCase.folder, "probe.txt");
         writelines("x", file)
         expected = isfile(fullfile(testCase.folder, "PROBE.TXT"));
         returned = foldscase(file);
         testCase.verifyEqual(returned, expected)
         returned = foldscase(testCase.folder);
         testCase.verifyEqual(returned, expected)
         listing = dir(testCase.folder);
         returned = {listing(~ismember({listing.name}, {'.', '..'})).name};
         expected = {'probe.txt'};
         testCase.verifyEqual(returned, expected)
      end

      function testTwoCaseVariantsDoNotFoolTheProbe(testCase)
         % Two entries whose names differ only by case exist only on a
         % case-sensitive volume. The fresh probe answers false there and
         % does not read the pair as folding.
         lowerFile = fullfile(testCase.folder, "pair.txt");
         writelines("a", lowerFile)
         if isfile(fullfile(testCase.folder, "PAIR.TXT"))
            % A folding volume cannot hold the pair; the probe says so.
            returned = foldscase(lowerFile);
            expected = true;
         else
            writelines("b", fullfile(testCase.folder, "PAIR.TXT"))
            returned = foldscase(lowerFile);
            expected = false;
         end
         testCase.verifyEqual(returned, expected)
      end

      function testBareRelativeNameProbesTheCurrentFolder(testCase)
         % A bare file name has no folder part, so foldscase probes the
         % current folder and the answer equals that folder's own.
         import matlab.unittest.fixtures.CurrentFolderFixture
         testCase.applyFixture(CurrentFolderFixture(testCase.folder));
         returned = foldscase("bare.txt");
         expected = foldscase(pwd);
         testCase.verifyEqual(returned, expected)
      end

      function testNestedRelativeMissingPathProbesTheCurrentFolder(testCase)
         % A relative path whose folders do not exist yet walks down to
         % nothing, so foldscase answers from the current folder.
         import matlab.unittest.fixtures.CurrentFolderFixture
         testCase.applyFixture(CurrentFolderFixture(testCase.folder));
         returned = foldscase(fullfile("new", "deps", "file.m"));
         expected = foldscase(pwd);
         testCase.verifyEqual(returned, expected)
      end

      function testMissingTargetProbesTheNearestAncestor(testCase)
         % foldscase answers a destination that does not exist yet from
         % the nearest existing ancestor, which an install dry run needs.
         missing = fullfile(testCase.folder, "not", "yet", "here");
         returned = foldscase(missing);
         expected = foldscase(testCase.folder);
         testCase.verifyEqual(returned, expected)
      end

      function testUnwritableFolderUsesTheHostConvention(testCase)
         % The file-system root exists but a user cannot write it, so the
         % host convention answers.
         returned = foldscase(fullfile(filesep, "no_such_root_xyz", "a"));
         expected = ispc || ismac;
         testCase.verifyEqual(returned, expected)
      end
   end
end
