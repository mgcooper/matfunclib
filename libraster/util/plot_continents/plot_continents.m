function [ h ] = plot_continents( varargin )
%PLOT_CONTINENTS a wrapper for the MATLAB documentation to plot world coastlines

load coastlines.mat coastlat coastlon

h.figure    = figure;
h.worldmap  = worldmap('world');
h.coastline = plotm(coastlat, coastlon,'LineWidth',1,'Color',[0.2 0.2 0.2]);

% these lines were above but unused. it splits the lat/lon into cells and could
% be used to extract features (continents, etc)
% [latcells, loncells] = polysplit(coastlat, coastlon);
% numel(latcells)