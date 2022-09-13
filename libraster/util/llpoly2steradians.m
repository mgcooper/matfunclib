function sr = llpoly2steradians(lat,lon)

% surface area of earth is 510065621724089 m2 for wgs84 ellipsoid
% one steradian on the unit sphere is sr = A/(r*r) = 4*pi
% there are 4*pi steradians in a sphere, so just scale the sub-basin areas
% by the earth's surface area times one steradian.
    Aearth  = 510065621724089;                  % m2
    [x,y]   = ll2utm([lat,lon]);                % m
    sr      = 4*pi*polyarea(x,y)/Aearth;        % sr
end