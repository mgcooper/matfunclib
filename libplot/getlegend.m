function L = getlegend(varargin)
%GETLEGEND get the legend object of provided figure handle or the active figure
% 
% L = getlegend(gcf) returns the legend object of gcf if one exists
% L = getlegend(H) returns the legend object of the figure handle H
% 
% See also setlegend

% Get the active figure, or use the one passed in.
if nargin == 0
   fig = gcf;
else
   fig = varargin{1};
end

L = findobj(fig, 'Type', 'Legend');

   
