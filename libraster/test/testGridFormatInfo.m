classdef testGridFormatInfo < matlab.unittest.TestCase
   %TESTGRIDFORMATINFO Grid format / info / orientation util family.
   %
   % Covers the libraster/util grid-classification helpers that had NO test
   % coverage: mapGridFormat, mapGridInfo, customIsUniform, checkGrid,
   % isfullgrid, ncorient, ncrowcol, fastgrid, orientMapGrid. Tests assert the
   % documented contracts (known classifications, round-trips, orientation
   % invariants), not incidental output.

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
         % North-up, W-E full grid (rows decrease N->S like a raster).
         [X, Y] = meshgrid(0:10:100, 50:-10:0);
      end
   end

   methods (Test)
      % ---- mapGridFormat ----
      function testMapGridFormatPoint(testCase)
         testCase.verifyEqual(mapGridFormat(5, 7), "point");
      end
      function testMapGridFormatGridVectors(testCase)
         % Vectors with all-unique elements and different lengths.
         fmt = mapGridFormat(0:10:100, 0:10:50);
         testCase.verifyEqual(fmt, "gridvectors");
      end
      function testMapGridFormatFullGrids(testCase)
         [X, Y] = testGridFormatInfo.planarGrid();
         testCase.verifyEqual(mapGridFormat(X, Y), "fullgrids");
      end
      function testMapGridFormatCoordinates(testCase)
         % Same-length vectors with repeated elements -> coordinate pairs.
         [X, Y] = testGridFormatInfo.planarGrid();
         testCase.verifyEqual(mapGridFormat(X(:), Y(:)), "coordinates");
      end
      function testMapGridFormatGridSizeForVectors(testCase)
         % gridSize is reported as [numel(Y), numel(X)] for gridvectors.
         [fmt, gridSize] = mapGridFormat(0:10:100, 0:10:50);
         testCase.verifyEqual(fmt, "gridvectors");
         testCase.verifyEqual(gridSize, [numel(0:10:50), numel(0:10:100)]);
      end

      % ---- mapGridInfo ----
      function testMapGridInfoUniform(testCase)
         % Equal dx and dy -> 'uniform'.
         [X, Y] = meshgrid(0:10:100, 0:10:50);
         [GridType, csx, csy] = mapGridInfo(X, Y);
         testCase.verifyEqual(GridType, 'uniform');
         testCase.verifyEqual(abs(csx), 10, 'AbsTol', 1e-9);
         testCase.verifyEqual(abs(csy), 10, 'AbsTol', 1e-9);
      end
      function testMapGridInfoRegular(testCase)
         % Uniform but dx ~= dy -> 'regular'.
         [X, Y] = meshgrid(0:10:100, 0:20:100);
         [GridType, csx, csy] = mapGridInfo(X, Y);
         testCase.verifyEqual(GridType, 'regular');
         testCase.verifyEqual(abs(csx), 10, 'AbsTol', 1e-9);
         testCase.verifyEqual(abs(csy), 20, 'AbsTol', 1e-9);
      end
      function testMapGridInfoIrregular(testCase)
         % Non-uniform spacing in both directions -> 'irregular'.
         [X, Y] = ndgrid([0 1 2 4 8], [0 1 2 4 8]);
         GridType = mapGridInfo(X, Y);
         testCase.verifyEqual(GridType, 'irregular');
      end
      function testMapGridInfoGeoFlag(testCase)
         % Geographic coordinates set tfGeoCoords true.
         [X, Y] = meshgrid(-50:0.5:-40, 50:0.5:60);
         [~, ~, ~, tfGeoCoords] = mapGridInfo(X, Y);
         testCase.verifyTrue(tfGeoCoords);
      end
      function testMapGridInfoPlanarNotGeo(testCase)
         % Planar coordinates far outside geo bounds set tfGeoCoords false.
         [X, Y] = meshgrid(0:1000:10000, 0:1000:5000);
         [~, ~, ~, tfGeoCoords] = mapGridInfo(X, Y);
         testCase.verifyFalse(tfGeoCoords);
      end

      % ---- customIsUniform ----
      function testCustomIsUniformTrue(testCase)
         [tf, cellsize] = customIsUniform((0:10:100)');
         testCase.verifyTrue(tf);
         testCase.verifyEqual(cellsize, 10, 'AbsTol', 1e-9);
      end
      function testCustomIsUniformFloat32Jitter(testCase)
         % float32 storage jitter is within the relative tolerance -> uniform.
         x = double(single(0:0.15:15)');
         [tf, cellsize] = customIsUniform(x);
         testCase.verifyTrue(tf);
         testCase.verifyEqual(cellsize, 0.15, 'AbsTol', 1e-3);
      end
      function testCustomIsUniformFalse(testCase)
         % Geometric spacing is genuinely irregular.
         tf = customIsUniform([0 1 2 4 8]');
         testCase.verifyFalse(tf);
      end
      function testCustomIsUniformReturnsModalCellSize(testCase)
         % One off node should not move the modal (most common) cell size.
         x = [0 10 20 30 41 50]';
         [~, cellsize] = customIsUniform(x);
         testCase.verifyEqual(cellsize, 10, 'AbsTol', 1e-9);
      end

      % ---- isfullgrid ----
      function testIsFullGridTrueForFullMeshgrid(testCase)
         [X, Y] = testGridFormatInfo.planarGrid();
         testCase.verifyTrue(isfullgrid(X(:), Y(:)));
      end
      function testIsFullGridFalseWhenNodeDropped(testCase)
         [X, Y] = testGridFormatInfo.planarGrid();
         x = X(:); y = Y(:);
         x(end) = []; y(end) = [];   % drop one node from the full grid
         testCase.verifyFalse(isfullgrid(x, y));
      end

      % ---- orientMapGrid ----
      function testOrientMapGridReorientsToNSWE(testCase)
         % Input S-N and E-W; default orientation should flip to N-S, W-E.
         [X, Y] = meshgrid(100:-10:0, 0:10:50);  % X E-W, Y S-N
         [Xo, Yo, didFlipLR, didFlipUD] = orientMapGrid(X, Y);
         testCase.verifyTrue(didFlipLR);
         testCase.verifyTrue(didFlipUD);
         % W-E: first column is the minimum, increases across columns.
         testCase.verifyEqual(Xo(1, 1), min(Xo(:)), 'AbsTol', 1e-9);
         testCase.verifyTrue(Xo(1, 2) > Xo(1, 1));
         % N-S: first row is the maximum, decreases down rows.
         testCase.verifyEqual(Yo(1, 1), max(Yo(:)), 'AbsTol', 1e-9);
         testCase.verifyTrue(Yo(1, 1) > Yo(2, 1));
      end
      function testOrientMapGridNoFlipWhenAlreadyOriented(testCase)
         % Already N-S, W-E: no flips.
         [X, Y] = testGridFormatInfo.planarGrid();
         [Xo, Yo, didFlipLR, didFlipUD] = orientMapGrid(X, Y);
         testCase.verifyFalse(didFlipLR);
         testCase.verifyFalse(didFlipUD);
         testCase.verifyEqual(Xo, X, 'AbsTol', 1e-9);
         testCase.verifyEqual(Yo, Y, 'AbsTol', 1e-9);
      end

      % ---- fastgrid ----
      function testFastgridMatchesMeshgrid(testCase)
         x = 0:10:100;
         y = 0:10:50;
         [Xf, Yf] = fastgrid(x, y);
         [Xm, Ym] = meshgrid(x, y);
         testCase.verifyEqual(Xf, Xm);
         testCase.verifyEqual(Yf, Ym);
      end

      % ---- checkGrid (now usable: diagonals equal + bisecting) ----
      function testCheckGridTrueForAxisAlignedRectangle(testCase)
         % Corners in any order (the function reorders cyclically).
         testCase.verifyTrue(checkGrid([0 0; 0 2; 3 0; 3 2]));
      end
      function testCheckGridTrueForRotatedRectangle(testCase)
         % A rotated rectangle is still a rectangle (the rotated-grid case).
         th = pi/6; R = [cos(th) -sin(th); sin(th) cos(th)];
         rect = [0 0; 3 0; 3 2; 0 2] * R.';
         testCase.verifyTrue(checkGrid(rect));
      end
      function testCheckGridFalseForNonRectangle(testCase)
         testCase.verifyFalse(checkGrid([0 0; 0 2; 3 0; 5 9]));   % sheared quad
      end

      % ---- ncorient ----
      function testNcorientProducesNorthUpRowMajor(testCase)
         % Header: returns full grids oriented N-S (rows), W-E (cols).
         lon = -50:10:0;
         lat = 40:10:60;
         [Lon, Lat] = ncorient(lon, lat);
         testCase.verifyEqual(size(Lon), [numel(lat), numel(lon)]);
         testCase.verifyEqual(size(Lat), [numel(lat), numel(lon)]);
         % W-E across columns.
         testCase.verifyEqual(Lon(1, 1), min(lon), 'AbsTol', 1e-9);
         testCase.verifyTrue(Lon(1, 2) > Lon(1, 1));
         % N-S down rows (north on top).
         testCase.verifyEqual(Lat(1, 1), max(lat), 'AbsTol', 1e-9);
         testCase.verifyTrue(Lat(1, 1) > Lat(2, 1));
      end
      function testNcorientReorientsDataGrid(testCase)
         % A data grid passed through is reoriented identically to lon/lat,
         % so values keyed by (lon,lat) stay aligned.
         lon = -50:10:0;          % 6 cols
         lat = 40:10:60;          % 3 rows
         % Build data already in the oriented (N-up, W-E) frame, then
         % de-orient it to ndgrid (lon-major) so ncorient can re-orient it.
         [Lon, Lat] = ncorient(lon, lat);
         data = Lon + 1000 * Lat;                  % unique per node
         dataNd = permute(flipud(data), [2, 1]);   % inverse of ncorient ops
         [~, ~, dataOut] = ncorient(lon, lat, dataNd);
         testCase.verifyEqual(dataOut, data, 'AbsTol', 1e-9);
      end

      % ---- ncrowcol ----
      function testNcrowcolSinglePointDoesNotCrash(testCase)
         % Regression: a single point (Nx2 with N=1) used to crash because
         % polyshape drops a lone vertex. It must select the nearest cell.
         ncX = -50:1:0; ncY = 40:1:60;
         [X, ~] = ndgrid(ncX, ncY);
         [start, count] = ncrowcol(X, ncX, ncY, [-30 48]);
         testCase.verifyEqual(numel(start), 2);
         testCase.verifyEqual(numel(count), 2);
         testCase.verifyGreaterThanOrEqual(min(start), 1);
      end

      function testNcrowcolBracketsPolygonWithinGrid(testCase)
         % start/count must select a row/col window covering the polygon.
         ncX = -50:1:0;       % 51 lon
         ncY = 40:1:60;       % 21 lat
         [X, ~] = ndgrid(ncX, ncY);   % ndgrid (row-major) per header
         poly = [-30 48; -20 48; -20 52; -30 52; -30 48];
         [start, count] = ncrowcol(X, ncX, ncY, poly);
         testCase.verifyEqual(numel(start), 2);
         testCase.verifyEqual(numel(count), 2);
         % The selected lon window must enclose the polygon's lon extent.
         lonWin = ncX(start(1):start(1) + count(1) - 1);
         latWin = ncY(start(2):start(2) + count(2) - 1);
         testCase.verifyLessThanOrEqual(min(lonWin), min(poly(:, 1)));
         testCase.verifyGreaterThanOrEqual(max(lonWin), max(poly(:, 1)));
         testCase.verifyLessThanOrEqual(min(latWin), min(poly(:, 2)));
         testCase.verifyGreaterThanOrEqual(max(latWin), max(poly(:, 2)));
      end
   end
end
