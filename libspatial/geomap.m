function varargout = geomap(lat,lon,varargin)
%GEOMAP initialize a worldmap in geographic coordinates
% 
%  ax = geomap(lat,lon) creates a worldmap with limits = bounds(lat),
%  bounds(lon)
% 
% See also: getgcm

[latmin,latmax] = bounds(lat);
[lonmin,lonmax] = bounds(lon);

ax = worldmap([latmin,latmax],[lonmin,lonmax]);

switch nargout
   case 1
      varargout{1} = ax;
end