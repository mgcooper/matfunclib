function [vq] = scatteredInterpolation(x, y, v, xq, yq, varargin)
%SCATTEREDINTERPOLATION Interpolate scattered data using scatteredInterpolant.
% 
% [vq] = scatteredInterpolation(x, y, v, xq, yq) performs scattered interpolation
% using the default method 'natural' and no extrapolation.
%
% [vq] = scatteredInterpolation(_, method) performs scattered interpolation
% using the specified method and no extrapolation.
%
% [vq] = scatteredInterpolation(_, method, extrap) performs scattered interpolation
% using the specified method and specified extrapolation method.
%
% See also: scatteredInterpolant
%
% Note: scatteredInterpolant does not support "multivalued" interpolation,
% meaning v has additional dimensions above x, y, but the interpolant is computed
% on x, y, then applied to all values of v in the higher dimensions (like a
% time series).

% Set default method and extrapolation
method = 'natural';
extrap = 'none';

% Update method and extrapolation if specified
if nargin >= 6
   method = varargin{1};
   if nargin >= 7
      extrap = varargin{2};
   end
end

% Initialize output
vq = nan(numel(xq), size(v, 2));

% Perform interpolation for each column of v
for n = 1:size(v, 2)
   F = scatteredInterpolant(x, y, v(:, n), method, extrap);
   vq(:, n) = F(xq, yq);
end

% F = ConstructPolyInterpolant2D(x,y,xq,yq,1,8);
