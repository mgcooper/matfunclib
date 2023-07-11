function [X,Y] = R2grid(R)
%R2GRID construct full grids X and Y from spatial referencing object R.
% 
% R2GRID [X,Y] = R2grid(R) constructs 2-d grids X and Y of coordinate pairs from
% spatial referencing object R 
%
% Author: matt cooper (guycooper@ucla.edu)
%
% See also R2grat

%% Check inputs

% confirm mapping toolbox is installed
assert(license('test','map_toolbox')==1, ...
   'rasterinterp requires Matlab''s Mapping Toolbox.')

% confirm R is either MapCells or GeographicCellsReference objects
validateattributes(R, ...
   {'map.rasterref.MapCellsReference', ...
   'map.rasterref.GeographicCellsReference'}, ...
   {'scalar'}, 'R2grid', 'R', 2) % might need {'scalar', 'object'}

% Regarding the construction of the grid from the R object. From the
% documentation for MapCellsReference: "The Mapping Toolbox™ and Image
% Processing Toolbox™ use the convention for the location of the origin
% relative to the raster cells or sampling points such that, at a sample
% location or at the center of a cell, x has an integer value equal to the
% column index. Likewise, at a sample location or at the center of a cell,
% y has an integer value equal to the row index.". This is why we construct
% the grid by adding the cell size /2 to the first X world coordinate, and
% subtracting the cells size/2 from the last X world coordinate (m+0.5)
% ____________________
% HORIZONTAL DIMENSION
% 
% center of first cell                 center of last cell
%           |                                   |
%           v                                   v
% 0   0.5   1   1.5   2   2.5  m-1.5 m-1 m-0.5  m  m+0.5
%       ___________________       ___________________
%      |         |         |     |         |         |
% o    |    o    |    o    | ... |    o    |    o    |    o
%      |         |         |     |         |         | 
%       -------------------       -------------------
% ^    ^                                             ^
% |    |                                             |
% |     \                                             \
%  \    raster left edge = R.XWorldLimits(1)           raster right edge = R.XWorldLimits(2)
%   \
%    origin
% __________________
% VERTICAL DIMENSION
% 
%     o <- origin
%
%  -------  <- raster top edge ( R.YWorldLimits(1) )
% |       |
% |   o   | <- center of first cell
% |       |
%  -------
%     .
%     .
%     .
%  -------  <- raster top edge ( R.YWorldLimits(1) )
% |       |
% |   o   | <- center of last cell
% |       |
%  -------  <- raster bottom edge ( R.YWorldLimits(2) )
%
%     o <- phantom point mirroring origin on other end
% 
% 
% The default R = maprefcells() is equivalent to:
% xlimits = [0.5 2.5];
% ylimits = [0.5 2.5];
% rasterSize = [2 2];
% R = maprefcells(xlimits, ylimits, rasterSize)
% 
% This defines a 2x2 raster with four grid cells.
% 
% This is why when starting with an R object, creating a grid involves adjusting
% the X/YWorldLimits (or Latitude/LongitudeLimits) INWARD by 1/2 cell size.
% 
% If instead, the raster cell centers are used to construct an R object, the
% opposite is true - the min/max cell centers are adjusted OUTWARD by 1/2 cell
% size to create the xlimits/ylimits inputs to MAPREFCELLS or GEOREFCELLS

% Determine if R is planar or geographic and call the appropriate function
if strcmp(R.CoordinateSystemType,'planar')
   [X,Y] = mapR2grid(R);
elseif strcmp(R.CoordinateSystemType,'geographic')
   [X,Y] = geoR2grid(R);
end

% Apply the appropriate function
function [X,Y] = mapR2grid(R)

   % build query grid from R, adjusted INWARD to cell centroids
   xpsz = R.CellExtentInWorldX;        % x pixel size
   xmin = R.XWorldLimits(1)+xpsz/2;    % left limit
   xmax = R.XWorldLimits(2)-xpsz/2;    % right limit
   xq = xmin:xpsz:xmax;

   % y direction
   ypsz = R.CellExtentInWorldY;        % y pixel size
   ymin = R.YWorldLimits(1)+ypsz/2;    % bottom limit
   ymax = R.YWorldLimits(2)-ypsz/2;    % top limit
   yq = ymin:ypsz:ymax;

   % construct unique x,y pairs for each Zq grid centroid
   [X,Y] = meshgrid(xq,yq);

   % flip the y-coordinates upside down if oriented S-N
   if strcmp(R.ColumnsStartFrom,'north')
      Y = flipud(Y);
   end

   % flip the x-coordinates left/right if oriented E-W
   if strcmp(R.ColumnsStartFrom,'east')
      X = fliplr(X);
   end
   
end

function [X,Y] = geoR2grid(R)

   % build query grid from R, adjusted INWARD to cell centroids
   lonpsz = R.CellExtentInLongitude;         % x pixel size
   lonmin = R.LongitudeLimits(1)+lonpsz/2;   % left limit
   lonmax = R.LongitudeLimits(2)-lonpsz/2;   % right limit
   lonq = lonmin:lonpsz:lonmax;

   % y direction
   latpsz = R.CellExtentInLatitude;          % y pixel size
   latmin = R.LatitudeLimits(1)+latpsz/2;    % bottom limit
   latmax = R.LatitudeLimits(2)-latpsz/2;    % top limit
   latq = latmin:latpsz:latmax;

   % construct unique x,y pairs for each Zq grid centroid
   [X,Y] = meshgrid(lonq,latq);

   % flip the y-coordinates upside down if oriented S-N
   if strcmp(R.ColumnsStartFrom,'north')
      Y = flipud(Y);
   end

   % flip the x-coordinates left/right if oriented E-W
   if strcmp(R.ColumnsStartFrom,'east')
      X = fliplr(X);
   end

   % Note: this might also work
   % [X, Y] = meshgrid( R.intrinsicXToLongitude(1:R.RasterSize(2)), ...
   %    R.intrinsicYToLatitude( 1:R.RasterSize(1)));
   
end

end

