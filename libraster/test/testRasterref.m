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

      function testPlanarNonIntegerCentersNotRounded(testCase)
         % Regression (matfunclib-43n): planar cell centres with NON-integer
         % coordinates (e.g. UTM metres) must not be snapped to integers. The old
         % round(min(X),0) shifted the limits ~half a cell; existing integer-grid
         % tests (0:10:100) could not catch it.
         x = 500123.5:250:501123.5;        % 250 m cells, fractional origin
         y = 4500077.25:-250:4499077.25;
         [X, Y] = meshgrid(x, y);
         R = rasterref(X, Y, 'UseGeoCoords', false, 'silent', true);
         % limits are the centres padded exactly half a cell (125 m), unrounded
         testCase.verifyEqual(R.XWorldLimits, [min(x)-125, max(x)+125], 'AbsTol', 1e-6);
         testCase.verifyEqual(R.YWorldLimits, [min(y)-125, max(y)+125], 'AbsTol', 1e-6);
         % and the centres round-trip exactly
         [Xr, Yr] = R2grid(R);
         testCase.verifyEqual(unique(Xr(:)), x(:), 'AbsTol', 1e-6);
         testCase.verifyEqual(unique(Yr(:)), sort(y(:)), 'AbsTol', 1e-6);
      end

      % ===================== real-world coverage =====================
      % Each builds R from cell centres and requires the centres to round-trip
      % through R2grid (the core "faithful referencing" contract). reltol scales
      % with coordinate magnitude (UTM coords are ~1e6).

      % ---- geographic (non pole-touching: edges stay within +/-90) ----
      function testGeoGlobal1deg(testCase)
         testCase.verifyRoundTrip(-179.5:1:179.5, 89.5:-1:-89.5, true);
      end
      function testGeoMerraGridNonPole(testCase)
         % MERRA-2 spacing 0.5 lat x 0.625 lon, latitude kept off the poles.
         testCase.verifyRoundTrip(-180:0.625:179.375, -89.75:0.5:89.75, true);
      end
      function testGeo0to360Longitude(testCase)
         testCase.verifyRoundTrip(0.5:1:359.5, -89.5:1:89.5, true);
      end
      function testGeoRegionalFractional(testCase)
         testCase.verifyRoundTrip(-50:0.05:-40, 60:0.05:70, true);
      end
      function testGeoSouthToNorthInputReoriented(testCase)
         % latitude given S->N must be reoriented and still round-trip.
         testCase.verifyRoundTrip(0:0.25:10, 0:0.25:10, true);
      end

      % ---- projected / planar (the rounding-removal guards) ----
      function testPlanarUTM30m(testCase)
         testCase.verifyRoundTrip((5e5+15.5):30:(5e5+3015.5), ...
            (4e6+7.25):30:(4e6+3007.25), false);
      end
      function testPlanarPolarStereoNegative(testCase)
         testCase.verifyRoundTrip(-3e5:1.5e4:3e5, -2.4e6:1.5e4:-1.8e6, false);
      end
      function testPlanarSubUnitCells(testCase)
         testCase.verifyRoundTrip(100.25:0.5:150.25, 200.75:0.5:250.75, false);
      end
      function testPlanarFloat32StorageNoise(testCase)
         % float32 jitter must NOT defeat the (now unrounded) limits: the centres
         % still round-trip. This is the case the old integer-rounding could not
         % have helped (it would have destroyed the 30 m cell size).
         x = double(single(500000:30:503000));
         y = double(single(4000000:30:4003000));
         testCase.verifyRoundTrip(x, y, false);
      end

      % ---- postings: verify via worldGrid (R2grid rejects postings, see
      %      matfunclib-sib) ----
      function testGeoPostingsRoundTripViaGeographicGrid(testCase)
         % geographic refs use geographicGrid (returns lat,lon), not worldGrid.
         [X, Y] = meshgrid(0:0.5:10, 10:-0.5:0);
         R = rasterref(X, Y, 'UseGeoCoords', true, 'silent', true, ...
            'cellInterpretation', 'postings');
         [LatW, LonW] = geographicGrid(R);
         testCase.verifyEqual(unique(LonW(:)), (0:0.5:10).', 'AbsTol', 1e-9);
         testCase.verifyEqual(unique(LatW(:)), (0:0.5:10).', 'AbsTol', 1e-9);
      end
      function testPlanarPostingsRoundTripViaWorldGrid(testCase)
         [X, Y] = meshgrid(10.5:5:110.5, 120.5:-5:20.5);
         R = rasterref(X, Y, 'UseGeoCoords', false, 'silent', true, ...
            'cellInterpretation', 'postings');
         [Xw, Yw] = worldGrid(R);
         testCase.verifyEqual(unique(Xw(:)), (10.5:5:110.5).', 'AbsTol', 1e-9);
         testCase.verifyEqual(unique(Yw(:)), (20.5:5:120.5).', 'AbsTol', 1e-9);
      end

      % ---- characterization of known limitations (pin current behavior) ----
      function testPoleTouchingClampsLatLimits(testCase)
         % matfunclib-m0x: a grid whose CENTRES reach +/-90 is geometrically
         % impossible as cells (the edge would pass the pole). rasterref clamps the
         % latitude limits to [-90,90] and builds R without error -- but the polar
         % cells are then distorted, so the round-trip is LOSSY at the poles. Pin
         % the clamp behavior here until the design decision in m0x is made.
         [X, Y] = meshgrid(-180:0.625:179.375, -90:0.5:90);
         R = rasterref(X, Y, 'UseGeoCoords', true, 'silent', true);
         testCase.verifyEqual(R.LatitudeLimits, [-90 90]);
      end
      function testR2gridAcceptsPostings(testCase)
         % matfunclib-sib (FIXED): R2grid now accepts postings references and
         % recovers the posting positions (was: errored, rejected postings).
         [X, Y] = meshgrid(0:0.5:10, 10:-0.5:0);
         R = rasterref(X, Y, 'UseGeoCoords', true, 'silent', true, ...
            'cellInterpretation', 'postings');
         [Xg, Yg] = R2grid(R);
         testCase.verifyEqual(unique(Xg(:)), (0:0.5:10).', 'AbsTol', 1e-9);
         testCase.verifyEqual(unique(Yg(:)), (0:0.5:10).', 'AbsTol', 1e-9);
      end
   end

   methods
      function verifyRoundTrip(testCase, x, y, useGeo)
         % Build R from cell centres x,y and require R2grid to recover them.
         [X, Y] = meshgrid(x, y);
         R = rasterref(X, Y, 'UseGeoCoords', useGeo, 'silent', true);
         [Xr, Yr] = R2grid(R);
         scale = max(1, max(abs([x(:); y(:)])));
         testCase.verifyEqual(unique(Xr(:)), unique(x(:)), 'AbsTol', 1e-6*scale);
         testCase.verifyEqual(unique(Yr(:)), unique(y(:)), 'AbsTol', 1e-6*scale);
      end
   end
end
