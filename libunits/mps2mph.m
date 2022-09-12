% Converts meters per second to miles per hour
% 
% RELEASE NOTES
%   Written by: Mark Raleigh (mraleig1@uw.edu), October 2010
% 
% SYNTAX
%   mph = mps2mph(mps)
% 
% INPUTS
%   mps = Lxw matrix or array of velocity in meters per second 
% 
% OUTPUTS
%   mph = Lxw matrix or array of velocity in miles per hour


function mph = mps2mph(mps)

%% Code

m_in_mi = ft2m(5280);

s_in_hr = 3600;

mph = (mps/m_in_mi)*s_in_hr;

