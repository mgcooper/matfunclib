function [ax,h1,h2] = squeezeplotyy( X1,Y1,X2,Y2,varargin )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

Y1    =   squeeze(Y1);
Y2    =   squeeze(Y2);

[ax,h1,h2] = plotyy(X1,Y1,X2,Y2,varargin{:});


end

