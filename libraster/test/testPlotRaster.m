classdef testPlotRaster < matlab.unittest.TestCase

   properties
      TestFigure
      TestAxes
      TestData
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
      function createFigure(testCase)
         testCase.TestFigure = figure("Visible", "off");
         testCase.addTeardown(@close, testCase.TestFigure);
         testCase.TestAxes = axes("Parent", testCase.TestFigure);
      end

      function createTestData(testCase)
         testCase.TestData.X = [10, 20, 30];
         testCase.TestData.Y = [4; 3; 2];
         testCase.TestData.Z = reshape(1:9, 3, 3);
      end
   end

   methods (Test)
      function testAxesFirstSyntax(testCase)
         H = plotraster(testCase.TestAxes, testCase.TestData.Z);

         testCase.verifyEqual(H.Parent, testCase.TestAxes);
         testCase.verifyEqual(H.CData, testCase.TestData.Z);
         testCase.verifyEqual(testCase.TestAxes.YDir, 'normal');
      end

      function testAxesLastSyntaxStillWorks(testCase)
         H = plotraster(testCase.TestData.Z, testCase.TestAxes, "equal");

         testCase.verifyEqual(H.Parent, testCase.TestAxes);
         testCase.verifyEqual(testCase.TestAxes.DataAspectRatio, [1 1 1]);
      end

      function testStyleCanPrecedeAxesHandle(testCase)
         H = plotraster(testCase.TestData.Z, "normal", testCase.TestAxes);

         testCase.verifyEqual(H.Parent, testCase.TestAxes);
      end

      function testGridVectorsSetImageExtents(testCase)
         H = plotraster(testCase.TestAxes, testCase.TestData.Z, ...
            testCase.TestData.X, testCase.TestData.Y);

         testCase.verifyEqual(H.XData, [10 30]);
         testCase.verifyEqual(H.YData, [4 2]);
      end

      function testValidateGridDataUsesProvidedValueArgName(testCase)
         try
            validateGridData("bad", [0 1], [1 0], ...
               "plotraster", "RasterValues", "X", "Y");
            testCase.assertFail("validateGridData did not throw an error.");
         catch ME
            testCase.verifyTrue(contains(ME.message, "RasterValues"));
         end
      end
   end
end
