% Converts miles per hour to meters per second
% 
% RELEASE NOTES
%   Written by: Mark Raleigh (mraleig1@uw.edu), October 2010
% 
% SYNTAX
%   mps = mph2mps(mph)
% 
% INPUTS
%   mph = Lxw matrix or array of velocity in miles per hour
% 
% OUTPUTS
%   mps = Lxw matrix or array of velocity in meters per second


function mps = mph2mps(mph)

%% Code

m_in_mi = ft2m(5280);

s_in_hr = 3600;

mps = mph*m_in_mi/s_in_hr;

