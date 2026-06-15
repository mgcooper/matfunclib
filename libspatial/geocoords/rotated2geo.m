function [lat, lon] = rotated2geo(rlat, rlon, poleLat, poleLon)
   %ROTATED2GEO Transform rotated-pole coordinates to geographic lat/lon.
   %
   % [lat, lon] = rotated2geo(rlat, rlon, poleLat, poleLon)
   %
   % Converts the rotated latitude/longitude of a CF
   % "rotated_latitude_longitude" grid (rotated north pole at true coordinates
   % poleLat, poleLon = grid_north_pole_latitude/longitude) back to true
   % geographic latitude/longitude. All inputs and outputs are in degrees.
   % Inverse of GEO2ROTATED.
   %
   % Inputs:
   %   rlat, rlon - rotated latitude/longitude (deg), any matching size
   %   poleLat    - grid_north_pole_latitude (deg)
   %   poleLon    - grid_north_pole_longitude (deg)
   %
   % Outputs:
   %   lat, lon   - true geographic latitude/longitude (deg), same size
   %
   % Standard COSMO/CORDEX inverse rotation (phirot2phi / rlarot2rla), the
   % convention used by RACMO2.3.
   %
   % See also: geo2rotated, parseGridMapping

   d2r = pi / 180;

   % Sine/cosine of the pole latitude and the pole longitude offset.
   sinPole = sin(d2r * poleLat);
   cosPole = cos(d2r * poleLat);
   lamPole = d2r * poleLon;

   % Rotated coordinates in radians; wrap rotated longitude to (-180, 180].
   phis = d2r * rlat;
   lams = rlon;
   lams(lams > 180) = lams(lams > 180) - 360;
   lams = d2r * lams;

   % True latitude.
   arg = cosPole .* cos(phis) .* cos(lams) + sinPole .* sin(phis);
   arg = max(min(arg, 1), -1);          % guard asin against round-off |arg|>1
   lat = (1 / d2r) * asin(arg);

   % True longitude (azimuth about the true pole), reusing a common term.
   term = -sinPole .* cos(phis) .* cos(lams) + cosPole .* sin(phis);
   arg1 = sin(lamPole) .* term - cos(lamPole) .* sin(lams) .* cos(phis);
   arg2 = cos(lamPole) .* term + sin(lamPole) .* sin(lams) .* cos(phis);
   lon = (1 / d2r) * atan2(arg1, arg2);
end
