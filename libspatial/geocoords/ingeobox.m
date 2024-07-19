function tf = ingeobox(lat,lon,latlims,lonlims)
   %INGEOBOX Find lat lon coords inside box
   %
   %  tf = ingeobox(lat,lon,latlims,lonlims)
   %
   % See also: inpolygon

   % Initialize to include all points.
   tf = true(size(lat));

   % Eliminate points that fall outside the latitude limits.
   tf(~(latlims(1) <= lat) & (lat <= latlims(2))) = false;

   % Eliminate points that fall outside the longitude limits.
   londiff = wraplon(lonlims(2) - lonlims(1), '360');
   tf(~(wraplon(lon - lonlims(1),  '360') <= londiff)) = false;
end

function lon = wraplon(lon,style)

   narginchk(1,2)

   if nargin == 1; style = '360'; end

   switch lower(style)

      case '360'
         positiveInput = (lon > 0);
         lon = mod(lon, 360);
         lon((lon == 0) & positiveInput) = 360;

      case '180'
         q = (lon < -180) | (180 < lon);
         lon(q) = wrapTo360(lon(q) + 180) - 180;

      case 'pi'
         q = (lon < -pi) | (pi < lon);
         lon(q) = wraplon(lon(q) + pi,'2Pi') - pi;

      case '2pi'
         positiveInput = (lon > 0);
         lon = mod(lon, 2*pi);
         lon((lon == 0) & positiveInput) = 2*pi;
   end
end
