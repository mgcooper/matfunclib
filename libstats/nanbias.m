function [bias] = nanbias(obs, mod, dim)
   %NANBIAS Compute the signed mean error of a modeled population of values
   %
   % [BIAS] = NANBIAS(OBS, MOD, DIM) computes the signed mean error of MOD
   % relative to OBS along dimension DIM.
   %
   %
   % See also nancorr, nansmooth, nanmovmean

   % user provided no dimension, assume down column
   if nargin < 3 || isempty(dim), dim = 1; end

   numgood = sum(~isnan(obs), dim);
   mod(isnan(obs)) = NaN;
   bias = sum(mod - obs, dim, 'omitnan') ./ numgood;
end
