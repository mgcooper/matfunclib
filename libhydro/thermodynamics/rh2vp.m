function [ e ] = rh2vp( RH,T )
%   RH2VP computes the partial pressure of water vapor in Pa from the
%   relative humidity in %

%   Author:     Matthew Guy Cooper.
%   Date:       1/20/2016
%   Contact:    guycooper@ucla.edu

%   INPUTS: 
%               RH:         relative humidity (%)
%               T:          air temperature (K)

%   OUTPUTS:
%               e:          vapor pressure (Pa)

%   DEPENDENCIES: 
%               physical_constants.mat
%               t2satvp.m

% compute saturated vapor pressure from T
e_s     =   t2satvp(T);

% compute the vapor pressure 
e       =   (RH.*e_s)./100;

end

