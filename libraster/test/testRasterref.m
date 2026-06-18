classdef testRasterref < matlab.unittest.TestCase
   %TESTRASTERREF Tests for rasterref cell/posting conventions and pole handling.
   %
   % Uses MATLAB's own intrinsicToWorld (not the project's R2grid) so the
   % center/edge convention is checked independently of rasterref's own helpers.
   % Planar cases set UseGeoCoords=false to avoid geographic auto-detection.

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture
         testFolder = fileparts(mfilename("fullpath"));
         projectFolder = fileparts(fileparts(testFolder));
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (Test)
      function testCellsPlacesCentersAtData(testCase)
         % Default 'cells': X,Y are cell centers, so R's limits are padded half a
         % cell and the cell-center of (1,1) equals the first data coordinate.
         [X, Y] = meshgrid(0:10:100, 50:-10:0);
         R = rasterref(X, Y, 'UseGeoCoords', false, 'silent', true);
         testCase.verifyEqual(R.XWorldLimits, [-5 105]);
         testCase.verifyEqual(R.YWorldLimits, [-5 55]);
         [xw, yw] = intrinsicToWorld(R, 1, 1);
         testCase.verifyEqual([xw yw], [0 50], 'AbsTol', 1e-9);
      end

      function testCellsRoundTrip(testCase)
         % centers -> R -> recovered centers must be exact.
         [X, Y] = meshgrid(0:10:100, 50:-10:0);
         R = rasterref(X, Y, 'UseGeoCoords', false, 'silent', true);
         [Xr, Yr] = R2grid(R);
         testCase.verifyEqual(unique(Xr(:)), (0:10:100).', 'AbsTol', 1e-9);
         testCase.verifyEqual(unique(Yr(:)), (0:10:50).', 'AbsTol', 1e-9);
      end

      function testPostingsNoHalfCellPad(testCase)
         % 'postings': X,Y are the sample positions, so R limits equal the data
         % extent (no half-cell pad) and posting (1,1) equals the first data point.
         [X, Y] = meshgrid(0:10:100, 50:-10:0);
         R = rasterref(X, Y, 'UseGeoCoords', false, 'silent', true, ...
            'cellInterpretation', 'postings');
         testCase.verifyEqual(R.XWorldLimits, [0 100]);
         testCase.verifyEqual(R.YWorldLimits, [0 50]);
         [xw, yw] = intrinsicToWorld(R, 1, 1);
         testCase.verifyEqual([xw yw], [0 50], 'AbsTol', 1e-9);
      end

      function testGeographicPoleGridDoesNotError(testCase)
         % A global geographic grid whose cells reach +/-90 must build without
         % error; latitude limits are clamped to [-90, 90].
         [X, Y] = meshgrid(-180:10:170, 90:-10:-90);
         R = rasterref(X, Y, 'UseGeoCoords', true, 'silent', true);
         testCase.verifyEqual(R.LatitudeLimits, [-90 90]);
      end
   end
end
