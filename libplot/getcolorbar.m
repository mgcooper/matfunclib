function C = getcolorbar(varargin)
%GETCOLORBAR get colorbar objects in provided figure handle or the active figure
% 
% C = getcolorbar(gcf) returns the colorbar objects of gcf if any exist
% C = getcolorbar(H) returns the colorbar objects of the figure handle H
% 
% See also colorbar, getlegend

% Get the active figure, or use the one passed in.
if nargin == 0
   fig = gcf;
else
   fig = varargin{1};
end

C = findobj(fig, 'Type', 'Colorbar');
end