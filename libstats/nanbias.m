function [ nan_bias ] = nanbias( obs,mod,dim )
%NANBIAS computes the signed mean error of a modeled population of values
%relative to some truth or "obs" 
%   Detailed explanation goes here

if nargin == 2 % user provided no dimension, assume down column
    numgood         =   sum(~isnan(obs),1);

    naninds         =   find(isnan(obs));

    mod(naninds)    =   NaN;

    nan_bias        =   nansum(mod - obs)./numgood;
    
else % user provided a dimension    

    numgood         =   sum(~isnan(obs),dim);

    naninds         =   find(isnan(obs));

    mod(naninds)    =   NaN;

    nan_bias        =   nansum(mod - obs)./numgood;

end
