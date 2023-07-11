function r = ssa2grainsize(ssa)
%ssa2grainsize converts the specific surface area to equivalent spherical
%grain size (radius)
% ice density = kg/m3
% grain_radius = m
% specific surface area = surface area / mass = m2/kg
r = 3./(ssa.*917);
end

