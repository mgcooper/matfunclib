function [ RH ] = sh2rh( q,P,T )
%   SH2RH computes the relative humidity in % given the specic humidity and
%   the air pressure and air temperature

%   Author:     Matthew Guy Cooper.
%   Date:       4/29/2020
%   Contact:    guycooper@ucla.edu

%   INPUTS: 
%               q:          specific humidity (mass/mass)
%               T:          air temperature (K)
%               P:          air pressure (Pa)

%   OUTPUTS:
%               RH:         relative humidity (%)

%   DEPENDENCIES: 
%               physical_constants.mat
%               t2satvp.m

load('physicalconstants','epsilon');

% compute saturated vapor pressure from T
e_s     =   t2satvp(T);

% compute the vapor pressure 
% e       =   (q.*P)./(epsilon+(1-epsilon).*q);
e       =   sh2vp(q,P);

% compute the relative humidity
RH      =   100.*e./e_s;

end

