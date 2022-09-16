function [ T_p ] = potentialT( T,P,P_0 )

%   POTENTIALT computes the potential temperature given the reference
%   pressure

%   Author:     Matthew Guy Cooper.
%   Date:       1/20/2016
%   Contact:    guycooper@ucla.edu

%   INPUTS: 

%               T:          air temperature (K)
%               P:          air pressure (any unit of 
%                           pressure so long as the same as P0)
%               P0:         reference air pressure, typically chosen to be
%                           100,000 Pa

%   OUTPUTS:
%               T_p:        potential temperature (K)

%   DEPENDENCIES: 
%               physical_constants.mat

load('physicalconstants','Rd','cp');

T_p = T*(P_0/P)^(Rd/cp);

end

