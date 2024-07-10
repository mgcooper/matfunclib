classdef testPlotRaster < matlab.unittest.TestCase

   % I did not finish this. See the script-based test test_plotraster.

   properties
      TestData
      TestFigure
      TestFigureAxes
   end

   methods(TestMethodSetup)
      function createFigure(testCase)
         testCase.TestFigure = figure;
         testCase.TestFigureAxes = gca(testCase.TestFigure);
      end

      function createTestData(testCase)
         [X, Y, Z, R] = defaultGridData();
         testCase.TestData.X = X;
         testCase.TestData.Y = Y;
         testCase.TestData.Z = Z;
         testCase.TestData.R = R;
      end
   end

   methods(TestMethodTeardown)
      function closeFigure(testCase)
         close(testCase.TestFigure)
      end
   end

   methods (Test)

      function testZInput(testCase)

         plotraster(testCase.TestData.Z, ...
            testCase.TestFigureAxes)

      end

      function testZRInput(testCase)

         plotraster(testCase.TestData.Z, testCase.TestData.R, ...
            testCase.TestFigureAxes)

      end

      function testZXYInput(testCase)

         plotraster(testCase.TestData.Z, testCase.TestData.X, ...
            testCase.TestData.Y, ...
            testCase.TestFigureAxes)
      end
   end
end
