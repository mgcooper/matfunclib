function varargout = geomap(lat, lon, varargin)
   %GEOMAP Initialize a worldmap in geographic coordinates
   %
   %  ax = geomap(lat, lon) creates a worldmap with
   %  limits = bounds(lat), bounds(lon)
   %
   % See also: getgcm

   if nargin == 0
      ax = worldmap([-90 90], [-180 180]);
      return
   elseif nargin == 3
      xbuffer = varargin{1};
      ybuffer = xbuffer;
   elseif nargin == 4
      xbuffer = varargin{1};
      ybuffer = varargin{2};
   else
      xbuffer = 0;
      ybuffer = 0;
   end

   [latmin, latmax] = bounds(double(lat(:)));
   [lonmin, lonmax] = bounds(double(lon(:)));

   latmin = latmin - (latmax - latmin) * ybuffer/100;
   latmax = latmax + (latmax - latmin) * ybuffer/100;

   lonmin = lonmin - (lonmax - lonmin) * xbuffer/100;
   lonmax = lonmax + (lonmax - lonmin) * xbuffer/100;

   ax = worldmap([latmin, latmax], [lonmin, lonmax]);

   switch nargout
      case 1
         varargout{1} = ax;
   end
end
