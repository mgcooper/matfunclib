clean

%%
% load the data
load topo topo
load mapmtx lt1 lg1 map1

%%
% Identify the geographic limits of the geolocated grid that was loaded
% from mapmtx.

latlim(1) = 2*floor(min(lt1(:))/2);
lonlim(1) = 2*floor(min(lg1(:))/2);
latlim(2) = 2*ceil(max(lt1(:))/2);
lonlim(2) = 2*ceil(max(lg1(:))/2);

%%
% Reference the global topo data to latitude and longitude and then trim it
% to the rectangular region enclosing the smaller grid.

topoR = georasterref('RasterSize',size(topo), ...
    'LatitudeLimits',[-90 90],'LongitudeLimits',[0 360]);
[topo1,topo1R] = maptrims(topo,topoR,latlim,lonlim);

%%
% Allocate a regular grid filled uniformly with -Inf, to receive texture
% data.

cellsPerDegree = .5;
[L1,L1R] = zerom(latlim,lonlim,cellsPerDegree);
L1 = L1 - Inf;

%%
% Overwrite L1 using imbedm, converting it from a geolocated grid to a
% regular grid, in which the values come from the discrete Laplacian of the
% elevation grid map1.

L1 = imbedm(lt1,lg1,del2(map1),L1,L1R);

%%
% Set up a map axes with the Miller projection and use meshm to draw the
% topo1 extract of the topo DEM. Render the figure as a 3-D view from a 20
% degree azimuth and 30 degree altitude, and exaggerate the vertical
% dimension by a factor of 200. Both the surface relief and coloring
% represent topographic elevation.

figure 
axesm miller
h = meshm(topo1,topo1R,size(topo1),topo1);
view(20,30)
daspectm('m',200)

%%
% Apply the L1 matrix as a texture map directly to the surface using the
% set function. The area not covered by the [lt1, lg1, map1] geolocated
% data grid appears dark blue because the corresponding elements of L1 were
% set to -Inf.

h.CData = L1;
h.FaceColor = 'texturemap';
material shiny 
camlight
lighting gouraud
axis tight