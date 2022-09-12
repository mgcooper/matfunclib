
function afec = ssa2afec(ssa,kice,sample_density,g)
%ssa2afec converts the specific surface area to the asymptotic flux
%extinction coefficient (afec) given the absorption coefficient of ice, the
%sample density (e.g. snow or glacier ice) and the asymmetry parameter g
% specific surface area = surface area / mass = m2/kg
% absorption coefficient of ice = 1/m
% sample density = kg/m3
% asymmetry parameter = [-]

% other inputs:
% B = 1.6;            % absorption enhancment parameter 
% rho_ice = 917;      % density of pure ice
A = (3/4*1.6/917*sample_density*sample_density);
afec = sqrt(A.*kice.*ssa.*(1-g));
end

