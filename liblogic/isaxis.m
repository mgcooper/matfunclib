function tf = isaxis(ax)
%ISAXIS return true if ax is an axes object
tf = isa(ax,'matlab.graphics.axis.Axes');

% % based on plot.m functionsignature file, might need these:
% "type":[["matlab.graphics.axis.AbstractAxes"], ["matlab.ui.control.UIAxes"]]},

