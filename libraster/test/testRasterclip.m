classdef testRasterclip < matlab.unittest.TestCase
   %TESTRASTERCLIP Tests for rasterclip (clip a raster by a polygon geostruct).

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
      function testInOnMaskSizesAndContents(testCase)
         [Xg, Yg] = meshgrid(0:10:100, 50:-10:0);
         R = rasterref(Xg, Yg, 'UseGeoCoords', false, 'silent', true);

         % A closed box polygon (as an X/Y geostruct) covering part of the grid.
         shp = struct('X', [20 20 60 60 20], 'Y', [10 40 40 10 10]);
         [in, on] = rasterclip(R, shp);

         ncells = R.RasterSize(1) * R.RasterSize(2);
         testCase.verifyEqual(numel(in), ncells);
         testCase.verifyEqual(numel(on), ncells);
         testCase.verifyTrue(islogical(in) || isnumeric(in));
         testCase.verifyTrue(any(in(:)));            % some cells inside
         testCase.verifyFalse(all(in(:)));           % not the whole grid
      end
   end
end
