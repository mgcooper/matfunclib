classdef testTextValidators < matlab.unittest.TestCase

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
      function testContainsOnlyTextAcceptsMixedCharStringCells(testCase)
         testCase.verifyTrue(containsOnlyText({'a', "b"}));
      end

      function testContainsOnlyTextRejectsNontextCellContents(testCase)
         testCase.verifyFalse(containsOnlyText({'a', 1}));
      end

      function testMustContainOnlyTextMatchesPredicate(testCase)
         testCase.verifyWarningFree(@() mustContainOnlyText({'a', "b"}));
         testCase.verifyError(@() mustContainOnlyText({'a', 1}), ...
            'custom:validators:mustContainOnlyText');
      end

      function testMustBeTextScalarOrEmptyAllowsEmptyInputs(testCase)
         testCase.verifyWarningFree(@() mustBeTextScalarOrEmpty(''));
         testCase.verifyWarningFree(@() mustBeTextScalarOrEmpty(""));
         testCase.verifyWarningFree(@() mustBeTextScalarOrEmpty([]));
      end

      function testMustBeTextScalarOrEmptyRejectsNonscalarTextContainers(testCase)
         testCase.verifyError(@() mustBeTextScalarOrEmpty(["a", "b"]), ...
            'custom:validators:mustBeTextScalarOrEmpty');
         testCase.verifyError(@() mustBeTextScalarOrEmpty({'a'}), ...
            'custom:validators:mustBeTextScalarOrEmpty');
      end
   end
end
