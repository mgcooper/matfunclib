function sr = llpoly2steradians(lat,lon)
   %LLPOLY2STERADIANS Compute polygon area in steradians on Earth sphere.

   % There are 4*pi steradians in a sphere, and the solid angle subtended by a
   % polygon equals its area on the UNIT sphere. So evaluate sphericalpolyarea on
   % the unit sphere ([1 0]) and take the magnitude. This replaces the old
   % ll2utm + polyarea path, which projected to UTM (inaccurate for large or
   % multi-zone polygons) -- the spherical-excess area is exact and toolbox-free.
   sr = abs(sphericalpolyarea(lat, lon, [1 0]));
end
