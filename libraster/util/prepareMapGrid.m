function [X2,Y2,CellSizeX,CellSizeY,GridType,tfGeoCoords,I2,LOC1,I1,LOC2] = ...
   prepareMapGrid( X1, Y1, GridOption)
%PREPAREMAPGRID Prepare planar or geographic X,Y grids for spatial analysis
%
% [X, Y, cellSizeX, cellSizeY, gridType, tfGeoCoords] = prepareMapGrid(X, Y)
% takes the input X,Y coordinate arrays or vectors that represent a regular or
% uniform grid and returns the following outputs:
%
%   - X, Y: The input coordinate arrays or vectors, reoriented and gridded if 
%           necessary, to ensure they are 2-d arrays oriented West-East and
%           North-South. 
%   - cellSizeX, cellSizeY: The cell size in the X and Y directions.
%   - gridType: The type of the grid ('uniform', 'regular', 'irregular').
%   - tfGeoCoords: A boolean flag to indicate if the coordinates are geographic.
%
% The function supports three types of input:
%   1) Grid arrays of coordinate pairs.
%   2) Grid vectors (e.g., x = 120:5:160, y = 40:5:60).
%   3) Lists of coordinate pairs (e.g., X(:), Y(:), where X and Y are grid arrays).
%
% This function is intended for use with regular or uniform grids. If the input
% grid is irregular, the function will raise an error.
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

% Determine input grid format.
GridFormat = mapGridFormat(X1, Y1);

% If GridOption was not provided, use fullgrids (not GridFormat)
if nargin < 3 || isempty(GridOption)
   GridOption = 'fullgrids';
end

% Determine the grid type, X/Y cell size, and if the coordinates are geographic
[GridType, CellSizeX, CellSizeY, tfGeoCoords] = mapGridInfo(X1, Y1, GridFormat);

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
% "irregular" should be treated the same way, meaning lists of coordinate pairs
% are provided, and they are assumed to be correct. 
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
      % keep = unique([X1(:), Y1(:)], 'rows');
      % X = X(keep);
      % Y = Y(keep);
      
end

% Ensure the X,Y arrays are oriented W-E and N-S. This should work for all cases
% above. For coordinates and unstructured, orientMapGrid returns immediately
[X2, Y2] = orientMapGrid(X2, Y2, 'off');

% Find the mapping between the input X,Y and output X,Y. Suppress this for
% nargout < 6 so gridmember can call this function. 
if nargout > 6
   [I2, LOC1, I1, LOC2] = gridmember(X2, Y2, X1, Y1);
end
