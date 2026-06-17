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

      function testReferenceObjectInput(testCase)
         % Folded in from the legacy test_plotraster script: plotraster(Z, R).
         [Z, R] = testCase.defaultData();
         H = plotraster(Z, R, testCase.TestAxes);
         testCase.verifyEqual(H.Parent, testCase.TestAxes);
      end

      function testReferenceObjectInputWithAxisType(testCase)
         [Z, R] = testCase.defaultData();
         H = plotraster(Z, R, testCase.TestAxes, "equal");
         testCase.verifyEqual(H.Parent, testCase.TestAxes);
         testCase.verifyEqual(testCase.TestAxes.DataAspectRatio, [1 1 1]);
      end

      function testReferenceObjectStyleBeforeAxes(testCase)
         [Z, R] = testCase.defaultData();
         H = plotraster(Z, R, "normal", testCase.TestAxes);
         testCase.verifyEqual(H.Parent, testCase.TestAxes);
      end
   end

   methods (Access = private)
      function [Z, R, X, Y] = defaultData(testCase)
         % Default gridded data from defaultGridData (derived from
         % example_cells.tif). Skip the referencing-object tests when the Mapping
         % Toolbox or the example raster are unavailable, rather than failing.
         testCase.assumeTrue(license('test', 'map_toolbox') == 1, ...
            'Mapping Toolbox required for referencing-object tests.');
         testCase.assumeFalse(isempty(which('example_cells.tif')), ...
            'example_cells.tif not found on the path.');
         [X, Y, Z, R] = defaultGridData();
      end
   end
end
