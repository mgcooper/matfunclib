classdef testMapGridCellSize < matlab.unittest.TestCase
   %TESTMAPGRIDCELLSIZE Tests for mapGridCellSize grid classification.
   %
   % Regression coverage for the case where a grid is uniform only up to
   % floating-point round-off: the zero-tolerance built-in isuniform used to
   % misclassify it as irregular and return a per-node cell-size vector.

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         % Put the whole project on the path so mapGridCellSize and its helpers
         % resolve without a manual addpath, mirroring the other libraster tests.
         import matlab.unittest.fixtures.PathFixture

         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (Test)
      function testNoisyUniformGridCollapsesToScalar(testCase)
         % A geographic grid that is uniform except for ~1e-12 round-off (as seen
         % with real MERRA-2 coordinates) must classify as uniformly spaced with a
         % scalar cell size, not as an irregular grid with per-node spacing.
         lon = (-180:0.625:179.375).';            % 576 nodes, 0.625 deg step
         lat = (-90:0.5:90).';                     % 361 nodes, 0.5 deg step
         lon = lon + 1e-12 * cos((0:numel(lon)-1).');  % sub-tolerance noise
         lat = lat + 1e-12 * cos((0:numel(lat)-1).');

         [cellSizeX, cellSizeY, gridType] = mapGridCellSize(lon, lat);

         testCase.verifyTrue(isscalar(cellSizeX), ...
            "cellSizeX should collapse to a scalar for a noisy-uniform grid");
         testCase.verifyTrue(isscalar(cellSizeY), ...
            "cellSizeY should collapse to a scalar for a noisy-uniform grid");
         testCase.verifyEqual(cellSizeX, 0.625, "AbsTol", 1e-9);
         testCase.verifyEqual(cellSizeY, 0.5, "AbsTol", 1e-9);
         % Different x/y steps => 'regular' (uniform per-axis, unequal step sizes).
         testCase.verifyEqual(gridType, 'regular');
      end

      function testCleanUniformGrid(testCase)
         % A perfectly uniform grid with equal x/y steps stays 'uniform'.
         x = (0:10).';
         y = (0:10).';

         [cellSizeX, cellSizeY, gridType] = mapGridCellSize(x, y);

         testCase.verifyEqual(cellSizeX, 1);
         testCase.verifyEqual(cellSizeY, 1);
         testCase.verifyEqual(gridType, 'uniform');
      end

      function testGenuinelyIrregularGridStaysIrregular(testCase)
         % Spacing that varies well beyond the tolerance must remain irregular so
         % the tolerant fallback does not paper over real non-uniform grids.
         x = [0 1 2 4 8].';
         y = [0 1 2 4 8].';

         [~, ~, gridType] = mapGridCellSize(x, y);

         testCase.verifyEqual(gridType, 'irregular');
      end
   end
end
