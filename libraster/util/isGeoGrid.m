function [tfGeoCoords, tfLatLonOrder] = isGeoGrid(Lat, Lon)
   %ISGEOGRID Determine if coordinates are geographic with X = Lon and Y = Lat.
   %
   % [tfGeoCoords] = isGeoGrid(Lat, Lon) returns a boolean flag indicating if
   % the given coordinates Lat and Lon are within the geographic coordinate
   % system bounds (latitude: -90 to 90, longitude: -180 to 180 or 0 to 360).
   %
   % [tfGeoCoords, tfLatLonOrder] = isGeoGrid(Lat, Lon) performs an additional
   % check if the given coordinates Lat and Lon are ordered as Lon, Lat by
   % checking if Lon is within the geographic coordinate system bounds for
   % LATITUDE (-90 to 90) and Lat is within the geographic coordinate system
   % bounds for LONGITUDE (-180 to 180 or 0 to 360). If both are true, the
   % coordinates Lat, Lon are assumed to be ordered as Lon, Lat, and
   % isLatLonOrder is false (indicates user input error, common when switching
   % between coordinate systems or using X,Y for Lon,Lat), otherwise
   % isLatLonOrder is true (expected order).
   %
   % Example:
   %   [tfGeoCoords,tfLatLonOrder] = isGeoGrid(X, Y)
   %
   % Matt Cooper, 11-Mar-2023, https://github.com/mgcooper
   %
   % See also: orientMapGrid, mapGridCellSize, prepareMapGrid, mapGridInfo

   % Initialize output
   tfGeoCoords = false;
   tfLatLonOrder = false;

   % Reshape to lists and remove nan
   [Lat, Lon] = deal(Lat(:), Lon(:));
   [Lat, Lon] = deal(Lat(~isnan(Lat)), Lon(~isnan(Lon)));

   % Check if coordinates are geographic with X = Lon and Y = Lat. A grid is
   % classified geographic only when its coordinates fall within geographic
   % bounds AND carry a signal distinguishing them from a planar grid that
   % merely occupies the same numeric range. Within-bounds planar grids are
   % typically small, all-integer and all-positive (e.g. a 0..100 by 0..50
   % test/index grid); real lat/lon grids usually contain fractional degrees, or
   % values a small positive planar grid would not (negative longitudes,
   % longitudes > 180, or negative latitudes). All-integer, non-negative, <=180
   % grids are therefore treated as ambiguous and classified planar -- pass
   % UseGeoCoords=true to force geographic for such a grid.
   if inGeoBounds(Lon, Lat) && hasGeoSignature(Lon, Lat)
      tfGeoCoords = true;
      tfLatLonOrder = true;

      % Check if coordinates are geographic but ordered X = Lat, Y = Lon (a
      % common user input error when swapping coordinate systems).
   elseif nargout == 2 && inGeoBounds(Lat, Lon) && hasGeoSignature(Lat, Lon)
      tfGeoCoords = true;
      tfLatLonOrder = false;
   end
end

function tf = inGeoBounds(lon, lat)
   % Longitudes within [-180,180] or [0,360] and latitudes within [-90,90].
   tf = ((min(lon) >= -180 && max(lon) <= 180) ...
      || (min(lon) >= 0 && max(lon) <= 360)) ...
      && (min(lat) >= -90 && max(lat) <= 90);
end

function tf = hasGeoSignature(lon, lat)
   % Signals that in-range coordinates are geographic rather than a same-range
   % planar grid: fractional-degree values (beyond float round-off), or
   % longitudes/latitudes a small positive planar grid would not contain.
   v = [lon(:); lat(:)];
   isFractional = any(abs(v - round(v)) > 1e-6);
   tf = isFractional || min(lon) < 0 || max(lon) > 180 || min(lat) < 0;
end
