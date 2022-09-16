function [ T_w ] = vp2wetbulb2( e,T,P )

%   VP2WETBULB2 implements an iterative solution to the 
%   wet bulb temperature equation given the vapor pressure, air 
%   temperature, and air pressure. Not as well vetted as vp2wetbulb, which
%   was adapted (copied essentially) from Steve Margulis' MOD-WET model.
%   Keeping for reference, thoguh. 

%   Author:     Matthew Guy Cooper.
%   Date:       1/20/2016
%   Contact:    guycooper@ucla.edu

%   INPUTS: 
%               e:          partial pressure of water vapor (Pa)
%               T:          air temperature (K)
%               P:          air pressure (Pa)

%   OUTPUTS:
%               Tw:         wet bulb temperature (k)

%   DEPENDENCIES: 
%               physical_constants.mat
%               t2satvp.m
%               vp2Tdew.m
%               vp2sh.m

load('physicalconstants','Lv','cp','e_s0','Rv','T_0','epsilon')
maxiter = 10000;
tol = 0.0001;


q = vp2sh(e,P);
Td = vp2Tdew(e);

% initialize stuff
guess = Td;
dif = 0.01;
iter = 0;

while dif > tol && iter < maxiter

    iter = iter + 1;

    T_w = (1/T_0-log((P*(cp*T+Lv*q-cp*guess))/(Lv*epsilon*e_s0))*Rv/Lv)^-1;
    
    dif = abs(guess - T_w);
    
    guess = T_w;
end


end

