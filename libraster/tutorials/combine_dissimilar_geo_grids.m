clean

%%
% Load the geolocated data grid from the mapmtx file and the regular data
% grid from the topo file. The mapmtx file actually contains two regions
% but this example only uses the diamond-shaped portion, lt1 , lg1 , and
% map1, centered on the Middle East.

load mapmtx lt1 lg1 map1 
load topo

%%
% Compute the surface aspect, slope, and gradients for topo . This example
% only uses the slopes in subsequent steps.

[aspect,slope,gradN,gradE] = gradientm(topo,topolegend);

%%
% Use ltln2val to interpolate slope values to the geolocated grid specified
% by lt1 and lg1 . The output is a 50-by-50 grid of elevations matching the
% coverage of the map1 variable.

slope1 = ltln2val(slope,topolegend,lt1,lg1);

%%
% Set up a figure with a Miller projection and use surfm to display the
% slope data. Specify the z -values for the surface explicitly as the map1
% data, which is terrain elevation. The map mainly depicts steep cliffs,
% which represent mountains (the Himalayas in the northeast), and
% continental shelves and trenches.

figure 
axesm miller
surfm(lt1,lg1,slope1,map1)

%%
% The coloration depicts steepness of slope. Change the colormap to make
% the steepest slopes magenta, the gentler slopes dark blue, and the flat
% areas light blue:

colormap cool

%%
% Use view to get a southeast perspective of the surface from a low
% viewpoint. In 3-D, you immediately see the topography as well as the
% slope.

view(20,30)
daspectm('meter',200)

%%
% The default rendering uses faceted shading (no smooth interpolation).
% Render the surface again, this time making it shiny with Gouraud shading
% and lighting from the east (the default of camlight lights surfaces from
% over the viewer's right shoulder).

material shiny
camlight
lighting Gouraud

%%
% Finally, remove white space and re-render the figure in perspective mode.

axis tight
ax = gca;
ax.Projection = 'perspective';
