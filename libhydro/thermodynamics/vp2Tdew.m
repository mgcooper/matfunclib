function [ Td ] = vp2Tdew( e )

%   VP2TDEW computes the dew point temperature from vapor pressure using
%   the Clausius Clapeyron equation 

%   Author:     Matthew Guy Cooper.
%   Date:       1/20/2016
%   Contact:    guycooper@ucla.edu

%   INPUTS: 
%               e:          partial pressure of water vapor (Pa)

%   OUTPUTS:
%               Td:         dew point temperature (K)

%   DEPENDENCIES: 
%               physical_constants.mat

% Run script to load constants
load('physicalconstants','T_0','e_s0','Rv','Lv');


Td = 1 / ( (1/T_0) - (Rv/Lv) * ( log(e/e_s0) ) );

end

