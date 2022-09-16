%Description: This function is really just a mechanism to store physical
%constants that are used by many other functions. It is therefore often
%loaded at the beginning of other functions. Note: Some of these may not
%truly be constants (i.e. may vary with temperature), but are used as such
%for simplicity.

%save_data = 1;

%%% Disclaimer:
%%% This program and all related codes that are part of the "MOdular 
%%% Distributed Watershed Educational Toolbox" (hereafter "MOD-WET" or 
%%% "software") is designed for instructional and educational use. 
%%% Commercial use is prohibited. The software is provided 'as is' without 
%%% warranty of any kind, either express or implied. MOD-WET could include 
%%% technical or other mistakes, inaccuracies or typographical errors. The 
%%% use of the software is done at your own discretion and risk and with 
%%% agreement that you will be solely responsible for any damage and that 
%%% the authors and their affiliate institutions accept no responsibility 
%%% for errors or omissions in the software or documentation. In no event 
%%% shall the authors or their affiliate institutions be liable to you or 
%%% any third parties for any special, indirect or consequential damages of 
%%% any kind, or any damages whatsoever.
%%%
%%% Any bugs that are found can be reported to: Steve Margulis
%%% (margulis@seas.ucla.edu) where we will make every effort to fix them 
%%% for future releases.

%Physical Constants
cp            = 1004;    % Specific heat capacity of air (J/kg/K)
ci            = 2102;    % Specific heat capacity of ice (J/kg/K)
cw            = 4180;    % Specific heat capacity of water (J/kg/K)
rhow          = 1000;    % Density of water (kg/m^3)
rhoi          = 917;     % Density of ice (kg/m^3)
Rd            = 287;     % Ideal gas constant of dry air (J/kg/K)
Rv            = 461;     % Ideal gas constant of water vapor (J/kg/K)
epsilon       = 0.622;   % Rd/Rv (-)
e_s0          = 611;     % Reference staurated vapor pressure in
                         % Clausius-Clapeyron Equatioin (Pa)
T_0           = 273.15;  % Reference temperature in Clausius-Clapeyron Equatioin (K)
Lv            = 2.5e6;   % Latent heat of vaporzation (J/kg)
Lf            = 3.34e5;  % Latent heat of fusion (J/kg)
Ls            = 2.83e6;  % Latent heat of sublimation (J/kg)
g             = 9.81;    % Acceleration of gravity (m/s^2)
S0            = 1367;    % Solar constant in (W/m^2)
SB_const      = 5.67e-8; % Stefan-Boltzman constant (W/m^2/K^4)
kappa         = 0.4;     % Von Karman constant (-)
N0            = 0.08;    % Marshall-Palmer parameter (cm^-4)
gamma         = 64.6;    % Psychrometric constant (Pa/K)
T_f           = 273.15;  % Water freezing temp.(K)
gamma_d       = 9.800;   % dry adiabatic lapse rate [K/km]
k_water       = 0.552;   % Thermal conductivity water at 0oC [W m-1 K-1];
k_ice         = 2.10;    % Thermal conductivity ice at 0oC [W m-1 K-1];

% note: 
% water viscosity is 1 mPa * s = 1e-3 Pa*s = 1e-3 

info.cp       = 'Specific heat capacity of air (J/kg/K)';
info.rhow     = 'Density of water (kg/m^3)';
info.rhoi     = 'Density of ice (kg/m^3)';
info.ci       = 'Specific heat capacity of ice (J/kg/K)';
info.Rd       = 'Ideal gas constant of dry air (J/kg/K)';
info.Rv       = 'Ideal gas constant of water vapor (J/kg/K)';
info.epsilon  = 'Rd/Rv (-)';
info.e_s0     = 'Reference staurated vapor pressure in Clausius-Clapeyron Equatioin (Pa)';
info.T_0      = 'Reference temperature in Clausius-Clapeyron Equatioin (K)';
info.Lv       = 'Latent heat of vaporzation (J/kg)';
info.Lf       = 'Latent heat of fusion (J/kg)';
info.Ls       = 'Latent heat of sublimation (J/kg)';
info.g        = 'Acceleration of gravity (m/s^2)';
info.S0       = 'Solar constant in (W/m^2)';
info.SB_const = 'Stefan-Boltzman constant (W/m^2/K^4)';
info.kappa    = 'Von Karman constant (-)';
info.N0       = 'Marshall-Palmer parameter (cm^-4)';
info.gamma    = 'Psychrometric constant (Pa/K)';
info.T_f      = 'Water freezing temp.(K)';
info.gamma_d  = 'dry adiabatic lapse rate [K/km]';
info.k_water  = 'Thermal conductivity of water at 0oC [W m-1 K-1]';
info.k_ice    = 'Thermal conductivity ice at 0oC [W m-1 K-1]';

%if save_data == 1
%clear save_data
%save('physical_constants.mat');
%end

