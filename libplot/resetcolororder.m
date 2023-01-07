function resetcolororder(varargin)
%RESETCOLORORDER reset the color order of the target axes to the default first
%color.
% 
%  resetcolororder() resets the current axis to color order index 1
% 
%  resetcolororder(obj) resets the axes 'obj' to color order index 1
% 
% See also:

if nargin < 1
   ax = gca;
end
set(ax,'ColorOrderIndex',1)
