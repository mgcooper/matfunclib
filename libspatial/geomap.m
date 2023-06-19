function varargout = geomap(lat,lon,varargin)


[latmin,latmax] = bounds(lat);
[lonmin,lonmax] = bounds(lon);

ax = worldmap([latmin,latmax],[lonmin,lonmax]);

switch nargout
   case 1
      varargout{1} = ax;
end