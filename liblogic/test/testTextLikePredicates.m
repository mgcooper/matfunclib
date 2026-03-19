classdef testTextLikePredicates < matlab.unittest.TestCase

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

   methods (Test)
      function testIstextlikeAcceptsMixedTextCellArrays(testCase)
         testCase.verifyTrue(istextlike({'a', "b"}));
         testCase.verifyTrue(istextlike({'a'; 'b'}));
      end

      function testIstextlikeRejectsMixedTextAndNontextCellArrays(testCase)
         testCase.verifyFalse(istextlike({'a', 1}));
         testCase.verifyFalse(istextlike({"a", missing}));
      end

      function testEachModeReturnsElementwiseResults(testCase)
         returned = istextlike({'a', 1, "b"}, 'each');
         testCase.verifyEqual(returned, [true false true]);
      end

      function testNontrivialModeRejectsBlankStringValues(testCase)
         testCase.verifyFalse(istextlike("", 'nontrivial'));
         testCase.verifyFalse(ischarlike("", 'nontrivial'));
      end

      function testIscharlikeRemainsCompatibilityAlias(testCase)
         cases = { ...
            'a', ...
            "", ...
            string.empty(0, 0), ...
            {'a', "b"}, ...
            {'a', 1}, ...
            {'', ""}};

         returned = cellfun(@(value) ischarlike(value) == istextlike(value), ...
            cases);
         testCase.verifyTrue(all(returned));
      end
   end
end
