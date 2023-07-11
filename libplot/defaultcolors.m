function [colors] = defaultcolors()
%GETDEFAULTCOLORS Returns the default color triplets
% 
%  [colors] = defaultcolors() returns the default color order triplets
% 
% See also: distinguishable_colors

colors = get(groot,'defaultaxescolororder');

