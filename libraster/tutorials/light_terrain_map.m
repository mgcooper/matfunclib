clean

%% Light a Terrain Map of a Region

% This example shows how to add lighting to terrain maps using the lightm
% function. To achieve finer control over light positions (for example, in
% small areas lit by several lights), you have to specify light positions
% using projected coordinates because light objects are children of axes
% and share their coordinate space.

%% 
% Create a terrain map.

latlim = [ 41.20  41.95];
lonlim = [-70.95 -70.10];
cd dted\w071 % Note: Your absolute path may vary.
samplefactor = 1;
[capeterrain, caperef] = dted('n41.dt0', samplefactor, ...
   latlim, lonlim);
capeterrain(capeterrain == 0) = -1;
capecoast = shaperead('usastatehi', ...
   'UseGeoCoords', true, ...
   'BoundingBox', [lonlim' latlim']);

%%
% Construct a map of the region within the specified latitude and longitude
% limits.

figure
ax = usamap(latlim,lonlim);
geoshow(ax,capecoast,'FaceColor','none');
geoshow(ax,capeterrain,caperef,'DisplayType','texturemap');
demcmap(capeterrain)

%% 
% Set the vertical exaggeration. Use daspectm to specify that elevations
% are in meters and should be multiplied by 20.

daspectm('m',20)

%% 
% Make sure that the line data is visible. To ensure that it is not
% obscured by terrain, use zdatam to set it to the highest elevation of the
% cape1 terrain data.

zdatam('allline',max(capeterrain(:)))

%%
% Specify a location for a light source with the lightm function. (If you
% omit arguments, a GUI for setting positional properties for the new light
% opens.)

lightm(42,-71)

%% 
% The lighting computations caused the map to become quite dark with
% specular highlights. Now restore its luminance by specifying three
% surface reflectivity properties in the range of 0 to 1.

ambient = 0.7; diffuse = 1; specular = 0.6;
material([ambient diffuse specular])

%% 
% The surface looks blotchy because there is no interpolation of the
% lighting component (flat facets are being modeled). Correct this by
% specifying Gouraud shading

lighting Gouraud

%% 
% To compare the lit map with the unlit version, toggle the lighting off.

lighting none