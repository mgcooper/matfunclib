function [pctDif, absDif, pctAnom] = gridAnomaly(normal, sample)
%GRIDANOMALY 
% 
%   [pctDif, absDif, pctAnom] = gridAnomaly(normal, sample)

absDif  =   sample - normal;
ratio   =   absDif./normal;
pctDif  =   100.*ratio;
pctAnom =   100 + pctDif;

% pctAnom =   100.*sample./normal;

