function [ nc ] = makecmap( c, n )
% MAKECMAP make smoothly-varying custom colormaps 
% 
% [ nc ] = makecmap( c, n ) linearly interpolates rgb colormap C to N levels
% 
% Inputs:
% 
% c: [n x 3] array of RGB "endmember" values to interpolate between
% n: number of desired levels in the colormap
% 
% Outputs:
% 
% cn: updated colormap with n levels
% 
% Example
% 
% makecmap([0 0 0; 0 0 1; 0 1 0], 20) produces a cmap with 20 gradations from
% WHITE to BLUE to GREEN 
%   
% WRITTEN BY: M. Dannenberg, 3/26/14
% 
% See also buildcmap, cmap, cptcmap

[nr,~] = size(c);
ns = floor((n+nr-2)/ (nr-1));
re = rem((n+nr-2), (nr-1));
nc = zeros(n, 3);
p = 1;

for i=1:(nr-1)
    btw = ns;
    if i<=re
        btw = ns+1;
    end
    f = c(i,:);
    s = c(i+1,:);
    
    R = linspace(f(1), s(1), btw);
    G = linspace(f(2), s(2), btw);
    B = linspace(f(3), s(3), btw);
    
    T = [R' G' B'];
    
    nc(p:(p+btw-1), :) = T;
    p = p+btw-1;

end
