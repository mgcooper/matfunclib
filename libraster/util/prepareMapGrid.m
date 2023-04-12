function [X,Y,cellSizeX,cellSizeY,gridType,tfGeoCoords] = prepareMapGrid(X,Y,gridOption)
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

% parse gridOption 
if nargin < 3
   gridOption = "fullgrids";
end   

% Determine the grid type, cell size in the X and Y direction, and if the coordinates are geographic
[gridType, cellSizeX, cellSizeY, tfGeoCoords] = mapGridInfo(X, Y);

% If longitude is wrapped from 0-360, unwrap to -180:180
if tfGeoCoords == true
%     X = wrapTo180(X);
end

% Return the requested gridOption
switch gridOption 
   
   case "gridvectors"
      
      X = reshape(sort(unique(X(:)),'ascend'),1,[]);
      Y = reshape(sort(unique(Y(:)),'descend'),[],1);

      % X = unique(X(:),'sorted');
      % Y = unique(Y(:),'sorted');
      
   case "fullgrids"

      % Convert grid vectors or coordinate pairs to 2-d arrays
      [X, Y] = meshgrid(unique(X(:), 'sorted'), unique(Y(:), 'sorted'));
      
      % Ensure the X,Y arrays are oriented W-E and N-S
      [X, Y] = orientMapGrid(X, Y);
      
   case "gridframes"
      
      [X, Y] = gridNodesToEdges(X, Y);
      
end


end