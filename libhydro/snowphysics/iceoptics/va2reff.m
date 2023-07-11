function r = va2reff(V,A)
%va2reff converts the total volume and total cross-sectional area to
%equivalent spherical grain size (radius)
% grain_radius = m
% volume = m3
% cross-sectional area = m2
r = 3.*V./4./A;
end

