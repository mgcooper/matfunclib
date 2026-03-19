classdef testSqmi2Sqft < matlab.unittest.TestCase

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
      function testScalarConversion(testCase)
         testCase.verifyConversion(1, 27878400);
      end

      function testArrayConversion(testCase)
         sqmi = [0, 0.5, 2];
         expected = [0, 13939200, 55756800];
         testCase.verifyConversion(sqmi, expected);
      end
   end

   methods (Access = private)
      function verifyConversion(testCase, sqmi, expected)
         returned = sqmi2sqft(sqmi);
         testCase.verifyEqual(returned, expected);
      end
   end
end
