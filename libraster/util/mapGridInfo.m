function [gridType, cellSizeX, cellSizeY, tfGeoCoords, tfLatLonOrder] = ...
      mapGridInfo(X, Y, gridFormat)
   %MAPGRIDINFO Determine the grid type, cell size, and coordinate system.
   %
   % [gridType, cellSizeX, cellSizeY, tfGeo] = mapGridInfo(X, Y) returns the
   % type of the grid ('uniform', 'regular', 'irregular'), the cell size in the
   % X and Y direction, and a boolean flag to indicate if the coordinates are
   % geographic.
   %
   % 'uniform': Both x and y are uniformly spaced and have the same step size.
   % 'regular': Both x and y are uniformly spaced but have different step sizes.
   % 'irregular': Neither x nor y is uniformly spaced.
   %
   % Matt Cooper, 11-Mar-2023, https://github.com/mgcooper
   %
   % See also: prepareMapGrid, orientMapGrid, mapGridCellSize, isGeoGrid

   % Determine grid format if not provided
   if nargin < 3
      gridFormat = mapGridFormat(X, Y);
   end

   % Convert input formats to grid vectors.
   switch gridFormat
      case 'gridvectors'

         X = unique(X(:), 'sorted');
         Y = unique(Y(:), 'sorted');

      case {'fullgrids', 'coordinates'}

         % Remove duplicate coordinate pairs. Use 'stable' to retain the order.
         XY = unique([X(:),Y(:)], 'rows');
         X = XY(:, 1);
         Y = XY(:, 2);

      case 'point'
         % no problem

      otherwise % one must be unsupported type
         % need error message
   end

   % Determine the cell size in the X and Y direction and the grid type
   [cellSizeX, cellSizeY, gridType] = mapGridCellSize(X, Y);

   % Determine if the coordinates are geographic and if X,Y are Lat,Lon
   [tfGeoCoords,tfLatLonOrder] = isGeoGrid(Y, X);
end
