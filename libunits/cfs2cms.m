% Converts cubic feet per second to cubic meters per second
% 
% RELEASE NOTES
%   Written by: Mark Raleigh (mraleig1@uw.edu), October 2010
% 
% SYNTAX
%   cms = cfs2cms(cfs)
% 
% INPUTS
%   cfs = Lxw matrix or array of flow values in cubic feet per second
% 
% OUTPUTS
%   cms = Lxw matrix or array of flow values in cubic meters per second

function cms = cfs2cms(cfs)

%% Code

m = ft2m(1);

cms = cfs.*(m.^3);
