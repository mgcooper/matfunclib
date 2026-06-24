classdef testGridCoordFamily < matlab.unittest.TestCase
   %TESTGRIDCOORDFAMILY R-object / grid-coordinate conversion family.
   %
   % Covers R2grid, R2grat, grid2R, bbox2R, gridvec/fullgrid, gridNodesToEdges --
   % the util/ family that had NO test coverage, which let R2grat rot (it called
   % the removed meshgrat). The R2grid/R2grat agreement test is the regression
   % guard for that fix (matfunclib-4c5). grid2R is covered for the half-cell
   % round-trip it used to fail (matfunclib-eg3).

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture
         testFolder = fileparts(mfilename("fullpath"));
         projectFolder = fileparts(fileparts(testFolder));
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (Static)
      function [X, Y, R] = planarGrid()
         [X, Y] = meshgrid(0:10:100, 50:-10:0);
         R = rasterref(X, Y, 'UseGeoCoords', false, 'silent', true);
      end
      function [X, Y, R] = geoGrid()
         [X, Y] = meshgrid(-50:0.5:-40, 60:-0.5:50);
         R = rasterref(X, Y, 'UseGeoCoords', true, 'silent', true);
      end
   end

   methods (Test)
      % ---- R2grid ----
      function testR2gridRecoversCentersPlanar(testCase)
         [X, Y, R] = testGridCoordFamily.planarGrid();
         [Xg, Yg] = R2grid(R);
         testCase.verifyEqual(unique(Xg(:)), unique(X(:)), 'AbsTol', 1e-9);
         testCase.verifyEqual(unique(Yg(:)), unique(Y(:)), 'AbsTol', 1e-9);
      end
      function testR2gridRecoversCentersGeo(testCase)
         [X, Y, R] = testGridCoordFamily.geoGrid();
         [Xg, Yg] = R2grid(R);
         testCase.verifyEqual(unique(Xg(:)), unique(X(:)), 'AbsTol', 1e-9);
         testCase.verifyEqual(unique(Yg(:)), unique(Y(:)), 'AbsTol', 1e-9);
      end

      % ---- R2grat (regression: meshgrat removal) ----
      function testR2gratRunsAndMatchesR2gridPlanar(testCase)
         [X, ~, R] = testGridCoordFamily.planarGrid();
         [Xt, Yt] = R2grat(R);
         [Xg, Yg] = R2grid(R);
         testCase.verifyEqual(size(Xt), size(X));
         testCase.verifyEqual(Xt, Xg, 'AbsTol', 1e-9);
         testCase.verifyEqual(Yt, Yg, 'AbsTol', 1e-9);
      end
      function testR2gratRunsAndMatchesR2gridGeo(testCase)
         [X, ~, R] = testGridCoordFamily.geoGrid();
         [Xt, Yt] = R2grat(R);
         [Xg, Yg] = R2grid(R);
         testCase.verifyEqual(size(Xt), size(X));
         testCase.verifyEqual(Xt, Xg, 'AbsTol', 1e-9);
         testCase.verifyEqual(Yt, Yg, 'AbsTol', 1e-9);
      end

      % ---- grid2R round-trips through R2grid ----
      function testGrid2RRoundTrip(testCase)
         [X, Y] = meshgrid(0:10:100, 50:-10:0);
         R = grid2R(X, Y);
         testCase.verifyTrue(isobject(R));
         testCase.verifyEqual(R.RasterSize, size(X));
         [Xg, Yg] = R2grid(R);
         testCase.verifyEqual(unique(Xg(:)), unique(X(:)), 'AbsTol', 1e-9);
         testCase.verifyEqual(unique(Yg(:)), unique(Y(:)), 'AbsTol', 1e-9);
      end

      % ---- bbox2R ----
      function testBbox2RLimits(testCase)
         % bbox bounds the outer EDGES (correct for a bounding box). Use planar
         % UTM-magnitude coords so the islatlon detector classifies it planar
         % (small ambiguous boxes go geographic -- see matfunclib-a65).
         R = bbox2R([5e5 4e6; 5.1e5 4.05e6], 1000);  % [minX minY; maxX maxY]
         testCase.verifyEqual(R.XWorldLimits, [5e5 5.1e5], 'AbsTol', 1e-6);
         testCase.verifyEqual(R.YWorldLimits, [4e6 4.05e6], 'AbsTol', 1e-6);
      end

      % ---- gridvec <-> fullgrid ----
      function testGridvecFullgridRoundTrip(testCase)
         [X, Y] = meshgrid(0:10:100, 50:-10:0);
         [xv, yv] = gridvec(X, Y);
         [Xf, Yf] = fullgrid(xv, yv);
         testCase.verifyEqual(size(Xf), size(X));
         testCase.verifyEqual(unique(Xf(:)), unique(X(:)), 'AbsTol', 1e-9);
         testCase.verifyEqual(unique(Yf(:)), unique(Y(:)), 'AbsTol', 1e-9);
      end

      % ---- gridNodesToEdges ----
      function testGridNodesToEdgesBracketsCenters(testCase)
         [X, Y] = meshgrid(0:10:100, 50:-10:0);
         [Xe, Ye] = gridNodesToEdges(X, Y);
         testCase.verifyEqual(size(Xe), size(X) + 1);
         testCase.verifyEqual(size(Ye), size(Y) + 1);
         % edges extend half a cell beyond the centre extent
         testCase.verifyEqual(min(Xe(:)), min(X(:)) - 5, 'AbsTol', 1e-9);
         testCase.verifyEqual(max(Xe(:)), max(X(:)) + 5, 'AbsTol', 1e-9);
      end
   end
end
