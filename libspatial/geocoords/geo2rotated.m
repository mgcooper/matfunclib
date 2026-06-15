function [rlat, rlon] = geo2rotated(lat, lon, poleLat, poleLon)
   %GEO2ROTATED Transform geographic lat/lon to rotated-pole coordinates.
   %
   % [rlat, rlon] = geo2rotated(lat, lon, poleLat, poleLon)
   %
   % Converts true geographic latitude/longitude to the rotated latitude/
   % longitude of a CF "rotated_latitude_longitude" grid whose rotated north
   % pole sits at true coordinates (poleLat, poleLon) -- i.e. the CF attributes
   % grid_north_pole_latitude and grid_north_pole_longitude. All inputs and
   % outputs are in degrees. Inverse of ROTATED2GEO.
   %
   % Inputs:
   %   lat, lon  - true geographic latitude/longitude (deg), any matching size
   %   poleLat   - grid_north_pole_latitude (deg)
   %   poleLon   - grid_north_pole_longitude (deg)
   %
   % Outputs:
   %   rlat, rlon - rotated latitude/longitude (deg), same size as lat/lon
   %
   % These are the standard COSMO/CORDEX rotation formulas (phi2phirot /
   % rla2rlarot), the convention used by RACMO2.3.
   %
   % See also: rotated2geo, parseGridMapping

   d2r = pi / 180;

   % Sine/cosine of the pole latitude and the pole longitude offset.
   sinPole = sin(d2r * poleLat);
   cosPole = cos(d2r * poleLat);
   lamPole = d2r * poleLon;

   % True coordinates in radians; wrap longitude to (-180, 180] first so the
   % atan2 branch for rlon is taken consistently.
   phi = d2r * lat;
   lam = lon;
   lam(lam > 180) = lam(lam > 180) - 360;
   lam = d2r * lam;

   % Rotated latitude: project the point onto the rotated polar axis.
   arg = cosPole .* cos(phi) .* cos(lam - lamPole) + sinPole .* sin(phi);
   arg = max(min(arg, 1), -1);          % guard asin against round-off |arg|>1
   rlat = (1 / d2r) * asin(arg);

   % Rotated longitude: azimuth about the rotated pole.
   arg1 = -sin(lam - lamPole) .* cos(phi);
   arg2 = -sinPole .* cos(phi) .* cos(lam - lamPole) + cosPole .* sin(phi);
   rlon = (1 / d2r) * atan2(arg1, arg2);
end
