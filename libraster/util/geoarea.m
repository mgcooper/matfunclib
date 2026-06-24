function A = geoarea(lat,lon,ellips)
   % A = geoarea(lat,lon) returns the signed surface area of the simple closed
   % polygon(s) with geographic vertices lat,lon (degrees). The result is:
   %
   %    Positive for clockwise vertex order
   %    Negative for counter-clockwise vertex order
   %    Zero if there are fewer than 3 vertices
   %
   % Multiple polygons may be supplied as NaN-delimited vectors or as cell arrays
   % of vectors; geoarea returns one signed area per part (so oppositely-wound
   % holes come back with the opposite sign).
   %
   % A = geoarea(lat,lon,ELLIPS) sets the reference body (default 'wgs84'); see
   % sphericalpolyarea for the accepted forms ([1 0] gives steradians).
   %
   % geoarea is now a thin wrapper over the toolbox-free sphericalpolyarea (no
   % Mapping Toolbox: the old areaint / referenceEllipsoid dependence and the
   % unfinished geopolygonarea/nanpolyarea experiments are gone). The spherical-
   % excess area is signed by vertex orientation -- clockwise-positive here, the
   % same convention this function always documented.
   %
   % See also: sphericalpolyarea, polyorder, earthSurfaceArea

   if nargin < 3 || isempty(ellips)
      ellips = 'wgs84';
   end

   % Per-part signed area (Aparts). sphericalpolyarea is clockwise-positive, which
   % matches geoarea's documented convention, so return the per-part vector as-is.
   [~, A] = sphericalpolyarea(lat, lon, ellips);
end
