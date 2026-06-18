classdef testRasterinterp < matlab.unittest.TestCase
   %TESTRASTERINTERP Tests for rasterinterp (interpolate a raster to a new grid).

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
      function testInterpToFinerGridMatchesRq(testCase)
         [Xg, Yg] = meshgrid(0:10:100, 50:-10:0);
         R = rasterref(Xg, Yg, 'UseGeoCoords', false, 'silent', true);
         V = Xg + Yg;                    % a linear field

         [Xq, Yq] = meshgrid(0:5:100, 50:-5:0);   % finer query grid
         Rq = rasterref(Xq, Yq, 'UseGeoCoords', false, 'silent', true);

         [Vq, ~] = rasterinterp(V, R, Rq);

         testCase.verifyEqual(size(Vq), Rq.RasterSize);
         % A linear field interpolates to itself at interior query points.
         testCase.verifyEqual(Vq(3, 3), Xq(3, 3) + Yq(3, 3), 'AbsTol', 1e-6);
      end
   end
end
