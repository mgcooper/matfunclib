function [ e_s ] = t2satvp( T )

%   T2SATVP computes the saturated partial pressure of water vapor from air
%   temperature using the Clausius Clapeyron equation

%   Author:     Matthew Guy Cooper.
%   Date:       1/20/2016
%   Contact:    guycooper@ucla.edu

%   INPUTS: 
%               T:          air temperature (K)

%   OUTPUTS:
%               satvp:      saturated partial pressure of water vapor (Pa)

%   DEPENDENCIES: 
%               physical_constants.mat

% Run script to load constants
load('physicalconstants.mat','Lv','Rv','T_0','e_s0');

% Equation
e_s     =   e_s0 .* exp( Lv/Rv .* ( 1/T_0 - 1./T ));

end

