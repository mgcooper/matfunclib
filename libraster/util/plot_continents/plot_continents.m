function [ h ] = plot_continents( varargin )
%PLOT_CONTINENTS a wrapper for the MATLAB documentation to plot world
%coastlines
%   Detailed explanation goes here

worldmap world
load coast
[latcells, loncells] = polysplit(lat, long);
numel(latcells)
plotm(lat, long)

end

