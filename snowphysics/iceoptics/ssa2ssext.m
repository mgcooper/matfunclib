function sigma_e = ssa2ssext(ssa,sample_density)
%ssa2ssext converts the specific surface area to the single scattering
%extinction coefficient (typically denoted sigma_e) given the sample
%density (e.g. snow, glacier ice) 
% sample_density = kg/m3
% specific surface area = surface area / mass = m2/kg
% sigma_e = 1/m
sigma_e = ssa.*sample_density./2;
end

