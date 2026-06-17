classdef testPrepareMapGridRegular < matlab.unittest.TestCase
   %TESTPREPAREMAPGRIDREGULAR Regression for matfunclib-hfe.
   %
   % A uniform but large-magnitude projected axis (e.g. MAR/RACMO polar-stereo,
   % values ~1e3-1e6) must be classified 'regular', not 'irregular'. A blanket
   % round(.,10) in prepareMapGrid previously injected ~1e-10 quantization noise
   % into such axes and mis-flagged them irregular. These tests pin the fix.

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
      function testHighMagnitudeMetersAxisNotIrregular(testCase)
         % synthetic polar-stereo axis in meters: magnitude ~1e6, dx=dy=15 km.
         % Equal spacing => 'uniform'; the bug mis-flagged it 'irregular'.
         xr = (-7.5e5 + 15000 * (0:95)).';
         yr = (-1.185e6 + 15000 * (0:178)).';
         [X, Y] = meshgrid(xr, yr);
         [~, ~, dX, dY, GridType] = prepareMapGrid(X, Y, 'fullgrids');
         testCase.verifyEqual(GridType, 'uniform');
         testCase.verifyEqual(dX, 15000, 'AbsTol', 1e-6);
         testCase.verifyEqual(dY, 15000, 'AbsTol', 1e-6);
      end

      function testHighMagnitudeRegularAxis(testCase)
         % distinct dx,dy at large magnitude => 'regular' (exercises that branch)
         xr = (-7.5e5 + 15000 * (0:95)).';
         yr = (-1.185e6 + 20000 * (0:131)).';
         [X, Y] = meshgrid(xr, yr);
         [~, ~, dX, dY, GridType] = prepareMapGrid(X, Y, 'fullgrids');
         testCase.verifyEqual(GridType, 'regular');
         testCase.verifyEqual(dX, 15000, 'AbsTol', 1e-6);
         testCase.verifyEqual(dY, 20000, 'AbsTol', 1e-6);
      end

      function testKilometreAxisNotIrregular(testCase)
         % same grid expressed in km (magnitude ~1e3) -- also previously failed
         xr = (-750 + 15.000001 * (0:95)).';
         yr = (-1185 + 15.000001 * (0:178)).';
         [X, Y] = meshgrid(xr, yr);
         [~, ~, ~, ~, GridType] = prepareMapGrid(X, Y, 'fullgrids');
         testCase.verifyNotEqual(GridType, 'irregular');
      end

      function testMerra2NoisyAxisStillRegular(testCase)
         % the case the old round() targeted: degree axes with sub-1e-12 noise
         lon = -180 + 0.625 * (0:575).' + 1e-12 * cos((0:575).');
         lat = -90 + 0.5 * (0:360).' + 1e-12 * cos((0:360).');
         [LON, LAT] = meshgrid(lon, lat);
         [~, ~, dX, dY, GridType] = prepareMapGrid(LON, LAT, 'fullgrids');
         testCase.verifyEqual(GridType, 'regular');
         testCase.verifyEqual(dX, 0.625, 'AbsTol', 1e-9);
         testCase.verifyEqual(dY, 0.5, 'AbsTol', 1e-9);
      end

      function testGenuinelyIrregularStillIrregular(testCase)
         % a real irregular axis must NOT be rescued by the tolerance
         xr = [0 1 2 4 8 16].';
         yr = (0:5).';
         [X, Y] = meshgrid(xr, yr);
         testCase.verifyEqual(mapGridInfo(X, Y), 'irregular');
      end

      function testSavedMarAxisIsRegular(testCase)
         % the exact file-derived axis from the bug report, if shipped
         here = fileparts(mfilename("fullpath"));
         f = fullfile(fileparts(here), 'util', 'regression', ...
            'mar_regular_axis_repro.mat');
         testCase.assumeTrue(isfile(f), 'saved MAR axis not present');
         S = load(f);
         [X, Y] = meshgrid(S.xr, S.yr);
         [~, ~, ~, ~, GridType] = prepareMapGrid(X, Y, 'fullgrids');
         testCase.verifyEqual(GridType, 'regular');
      end

      function testRawFloat32JitterAxisIsUniform(testCase)
         % the RAW file-derived axes (xkm/ykm) carry float32 storage jitter
         % (~2e-6 of a cell). The relative-tolerance uniformity check must accept
         % them; the old absolute tolerance rejected them (matfunclib-hfe).
         here = fileparts(mfilename("fullpath"));
         f = fullfile(fileparts(here), 'util', 'regression', ...
            'mar_regular_axis_repro.mat');
         testCase.assumeTrue(isfile(f), 'saved MAR axis not present');
         S = load(f);
         testCase.assumeTrue(isfield(S, 'xkm') && isfield(S, 'ykm'), ...
            'raw xkm/ykm axes not present');
         [X, Y] = meshgrid(double(S.xkm), double(S.ykm));
         [~, ~, dX, dY, GridType] = prepareMapGrid(X, Y, 'fullgrids');
         testCase.verifyNotEqual(GridType, 'irregular');
         testCase.verifyEqual(dX, 15, 'AbsTol', 1e-3);
         testCase.verifyEqual(dY, 15, 'AbsTol', 1e-3);
      end

      function testSingleRowGridGetsSquareCellDefault(testCase)
         % a single-row (constant-Y) grid has no Y spacing of its own;
         % mapGridCellSize adopts the X cell size rather than returning NaN
         % (which would break rasterref's half-cell padding). matfunclib-lnh.11
         x = (0:10:100);
         y = 50 * ones(size(x));
         [csx, csy, gt] = mapGridCellSize(x, y);
         testCase.verifyEqual(csx, 10, 'AbsTol', 1e-9);
         testCase.verifyEqual(csy, 10, 'AbsTol', 1e-9);
         testCase.verifyFalse(any(isnan([csx csy])));
         testCase.verifyEqual(gt, 'uniform');
      end

      function testReprojectedJitterAxisIsIrregular(testCase)
         % a uniform axis perturbed by ~8% (far above the float32 jitter floor,
         % e.g. a reprojected grid) must still be classified irregular.
         rng(0);
         xr = cumsum([0; 15 + 0.08 * 15 * randn(95, 1)]);
         yr = (0:50:2500).';
         [X, Y] = meshgrid(xr, yr);
         testCase.verifyEqual(mapGridInfo(X, Y), 'irregular');
      end
   end
end
