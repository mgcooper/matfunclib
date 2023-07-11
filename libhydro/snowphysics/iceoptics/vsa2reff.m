function r = vsa2reff(V,SA)
%va2reff converts the total volume and total surface area to
%equivalent spherical grain size (radius)
% grain_radius = m
% volume = m3
% surface area = m2
r = 3.*V./SA;
end

