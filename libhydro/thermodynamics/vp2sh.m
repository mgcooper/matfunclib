function [ q ] = vp2sh( e,P )

%   VP2SH computes specific humidity from vapor pressure and air pressure

%   Author:     Matthew Guy Cooper.
%   Date:       1/20/2016
%   Contact:    guycooper@ucla.edu

%   INPUTS: 
%               e:          partial pressure of water vapor in any unit of
%                           pressure, but must be same as P
%               P:          air pressure in any unit of pressure, but must
%                           be same as e
%   OUTPUTS:
%               q:          specific humidity (mass ratio, unitless)

%   DEPENDENCIES: 
%               physical_constants.mat

% Run script to load constants
load('physicalconstants','epsilon');

% Equation
q=epsilon*e./P;
end

