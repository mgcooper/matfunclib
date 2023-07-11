function [Lat, Lon, cellSizeLat, cellSizeLon, gridType, tfGeoCoords] = ...
   prepareGeoGrid(Lat, Lon, varargin)
%PREPAREGEOGRID Prepare geographic lat,lon grids for spatial analysis

% I did not finish this. If prepareMapGrid2 behavior is wanted, then this needs
% to be compatible, otherwise, this needs tobe simplified to mirror how
% prepareMapGrid works, which assumes user input is correct

% Handle input
p = inputParser;
addOptional(p, 'silent', 'verbose');
parse(p, varargin{:});
silent = p.Results.silent;

% Check if the input vectors (or grids) are in Lon, Lat order
[tfGeoCoords,tfLonLatOrder] = isGeoGrid(Lon, Lat);
% [~, ~, tfGeoCoords, tfLonLatOrder] = mapGridInfo(Lon, Lat);

if not(tfGeoCoords)
   [Lon, Lat, cellSizeLon, cellSizeLat] = prepareMapGrid(Lon, Lat);
   return;
end

% Swap lat and lon if necessary
if tfLonLatOrder
   temp = Lat;
   Lat = Lon;
   Lon = temp;
end

% Determine if the input vectors (or grids) are regular and/or geographic/planar
[cellSizeLon, cellSizeLat, gridType] = mapGridCellSize(Lon, Lat);

% If lat and lon are not already grid arrays, build the grid arrays
if isvector(Lat) && isvector(Lon)
   [Lon, Lat] = meshgrid(Lon, Lat);
end

% Ensure the lat, lon arrays are oriented S-N and W-E
[Lon, Lat] = orientMapGrid(Lon, Lat);

% Warn if the input is in lon, lat order instead of lat, lon order
if ~tfLonLatOrder && ~silent
   warning('Input coordinates are in lon, lat order instead of lat, lon order. The order has been corrected.');
end
