function V = naninterp1(X,V,method,extrap)
%NANINTERP1 1-d interpolation over NaN values in vector X
%
%   Vq = INTERP1(X,V,Xq) interpolates to find Vq, the values of the
%   underlying function V=F(X) at the query points Xq. 
% 
% Matt Cooper, 29 Dec 2022, https://github.com/mgcooper
% 
% See also: interp1

if nargin == 2
   % NANINTERP1(X,V)
   method = 'linear';
   extrap = 'none';
elseif nargin == 3
   % NANINTERP1(X,V,method)
   extrap = 'none';
end

V(isnan(V)) = interp1(X(~isnan(V)),V(~isnan(V)),X(isnan(V)),method,extrap);