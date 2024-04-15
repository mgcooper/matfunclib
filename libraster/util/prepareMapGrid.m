function [X2,Y2,CellSizeX,CellSizeY,GridType,tfGeoCoords,I2,LOC1,I1,LOC2] = ...
      prepareMapGrid(X1, Y1, GridOption)
   %PREPAREMAPGRID Prepare planar or geographic X,Y grids for spatial analysis.
   %
   % [X, Y, cellSizeX, cellSizeY, gridType, tfGeoCoords] = prepareMapGrid(X, Y)
   % takes the input X,Y coordinate arrays or vectors that represent a regular
   % or uniform grid and returns the following outputs:
   %
   %   - X, Y: The input coordinate arrays or vectors, reoriented and gridded if
   %           necessary, to ensure they are 2-d arrays oriented West-East and
   %           North-South.
   %   - cellSizeX, cellSizeY: Scalars, the cell size in the X and Y directions.
   %   - gridType: Char, the grid type ('uniform', 'regular', 'irregular').
   %   - tfGeoCoords: Boolean flag, indicates if the coordinates are geographic.
   %
   % The function supports three types of input:
   %   1) Grid arrays of coordinate pairs.
   %   2) Grid vectors (e.g., x = 120:5:160, y = 40:5:60).
   %   3) Coordinate lists (e.g., X(:), Y(:), where X and Y are grid arrays).
   %
   % This function is intended for use with regular or uniform grids. If the
   % input grid is irregular, the function will raise an error.
   %
   %
   % Example 1: uniform grid, x = lon, y = lat (tfLatLonOrder = false)
   %   x = 0:5:100;
   %   y = 0:5:50;
   %   [X, Y] = meshgrid(x, y);
   %   [X, Y, cellSizeX, cellSizeY, gridType, tfGeoCoords] = prepareMapGrid(X, Y);
   %
   % Example 2: regular, non-uniform grid, x = lon, y = lat
   %   x = 0:10:100;
   %   y = 0:5:50;
   %   [X, Y] = meshgrid(x, y);
   %   [X, Y, cellSizeX, cellSizeY, gridType, tfGeoCoords] = prepareMapGrid(X, Y);
   %
   % Example 3: regular, non-uniform grid, x = lon, y = lat, lon in range 0:360
   %   x = 0:10:360;
   %   y = 0:5:50;
   %   [X, Y] = meshgrid(x, y);
   %   [X, Y, cellSizeX, cellSizeY, gridType, tfGeoCoords] = prepareMapGrid(X, Y);
   %   [minLon, maxLon] = bounds(X(:))
   %     ans: minLon = -170, maxLon = 180
   %
   % See also: mapGridInfo, orientMapGrid, mapGridCellSize

   % NOTE: This is failing in at least one known case - the gridded albedo from
   % Johnny. There, the lat lon grid vectors are projected to SIPSN. The
   % resolution is 1km, but mapGridFormat is returning "irregular" because the
   % call to customIsUniform returns false. That function is not ideal b/c it
   % does not consider the 2d grid orientation and take the diff along the
   % appropriate dimension. It should be possible to fix this using the mode and
   % an appropriate tolerance, but i was not able to get a "true" isuniform for
   % that case until I set tol to 6

   % Round input to nearest 1e-10. This is ad-hoc, from experience (e.g. MERRA2)
   X1 = round(X1, 10);
   Y1 = round(Y1, 10);

   % Determine input grid format.
   GridFormat = mapGridFormat(X1, Y1);

   % If GridOption was not provided, use fullgrids (not GridFormat)
   if nargin < 3 || isempty(GridOption)
      GridOption = 'fullgrids';
   end

   % Determine the grid type, X/Y cell size, and if coordinates are geographic
   [GridType, CellSizeX, CellSizeY, tfGeoCoords] = mapGridInfo(X1, Y1, GridFormat);

   % If GridType is irregular, then override the requested GridOption, only
   % 'unstructured' is compatible with subsequent methods.
   if strcmp(GridType, 'irregular') && ~strcmp(GridOption, 'unstructured')
      GridOption = 'unstructured';
   end

   % If longitude is wrapped from 0-360, unwrap to -180:180
   if tfGeoCoords == true
      % X = wrapTo180(X);
   end

   % Keep the original coordinates to determine 1) if there are missing pixels
   % after X, Y are converted to full grids or grid vectors, and 2) the indices
   % required to remap an external variable the same size as input X,Y onto the
   % output X,Y.
   % [X1, Y1] = dealout(X2, Y2);

   % Return the requested GridOption. GridType has no effect as of this time. If
   % GridOption is "unstructured", nothing is done. If GridType is used,
   % "irregular" should be treated the same way, meaning lists of coordinate
   % pairs are provided, and they are assumed to be correct.
   switch GridOption

      case 'gridvectors' % 1d cell-center vectors

         [X2, Y2] = gridvec(X1, Y1);

      case 'fullgrids' % 2d cell-center arrays

         [X2, Y2] = fullgrid(X1, Y1, GridOption);

      case 'gridframes' % 2d cell-edge arrays

         [X2, Y2] = fullgrid(X1, Y1, GridOption);
         [X2, Y2] = gridNodesToEdges(X2, Y2);

      case 'coordinates' % 1d cell center coordinates

         [X2, Y2] = fullgrid(X1, Y1, GridOption);

         X2 = X2(:);
         Y2 = Y2(:);

      case 'unstructured' % inclusive of 'irregular'

         % Probably do nothing, but if anything, remove / check for redundant pairs
         if numel(X1) == numel(Y1)
            XY = unique([X1(:), Y1(:)], 'rows', 'stable');
            X2 = XY(:, 1);
            Y2 = XY(:, 2);
         else
            % If here, likely means X1, Y1 are vectors of irregularly spaced
            % coordinates, e.g., if regular lat lon grid vectors were projected.
            % This is an error.
            X2 = X1;
            Y2 = Y1;

            error('X1, Y1 appear to be irregular and/or are not coordinate pairs')
         end

   end

   % Ensure the X,Y arrays are oriented W-E and N-S. This should work for all
   % cases above. For coordinates and unstructured, orientMapGrid returns
   % immediately. Update Sep 2023, added call to orient X1, Y1 b/c they were
   % being sent in as unoriented grid vectors so Y1 was a row but Y2 was a
   % column which made gridmember fail.
   [X1, Y1] = orientMapGrid(X1, Y1, 'off');
   [X2, Y2] = orientMapGrid(X2, Y2, 'off');

   % Find the mapping between the input X,Y and output X,Y. Suppress this for
   % nargout < 6 so gridmember can call this function.
   if nargout > 6
      [I2, LOC1, I1, LOC2] = gridmember(X2, Y2, X1, Y1);
   end
end
