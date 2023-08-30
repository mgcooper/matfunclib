function [colors] = defaultcolors()
%GETDEFAULTCOLORS Returns the default color triplets
% 
%  [colors] = defaultcolors() returns the default color order triplets
% 
% See also: distinguishable_colors

colors = get(groot,'defaultaxescolororder');

% add some additional colors 
newcolors = [0.25 0.80 0.54      % turquoise
             0.76 0.00 0.47      % magenta
             0.83 0.14 0.14
             1.00 0.54 0.00
             0.47 0.25 0.80];

colors = [colors; newcolors];

