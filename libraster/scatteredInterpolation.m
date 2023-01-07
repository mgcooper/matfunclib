function [vq] = scatteredInterpolation(x,y,v,xq,yq,varargin)
%SCATTEREDINTERPOLATION interpolate scattered data using a wrapper around
%scatteredInterpolant for the syntax x,y,v,xq,yq.
% 
%  [vq] = scatteredInterpolation(x,y,v,xq,yq) performs scattered interpolation
%  using method 'natural' and no extrapolation
% 
%  [vq] = scatteredInterpolation(__,method) performs scattered interpolation
%  using specified method and no extrapolation
% 
%  [vq] = scatteredInterpolation(__,method) performs scattered interpolation
%  using specified method and specified extrapolation method
% 
% 
% See also: 

% Note: scatteredInterpolant does not support "multivalued" interpolation
% meaning v has additional dimensions above x,y but the interpolant is computed
% on x,y then applied to all values of V in the higher dimensions (like a
% timesries)

method = 'natural';
extrap = 'none';
if nargin==6
   method = varargin{1};
elseif nargin==7
   method = varargin{1};
   extrap = varargin{2};
end

vq = nan(numel(xq),size(v,2));
for n = 1:size(v,2)
   F = scatteredInterpolant(x,y,v(:,n),method,extrap);
   vq(:,n) = F(xq,yq);
end


% 
% F = ConstructPolyInterpolant2D(x,y,xq,yq,1,8);
