function [vq] = scatteredInterpolation(x,y,v,xq,yq,varargin)
    
    % simple wrapper around scatteredInterpolant, only works for the case
    % of x,y,v,xq,yq, which is most common in my work
    
    method = 'nearest';
    if nargin==6
        method = varargin{1};
    end
    
    F   = scatteredInterpolant(x,y,v,method);
    vq   = F(xq,yq);

