function h = geobox(latlims,lonlims)
%GEOBOX h = geobox(latlims,lonlims) draws a box of size latlims lonlims on
%a geoaxis plot e.g. geoscatter, geoplot, geobubble, 
%   Detailed explanation goes here

hold on;

latmin      =   min(latlims);
latmax      =   max(latlims);
lonmin      =   min(lonlims);
lonmax      =   max(lonlims);

gb1         =   geoplot([latmin latmax],[lonmin lonmin],'r-');
gb2         =   geoplot([latmin latmax],[lonmax lonmax],'r-');
gb3         =   geoplot([latmin latmin],[lonmin lonmax],'r-');
gb4         =   geoplot([latmax latmax],[lonmin lonmax],'r-');

% gb1         =   geoplot([latmin latmax],[lonmin lonmin],varargin);
% gb2         =   geoplot([latmin latmax],[lonmax lonmax],varargin);
% gb3         =   geoplot([latmin latmin],[lonmin lonmax],varargin);
% gb4         =   geoplot([latmax latmax],[lonmin lonmax],varargin);

h.h1        =   gb1;
h.h2        =   gb2;
h.h3        =   gb3;
h.h4        =   gb4;

end

