function a = earthSurfaceArea(lat,lon,in3,in4)
   %EARTHSURFACEAREA Surface area of polygon on earth sphere or ellipsoid
   %
   %   A = EARTHSURFACEAREA(LAT,LON) calculates the spherical surface area of
   %   the polygon specified by the input vectors LAT, LON.  LAT and LON are in
   %   degrees.  The calculation uses a line integral approach.  The output, A,
   %   is the surface area fraction covered by the polygon on a unit sphere.
   %   Multiple polygons can be supplied provided that each polygon is separated
   %   by a NaN in the input vectors. Accuracy of the integration method is
   %   inversely proportional to the distance between polygon vertices.
   %
   %   A = EARTHSURFACEAREA(LAT,LON,ELLIPSOID) uses the input ELLIPSOID to
   %   describe the sphere or ellipsoid.  ELLIPSOID is a reference ellipsoid
   %   (oblate spheroid) object, a reference sphere object, or a vector of the
   %   form [semimajor_axis, eccentricity].  The output, A, is in square units
   %   corresponding to the length units of the semimajor axis.
   %
   %   A = AREAINT(...,ANGLEUNITS) uses the units specified by ANGLEUNITS.
   %   ANGLEUNITS can be 'degrees' or 'radians'.
   %
   %   See also AREAMAT, AREAQUAD.

   % Now a thin, toolbox-free wrapper over sphericalpolyarea (the old colatitude/
   % azimuth line integral via distance/convertlat/rsphere is gone). The result
   % is SIGNED by vertex orientation, so multi-part input with oppositely-wound
   % holes subtracts the hole areas. Per-part areas are returned (one per
   % NaN-delimited segment / cell), matching the old per-segment output.

   narginchk(2, 4)
   units = [];
   ellipsoid = [];
   switch nargin
      case 3
         if ischar(in3) || isStringScalar(in3)
            units = in3;
         else
            ellipsoid = in3;
         end
      case 4
         ellipsoid = in3;
         units = in4;
   end
   if isempty(units) || (isStringScalar(units) && strlength(units) == 0)
      units = 'degrees';
   end

   % sphericalpolyarea works in degrees; convert if the caller passed radians.
   if startsWith(lower(char(units)), 'r')
      lat = rad2deg(lat);
      lon = rad2deg(lon);
   end

   if isempty(ellipsoid)
      % No ellipsoid -> normalized result: signed area as a FRACTION of the unit
      % sphere (the unit sphere has 4*pi steradians of area).
      [~, a] = sphericalpolyarea(lat, lon, [1 0]);
      a = a / (4 * pi);
   else
      % Ellipsoid supplied -> absolute signed area in m^2.
      [~, a] = sphericalpolyarea(lat, lon, ellipsoid);
   end
end
