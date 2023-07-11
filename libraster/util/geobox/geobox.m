function h = geobox(latlims,lonlims,varargin)
%GEOBOX draw a box in geographic coordinates
%
% h = geobox(latlims,lonlims) draws a box of size latlims lonlims on a geoaxis
% plot e.g. geoscatter, geoplot, geobubble,
%
% See also

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
   try
      gb1 = geoplot([latmin latmax],[lonmin lonmin],'r-',varargin{:});
      gb2 = geoplot([latmin latmax],[lonmax lonmax],'r-',varargin{:});
      gb3 = geoplot([latmin latmin],[lonmin lonmax],'r-',varargin{:});
      gb4 = geoplot([latmax latmax],[lonmin lonmax],'r-',varargin{:});
   catch ME

      % regular axis - use mapbox
      if strcmp(ME.identifier,'MATLAB:license:checkouterror') || ...
            strcmp(ME.identifier,'MATLAB:newplot:HoldOnMixingAxesGeneric')
         h = mapbox([lonmin lonmax],[latmin latmax]);
         return;
      end
   end
end

h.h1 = gb1;
h.h2 = gb2;
h.h3 = gb3;
h.h4 = gb4;

