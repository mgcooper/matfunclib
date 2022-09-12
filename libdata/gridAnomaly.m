function [ pctDif,absDif,pctAnom ] = gridAnomaly( normal,sample )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

absDif  =   sample - normal;
ratio   =   absDif./normal;
pctDif  =   100.*ratio;
pctAnom =   100 + pctDif;

% pctAnom =   100.*sample./normal;

end

