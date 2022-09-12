function r = ssa2bubsize(ssa,rho)
% function r = ssa2bubsize(ssa,rho,dist)

%ssa2grainsize converts the specific surface area to equivalent spherical
%grain size (radius)
% ice density = kg/m3
% grain_radius = m
% specific surface area = surface area / mass = m2/kg
% r = sqrt(rho.*ssa./(N.*4*pi));

r = 3/917./ssa.*(917/rho-1);

% if nargin<2
%     r = 3/917./ssa.*(917/rho-1);
% elseif nargin==3
%     r = 
% end

