function [ T_w ] = vp2Twetbulb( e,T,P )

%   VP2WETBULB implements the bisection method to implicitly solve the 
%   wet bulb temperature equation given the vapor pressure, air 
%   temperature, and air pressure

%   Author:     Matthew Guy Cooper.
%   Date:       1/20/2016
%   Contact:    guycooper@ucla.edu

%   Adapted from the MOD-WET toolbox. 
%   Function originally written by: Ben Wong (9/10/2012)
%   Updated by S. Margulis on 9/15/2014 to fix a singularity caused by using
%   the dewpoint temperature as the lower bound in the rootfinding search.
%   Adapted by M. Cooper on 1/20/2016 

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



% Initialize error to infinity
error       =   Inf;
ep          =   0.0001; 
max_iter    =   1000;

% Compute the dew point temperature to be used as a lower bound
T_d         =   vp2Tdew(e);

% Define root upper and lower bounds; Note: The wet-bulb should be between
% the air temperature and the dewpoint temperature.
T_up        =   T;
% Note: Using the actual dewpoint temperature will cause a singularity in
% the wet bulb function below; so using a slightly larger value.
T_low       =   T_d*1.001;

% Start bisect method...
a           =   T_low;
b           =   T_up;
fa          =   wet_bulb(a,e,T,P);
fb          =   wet_bulb(b,e,T,P);

if sign(fa)*sign(fb') > 0
    disp('The function bounds are of the same sign. This means the root finder will fail. Stopping code ...')
    return
end

c = (a+b)/2;
it_count = 0;
while b-c > ep && it_count < max_iter
    it_count = it_count + 1;
    fc = wet_bulb(c,e,T,P); 
%   Internal print of bisection method. Tap the carriage
%   return key to continue the computation.
% 	disp('    it_count       a            b            c            b-c            f(c)');
%	[it_count a b c b-c fc];
    if sign(fb)*sign(fc) <= 0
        a = c;
        fa = fc;
    else
        b = c;
        fb = fc;
    end
    c = (a+b)/2;
end
T_w=c;

return

function val = wet_bulb(Tw,e,T,P)
% This function is the function used in the root finding process to
% determine the wet bulb temperature. It is simply the wet bulb equation
% written such that f(T_w)=0 i.e. a function of the wet bulb temperature
% equal to sero.

% Run script to load constants
load('physicalconstants','cp','Lv');

q=vp2sh(e,P);
q_s=vp2sh(t2satvp(Tw),P);

val=Lv/cp-(T-Tw)./(q_s-q);

return

end

end