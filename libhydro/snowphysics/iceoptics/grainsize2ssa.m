function ssa = grainsize2ssa(grain_radius)
%grainsize2ssa converts the equivalent spherical grain size (radius) to
%specific surface area 
% ice density = 917 kg/m3
% grain_radius = m
% specific surface area = surface area / mass = m2/kg
ssa = 3./(917.*grain_radius); 
end

