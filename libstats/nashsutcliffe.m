function [ nse ] = nashsutcliffe(obs, mod, opt)
%NASHSUTCLIFFE compute the nash sutcliffe efficiency relative to model mean
%
%  [ nse ] = nashsutcliffe(obs, mod) computes a modified form of the NSE metric
%  where the reference value in the denominator is the model mean rather than
%  the observed mean.
% 
%  [ nse ] = nashsutcliffe(obs, mod, ver) computes the standard NSE metric if
%  VER=2, which is identical to the r-squared metric. Default is VER=1.
% 
% See also

assert(numel(obs)==numel(mod), 'OBS and MOD must have the same number of elements');

if nargin < 3
   opt = 1;
end

obs = obs(:); mod = mod(:);
nanvals = isnan(obs) | isnan(mod);
obs = obs(~nanvals);
mod = mod(~nanvals);
modbar = mean(mod);
obsbar = mean(obs);

switch opt
   case 1
      nse = 1 - sum( (obs-mod).^2 ) ./ sum( (obs-modbar).^2 );
   case 2
      % r-squared
      nse = 1 - sum( (obs-mod).^2 ) ./ sum( (obs-obsbar).^2 );
end

end

