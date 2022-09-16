function [ e ] = sh2vp( q,P )

%   SH2VP computes vapor pressure from specific humidity and air pressure

%   Author:     Matthew Guy Cooper.
%   Date:       1/20/2016
%   Contact:    guycooper@ucla.edu

%   INPUTS: 
%               q:          specific humidity (mass ratio, unitless)
%               P:          air pressure in any unit of pressure, but must
%                           be same as e
%   OUTPUTS:
%               e:          partial pressure of water vapor in any unit of
%                           pressure, but must be same as P

%   DEPENDENCIES: 
%               physical_constants.mat

% Run script to load constants
load('physicalconstants','epsilon');

% Equation
e=P.*q./epsilon;
end

