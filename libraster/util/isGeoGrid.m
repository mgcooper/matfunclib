function [tfGeoCoords,tfLatLonOrder] = isGeoGrid(Lat, Lon)
%ISGEOGRID Determine if coordinates are geographic with X = Lon and Y = Lat.
%
% [tfGeoCoords] = isGeoGrid(Lat, Lon) returns a boolean flag indicating if the
% given coordinates Lat and Lon are within the geographic coordinate system
% bounds (latitude: -90 to 90, longitude: -180 to 180 or 0 to 360).
%
% [tfGeoCoords, tfLatLonOrder] = isGeoGrid(Lat, Lon) performs an additional
% check if the given coordinates Lat and Lon are ordered as Lon, Lat by checking
% if Lon is within the geographic coordinate system bounds for LATITUDE (-90 to 
% 90) and Lat is within the geographic coordinate system bounds for LONGITUDE
% (-180 to 180 or 0 to 360). If both are true, the coordinates Lat, Lon are
% assumed to be ordered as Lon, Lat, and isLatLonOrder is false (indicates user
% input error, common when switching between coordinate systems or using X,Y for
% Lon,Lat), otherwise isLatLonOrder is true (expected order). 
% 
% Example:
%   [tfGeoCoords,tfLatLonOrder] = isGeoGrid(X, Y)
% 
% Matt Cooper, 11-Mar-2023, https://github.com/mgcooper
% 
% See also orientMapGrid, mapGridCellSize, prepareMapGrid, mapGridInfo

% Initialize output
tfGeoCoords = false;
tfLatLonOrder = true;
   
% Check if coordinates are geographic with X = Lon and Y = Lat
if ((min(Lon(:)) >= -180 && max(Lon(:)) <= 180) || ...
      (min(Lon(:)) >= 0 && max(Lon(:)) <= 360)) && ...
      (min(Lat(:)) >= -90 && max(Lat(:)) <= 90)
    tfGeoCoords = true;
    tfLatLonOrder = true;
% Check if coordinates are geographic with X = Lat and Y = Lon (user input error)    
elseif nargout == 2 && ((min(Lat(:)) >= -180 && max(Lat(:)) <= 180) || ...
      (min(Lat(:)) >= 0 && max(Lat(:)) <= 360)) && ...
      (min(Lon(:)) >= -90 && max(Lon(:)) <= 90)
   tfGeoCoords = true;
   tfLatLonOrder = false;
end

end