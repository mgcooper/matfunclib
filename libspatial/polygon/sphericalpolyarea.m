function [A, Aparts] = sphericalpolyarea(lat, lon, ellipsoid)
   %SPHERICALPOLYAREA Signed surface area of a lat/lon polygon (toolbox-free).
   %
   %  A = sphericalpolyarea(LAT, LON) returns the net signed surface area (m^2,
   %  WGS84) of the polygon with geographic vertices LAT, LON (degrees). The area
   %  is SIGNED by vertex orientation, so multi-part input with oppositely-wound
   %  HOLES has the hole areas subtracted from the net A. Multiple polygons may be
   %  supplied as NaN-delimited vectors or as cell arrays of vectors.
   %
   %  [A, APARTS] = sphericalpolyarea(...) also returns the per-part signed area
   %  APARTS, so a caller can take the net (sum, holes subtracted) or the gross
   %  (sum(abs(APARTS))) area as needed.
   %
   %  [...] = sphericalpolyarea(LAT, LON, ELLIPSOID) sets the reference body:
   %     'wgs84' (default) | [semimajorAxis eccentricity] | [1 0] for the UNIT
   %     sphere (A is then in steradians) | a referenceEllipsoid/wgs84Ellipsoid-
   %     like object (duck-typed on .SemimajorAxis/.Eccentricity).
   %
   %  Method: the origin-independent spherical-excess edge sum (Chamberlain &
   %  Duquette / "Some Algorithms for Polygons on a Sphere"):
   %     A = R^2/2 * sum_edges  dLon * (2 + sin(lat_i) + sin(lat_{i+1}))
   %  with each dLon unwrapped into (-pi, pi]. Unlike a fixed-origin line integral
   %  (MATLAB areaint), it has no reference point, so it is correct for polygons
   %  straddling the equator and prime meridian, and the constant "2" term makes
   %  it handle pole-enclosing rings automatically. On an ellipsoid, latitudes are
   %  mapped to the authalic sphere (equal-area) using the authalic latitude and
   %  radius.
   %
   % See also: polyorder, nonnansegments, removeDuplicateVertices, geoarea

   if nargin < 3 || isempty(ellipsoid)
      ellipsoid = 'wgs84';
   end
   [a, e2] = resolveEllipsoid(ellipsoid);
   R = authalicRadius(a, e2);

   if iscell(lat)
      Aparts = zeros(size(lat));
      for k = 1:numel(lat)
         Aparts(k) = ringArea(lat{k}, lon{k}, R, e2);
      end
   else
      % NaN-delimited multipart: split on lat's NaNs (lat,lon share NaN positions
      % for a well-formed polygon list).
      [S, E] = nonnansegments(lat(:));
      Aparts = zeros(numel(S), 1);
      for k = 1:numel(S)
         idx = S(k):E(k);
         Aparts(k) = ringArea(lat(idx), lon(idx), R, e2);
      end
   end

   A = sum(Aparts(:));
end

%% ----------------------------------------------------------------------------
function A = ringArea(lat, lon, R, e2)
   % Signed area of a single ring.
   [lat, lon] = removeDuplicateVertices(lat(:), lon(:));
   if numel(lat) < 3
      A = 0;
      return
   end

   % Geodetic -> authalic latitude (equal-area), degrees -> radians.
   phi = geodetic2authalic(deg2rad(lat), e2);
   lam = deg2rad(lon);

   % Close the ring and take per-edge longitude differences, unwrapped to
   % (-pi, pi] so a dateline-crossing edge is handled with no toolbox call.
   phiN = [phi(2:end); phi(1)];
   lamN = [lam(2:end); lam(1)];
   dlam = mod(lamN - lam + pi, 2 * pi) - pi;

   % Chamberlain & Duquette spherical-excess edge sum.
   A = R^2 / 2 * sum(dlam .* (2 + sin(phi) + sin(phiN)));
end

%% ----------------------------------------------------------------------------
function xi = geodetic2authalic(phi, e2)
   % Geodetic latitude phi (rad) -> authalic latitude xi (rad). Closed-form
   % series in e2; identity for a sphere (e2 == 0).
   if e2 == 0
      xi = phi;
      return
   end
   xi = phi ...
      - (e2 / 3 + 31 * e2^2 / 180 + 59 * e2^3 / 560) .* sin(2 * phi) ...
      + (17 * e2^2 / 360 + 61 * e2^3 / 1260) .* sin(4 * phi) ...
      - (383 * e2^3 / 45360) .* sin(6 * phi);
end

%% ----------------------------------------------------------------------------
function R = authalicRadius(a, e2)
   % Radius of the sphere with the same surface area as the ellipsoid (a, e2).
   if e2 == 0
      R = a;
      return
   end
   e = sqrt(e2);
   R = a * sqrt((1 + (1 - e2) / e * atanh(e)) / 2);
end

%% ----------------------------------------------------------------------------
function [a, e2] = resolveEllipsoid(ellipsoid)
   % Resolve an ellipsoid spec to semimajor axis a and eccentricity-squared e2.
   if ischar(ellipsoid) || isstring(ellipsoid)
      switch lower(string(ellipsoid))
         case "wgs84"
            a = 6378137;
            f = 1 / 298.257223563;
            e2 = f * (2 - f);
         case {"sphere", "unit"}
            a = 1;
            e2 = 0;
         otherwise
            error("sphericalpolyarea:unknownEllipsoid", ...
               "Unknown ellipsoid name '%s'.", ellipsoid);
      end
   elseif isnumeric(ellipsoid) && numel(ellipsoid) == 2
      % [semimajorAxis eccentricity] (MATLAB referenceEllipsoid vector form;
      % [1 0] is the unit sphere).
      a = ellipsoid(1);
      e2 = ellipsoid(2)^2;
   elseif isobject(ellipsoid) || isstruct(ellipsoid)
      % referenceEllipsoid / wgs84Ellipsoid-like object.
      a = ellipsoid.SemimajorAxis;
      e2 = ellipsoid.Eccentricity^2;
   else
      error("sphericalpolyarea:badEllipsoid", ...
         "ELLIPSOID must be a name, a [semimajor ecc] vector, or an ellipsoid object.")
   end
end
