classdef testGridVectorsAndMembership < matlab.unittest.TestCase
   %TESTGRIDVECTORSANDMEMBERSHIP Grid-vector, corner, and membership family.
   %
   % Covers the util/ helpers that build axis grid vectors and full grids
   % (xgridvec, ygridvec, xfullgrid, yfullgrid), derive cell corners
   % (gridCellCorners), centroid coordinates (gridCoords), grid membership
   % (gridmember), nearest-node lookup (nearestGridPoint), and grid-frame
   % geometry (imageSizeInXY, mapGridOutline) -- none of which had test
   % coverage. The orientation conventions (X ascending W-E, Y descending N-S
   % per the north-up image convention the headers document) are the invariants
   % guarded here.

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
      function [X, Y] = planarGrid()
         % E-W ascending, N-S descending centers (image convention).
         [X, Y] = meshgrid(0:10:100, 50:-10:0);
      end
   end

   methods (Test)
      % ---- xgridvec / ygridvec axis orientation ----
      function testXgridvecAscendingRow(testCase)
         [X, ~] = testGridVectorsAndMembership.planarGrid();
         xv = xgridvec(X);
         testCase.verifyEqual(xv, 0:10:100, 'AbsTol', 1e-9);
         testCase.verifyEqual(size(xv, 1), 1);          % row vector
         testCase.verifyTrue(issorted(xv, 'ascend'));    % W-E ascending
      end

      function testYgridvecDescendingColumn(testCase)
         [~, Y] = testGridVectorsAndMembership.planarGrid();
         yv = ygridvec(Y);
         testCase.verifyEqual(yv, (50:-10:0).', 'AbsTol', 1e-9);
         testCase.verifyEqual(size(yv, 2), 1);          % column vector
         testCase.verifyTrue(issorted(yv, 'descend'));   % N-S descending
      end

      function testGridvecsDropDuplicates(testCase)
         % Repeated coordinates collapse to the unique sorted axis.
         X = [3 1 2 1 3 2];
         testCase.verifyEqual(xgridvec(X), [1 2 3], 'AbsTol', 1e-9);
      end

      % ---- xfullgrid / yfullgrid rebuild the full grid ----
      function testFullgridRebuildsColumns(testCase)
         [X, Y] = testGridVectorsAndMembership.planarGrid();
         Xf = xfullgrid(X, Y);
         Yf = yfullgrid(X, Y);
         testCase.verifyEqual(size(Xf), size(X));
         testCase.verifyEqual(size(Yf), size(Y));
         % meshgrid layout: each row of Xf is the ascending x axis,
         % each column of Yf is the descending y axis.
         testCase.verifyEqual(Xf, repmat(0:10:100, 6, 1), 'AbsTol', 1e-9);
         testCase.verifyEqual(Yf, repmat((50:-10:0).', 1, 11), 'AbsTol', 1e-9);
      end

      function testFullgridFromGridVectors(testCase)
         % Passing axis vectors reconstructs the same full grid.
         xv = 0:10:100;
         yv = (50:-10:0).';
         Xf = xfullgrid(xv, yv);
         Yf = yfullgrid(xv, yv);
         testCase.verifyEqual(size(Xf), [6 11]);
         testCase.verifyEqual(size(Yf), [6 11]);
         testCase.verifyEqual(unique(Xf(:)).', 0:10:100, 'AbsTol', 1e-9);
         testCase.verifyEqual(unique(Yf(:)), (0:10:50).', 'AbsTol', 1e-9);
      end

      function testFullgridGridvectorsOption(testCase)
         % 'gridvectors' option returns the axis vector, not the full grid.
         [X, Y] = testGridVectorsAndMembership.planarGrid();
         xv = xfullgrid(X, Y, 'gridvectors');
         yv = yfullgrid(X, Y, 'gridvectors');
         testCase.verifyEqual(xv, 0:10:100, 'AbsTol', 1e-9);
         testCase.verifyEqual(yv, (50:-10:0).', 'AbsTol', 1e-9);
      end

      % ---- gridCellCorners ----
      function testGridCellCornersHalfCellOffsets(testCase)
         % 4 corners offset by +/- half cell from each center.
         X = [0; 10];
         Y = [50; 40];
         dx = 10; dy = 10;
         [XV, YV] = gridCellCorners(X, Y, dx, dy);
         testCase.verifyEqual(size(XV), [2 4]);
         testCase.verifyEqual(size(YV), [2 4]);
         % cw layout from header: X offsets [-,-,+,+]/2, Y offsets [-,+,+,-]/2
         testCase.verifyEqual(XV(1, :), [-5 -5 5 5], 'AbsTol', 1e-9);
         testCase.verifyEqual(YV(1, :), [45 55 55 45], 'AbsTol', 1e-9);
         % Each row spans exactly one cell in each direction.
         testCase.verifyEqual(max(XV(1, :)) - min(XV(1, :)), dx, 'AbsTol', 1e-9);
         testCase.verifyEqual(max(YV(1, :)) - min(YV(1, :)), dy, 'AbsTol', 1e-9);
      end

      function testGridCellCornersCentroidIsCenter(testCase)
         % Mean of the 4 corners returns the cell center.
         X = [0; 10]; Y = [50; 40];
         [XV, YV] = gridCellCorners(X, Y, 10, 10);
         testCase.verifyEqual(mean(XV, 2), X, 'AbsTol', 1e-9);
         testCase.verifyEqual(mean(YV, 2), Y, 'AbsTol', 1e-9);
      end

      % ---- gridCoords ----
      function testGridCoordsCentroids(testCase)
         % Centroid x/y of each cell: lower-left corner + (k - 0.5)*cellsize.
         [x, y] = gridCoords(3, 4, 100, 200, 10);
         testCase.verifyEqual(x, 100 + ((1:4) * 10 - 5), 'AbsTol', 1e-9);
         testCase.verifyEqual(y, 200 + ((1:3) * 10 - 5), 'AbsTol', 1e-9);
         % First centroid is half a cell in from the lower-left origin.
         testCase.verifyEqual(x(1), 105, 'AbsTol', 1e-9);
         testCase.verifyEqual(y(1), 205, 'AbsTol', 1e-9);
      end

      % ---- gridmember ----
      function testGridmemberAllPresent(testCase)
         % Identical grids: every X2,Y2 pair is a member of X1,Y1.
         [X, Y] = testGridVectorsAndMembership.planarGrid();
         [LI2, LOC1] = gridmember(X, Y, X, Y);
         testCase.verifyEqual(size(LI2), size(X)); % reshaped to X2 shape
         testCase.verifyTrue(all(LI2(:)));
         testCase.verifyTrue(all(LOC1 > 0));
      end

      function testGridmemberDroppedNode(testCase)
         % Drop one node from the target grid (X1,Y1). gridmember should mark
         % that pixel false in LI2 (relative to the full grid X2,Y2) and 0 in
         % LOC1; every other pixel stays true.
         [X, Y] = testGridVectorsAndMembership.planarGrid();
         X2 = X(:); Y2 = Y(:);
         drop = 7;                                   % an arbitrary interior node
         keep = true(numel(X2), 1); keep(drop) = false;
         X1 = X2(keep); Y1 = Y2(keep);
         [LI2, LOC1] = gridmember(X2, Y2, X1, Y1);
         testCase.verifyEqual(nnz(~LI2), 1);          % exactly one missing
         testCase.verifyFalse(LI2(drop));             % the dropped node
         testCase.verifyEqual(LOC1(drop), 0);         % no source index
         testCase.verifyEqual(nnz(LI2), numel(X2) - 1);
         % LOC1 indexes into X1,Y1 for the kept pixels.
         present = find(LI2);
         testCase.verifyEqual(X1(LOC1(present)), X2(present), 'AbsTol', 1e-9);
         testCase.verifyEqual(Y1(LOC1(present)), Y2(present), 'AbsTol', 1e-9);
      end

      % ---- nearestGridPoint ----
      function testNearestGridPointFindsClosest(testCase)
         [X, Y] = testGridVectorsAndMembership.planarGrid();
         % Query near center (30, 20) with a small offset.
         [row, col, dist] = nearestGridPoint(X, Y, 31, 19);
         testCase.verifyEqual(X(row, col), 30, 'AbsTol', 1e-9);
         testCase.verifyEqual(Y(row, col), 20, 'AbsTol', 1e-9);
         testCase.verifyEqual(dist, sqrt(1^2 + 1^2), 'AbsTol', 1e-9);
      end

      function testNearestGridPointExactNodeZeroDist(testCase)
         [X, Y] = testGridVectorsAndMembership.planarGrid();
         [row, col, dist] = nearestGridPoint(X, Y, 50, 30);
         testCase.verifyEqual(dist, 0, 'AbsTol', 1e-9);
         testCase.verifyEqual(X(row, col), 50, 'AbsTol', 1e-9);
         testCase.verifyEqual(Y(row, col), 30, 'AbsTol', 1e-9);
      end

      % ---- mapGridOutline ----
      function testMapGridOutlineExtendsHalfCell(testCase)
         % Inferred cell size extends the frame half a cell past min/max.
         [X, Y] = testGridVectorsAndMembership.planarGrid();
         [PX, PY] = mapGridOutline(X, Y);
         testCase.verifyEqual(min(PX), min(X(:)) - 5, 'AbsTol', 1e-9);
         testCase.verifyEqual(max(PX), max(X(:)) + 5, 'AbsTol', 1e-9);
         testCase.verifyEqual(min(PY), min(Y(:)) - 5, 'AbsTol', 1e-9);
         testCase.verifyEqual(max(PY), max(Y(:)) + 5, 'AbsTol', 1e-9);
      end

      function testMapGridOutlineExplicitSpacing(testCase)
         % Explicit dX, dY override the inferred cell size.
         [X, Y] = testGridVectorsAndMembership.planarGrid();
         P = mapGridOutline(X, Y, 20, 40);
         [xl, yl] = boundingbox(P);
         testCase.verifyEqual(xl, [min(X(:)) - 10, max(X(:)) + 10], 'AbsTol', 1e-9);
         testCase.verifyEqual(yl, [min(Y(:)) - 20, max(Y(:)) + 20], 'AbsTol', 1e-9);
      end

      % ---- imageSizeInXY ----
      function testImageSizeInXY(testCase)
         % Build an image with known XData/YData centers; the reported size is
         % the pixel-edge-to-edge extent (centers span + one cell).
         fig = figure('Visible', 'off');
         cleanup = onCleanup(@() close(fig));
         C = magic(5);                  % 5x5 CData
         im = image('XData', 0:10:40, 'YData', 0:10:40, 'CData', C);
         out = imageSizeInXY(im);
         % imageSizeInXY computes pixel extent as (XData(2)-XData(1))/(N-1),
         % where N is the CData dimension: here (10)/(5-1) = 2.5 per pixel.
         % Frame = XData span (40) + one pixel (2.5) = 42.5 in each direction.
         testCase.verifyEqual(out, [42.5 42.5], 'AbsTol', 1e-9);
      end
   end
end
