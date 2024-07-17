function [GridType, cellSizeX, cellSizeY, tfGeoCoords, tfLatLonOrder] = ...
      mapGridInfo(X, Y, GridFormat)
   %MAPGRIDINFO Determine the grid type, cell size, and coordinate system.
   %
   % [GridType, cellSizeX, cellSizeY, tfGeo] = mapGridInfo(X, Y) returns the
   % type of the grid ('uniform', 'regular', 'irregular'), the cell size in the
   % X and Y direction, and a boolean flag to indicate if the coordinates are
   % geographic.
   %
   % Inputs:
   %  X - x-coordinates of grid
   %  X - y-coordinates of grid
   %  GridFormat - (optional) the grid data format, specifying how the
   %  coordinates are stored in memory. Values are:
   %     'gridvectors'
   %     'fullgrids'
   %     'coordinates'
   %     'point'
   %  Note that 'GridFormat' is also referred to as 'GridOption' both in the
   %  mspatial library and in Mathworks Mapping Toolbox functions. See the
   %  documentation for the Mapping Toolbox for more information.
   %
   % Outputs:
   %
   %  GridType - The type of grid, specified as a scalar text taking one of the
   %  following values:
   %     'uniform': X and Y are uniformly spaced with the same step size.
   %     'regular': X and Y are uniformly spaced but with different step sizes.
   %     'irregular': Neither X or Y is uniformly spaced.
   %
   % Matt Cooper, 11-Mar-2023, https://github.com/mgcooper
   %
   % See also: prepareMapGrid, orientMapGrid, mapGridCellSize, isGeoGrid

   % Determine grid format if not provided
   if nargin < 3
      GridFormat = mapGridFormat(X, Y);
   end

   % Convert input formats to grid vectors.
   switch GridFormat
      case 'gridvectors'

         X = unique(X(:), 'sorted');
         Y = unique(Y(:), 'sorted');

      case {'fullgrids', 'coordinates'}

         % Remove duplicate coordinate pairs. Use 'stable' to retain the order.
         XY = unique([X(:), Y(:)], 'rows');
         X = XY(:, 1);
         Y = XY(:, 2);

      case 'point'
         % no problem

      otherwise % one must be unsupported type
         % need error message
   end

   % Determine the cell size in the X and Y direction and the grid type
   [cellSizeX, cellSizeY, GridType] = mapGridCellSize(X, Y);

   % Determine if the coordinates are geographic and if X,Y are Lat,Lon
   [tfGeoCoords,tfLatLonOrder] = isGeoGrid(Y, X);
end
