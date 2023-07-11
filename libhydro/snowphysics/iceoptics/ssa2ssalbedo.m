function omega = ssa2ssalbedo(ssa,kice)
%ssa2ssalbedo converts the specific surface area to the single scattering
%albedo (typically denoted omega) given the absorption coefficient of ice
% specific surface area = surface area / mass = m2/kg
% absorption coefficient of ice = 1/m
% omega = [-]

% B = 1.6;            % absorption enhancment parameter 
% rho_ice = 917;      % density of pure ice

omega = 1 - (2*1.6/917).*kice./ssa;
end

