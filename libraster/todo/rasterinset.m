pathgeo = '/Users/MattCooper/Google UCLA/ArcGIS/Greenland/Greenland/Borders/';
sf = shaperead([pathgeo 'greenland_adm2_geo.shp']);

%%

% set map boundaries
latmin = 58;
latmax = 85;
lonmin = -80;
lonmax = -10;

% make the figure
figure
ax1         =   worldmap([latmin latmax],[lonmin lonmax]); hold on;
h1          =   geoshow(ax1, sf.Y, sf.X    ,           ...
                                        'DisplayType'   ,   'line'  , ...
                                        'linewidth'     ,   1.5     , ...
                                        'color'         ,   'k');
n           =   northarrow('latitude', 61, 'longitude', -22);
s           =   scaleruler; 
setm(s,'MajorTick',[0 200 400 600]);
getm(s,'XLoc');
tightmap;

% Place axes for an inset in the upper left of the map frame
ax2         =   axes('pos',[.2 .8 .1 .1]);
h2          =   geoshow(ax2, sf.Y, sf.X    ,           ...
                                        'DisplayType'   ,   'line'  , ...
                                        'linewidth'     ,   1.5     , ...
                                        'color'         ,   'k');
%%
% Set the frame fill color and set the labels. Only works with map axis
% setm(h2,'FFaceColor','w')
% mlabel; plabel; gridm % toggle off

% Make the scale of the inset axes, h2 (California), match the scale of the
% original axes, h1 (South America). Hide the map border.
% axesscale(ax1)
% set([ax1 ax2], 'Visible', 'off')
%%
% if the mapping software chose a different projection for the inset change
% it here
getm(ax1, 'mapprojection')
getm(ax2, 'mapprojection')
setm(ax1, 'mapprojection', getm(ax2, 'mapprojection'))

% expriment with changing properties of the inset
setm(ax2, 'ffacecolor', 'y')