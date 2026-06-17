classdef testRastercrop < matlab.unittest.TestCase
   %TESTRASTERCROP Tests for rastercrop (crop a raster to x/y limits).

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture
         testFolder = fileparts(mfilename("fullpath"));
         projectFolder = fileparts(fileparts(testFolder));
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
         testCase.assumeTrue(license('test', 'map_toolbox') == 1, ...
            'Mapping Toolbox required.');
      end
   end

   methods (Test)
      function testCropToLimitsShrinksRaster(testCase)
         [Xg, Yg] = meshgrid(0:10:100, 50:-10:0);
         R = rasterref(Xg, Yg, 'UseGeoCoords', false, 'silent', true);
         Z = Xg + Yg;

         [Z2, R2] = rastercrop(Z, R, [20 60], [10 40]);

         testCase.verifyLessThanOrEqual(numel(Z2), numel(Z));
         testCase.verifyTrue(any(Z2(:) > 0));
         testCase.verifyEqual(size(Z2), R2.RasterSize);
      end
   end
end
