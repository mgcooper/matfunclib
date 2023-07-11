function cfs = cms2cfs(cms)
%CMS2CFS converts cubic meters per second to cubic feet per second
%
% SYNTAX
%   cfs = cms2cfs(cms)
%
% INPUTS
%   cfs = Lxw matrix or array of flow values in cubic meters per second
%
% OUTPUTS
%   cms = Lxw matrix or array of flow values in cubic feet per second
%
% RELEASE NOTES
%   Written by: Mark Raleigh (mraleig1@uw.edu), October 2010

ft = m2ft(1);
cfs = cms.*(ft.^3);
