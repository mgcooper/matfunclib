function ssa = bubsize2ssa(r,rho)
%ssa2grainsize converts the specific surface area to equivalent spherical
%grain size (radius)
% ice density = kg/m3
% bubble_radius = m
% specific surface area = surface area / mass = m2/kg
ssa = 3/917./r.*(917/rho-1);
end

