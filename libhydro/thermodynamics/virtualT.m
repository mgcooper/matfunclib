function [ T_v ] = virtualT( T,e,P )

%   virtualT computes the virtual temperature 

%   Author:     Matthew Guy Cooper.
%   Date:       1/20/2016
%   Contact:    guycooper@ucla.edu

%   Adapted from the MOD-WET toolbox. 
%   Function originally written by: Ben Wong (9/10/2012)
%   Updated by S. Margulis on 9/15/2014 to fix a singularity caused by using
%   the dewpoint temperature as the lower bound in the rootfinding search.
%   Adapted by M. Cooper on 1/20/2016 

%   INPUTS: 
%               e:          partial pressure of water vapor (any unit of 
%                           pressure so long as the same as P)
%               T:          air temperature (K)
%               P:          air pressure (any unit of 
%                           pressure so long as the same as e)

%   OUTPUTS:
%               T_v:        virtual temperature (K)

%   DEPENDENCIES: 
%               physical_constants.mat

load('physicalconstants','epsilon');

% q = vp2sh(e,P);
% T_v = T*(1 + 0.61*q);

T_v=T./(1-(1-epsilon)*(e./P));

end

