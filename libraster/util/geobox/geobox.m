function h = geobox(latlims,lonlims,varargin)
%GEOBOX h = geobox(latlims,lonlims) draws a box of size latlims lonlims on
%a geoaxis plot e.g. geoscatter, geoplot, geobubble, 
%   Detailed explanation goes here

hold on;

latmin = min(latlims);
latmax = max(latlims);
lonmin = min(lonlims);
lonmax = max(lonlims);

if ismap(gca)
   gb1 = plotm([latmin latmax],[lonmin lonmin],'r-',varargin{:});
   gb2 = plotm([latmin latmax],[lonmax lonmax],'r-',varargin{:});
   gb3 = plotm([latmin latmin],[lonmin lonmax],'r-',varargin{:});
   gb4 = plotm([latmax latmax],[lonmin lonmax],'r-',varargin{:});
else
   gb1 = geoplot([latmin latmax],[lonmin lonmin],'r-',varargin{:});
   gb2 = geoplot([latmin latmax],[lonmax lonmax],'r-',varargin{:});
   gb3 = geoplot([latmin latmin],[lonmin lonmax],'r-',varargin{:});
   gb4 = geoplot([latmax latmax],[lonmin lonmax],'r-',varargin{:});
end

h.h1 = gb1;
h.h2 = gb2;
h.h3 = gb3;
h.h4 = gb4;

