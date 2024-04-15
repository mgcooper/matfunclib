function S = updateCoordinates(S, mapproj, varargin)
   %UPDATECOORDINATES Add X, Y coordinates to a Lat, Lon geostruct or visa versa
   %
   %  S = UPDATECOORDINATES(S, MAPPROJ) transforms the coordinates of the
   %  input geostruct S using the map projection defined by MAPPROJ.
   %  It will transform Latitude and Longitude to X and Y if 'Lat' and 'Lon'
   %  fields are present and append the X and Y fields to the geostruct;
   %  otherwise, it will transform X and Y to Latitude and Longitude if 'X' and
   %  'Y' fields are present and append new Lat and Lon fields.
   %
   %  S = UPDATECOORDINATES(S, MAPPROJ, VARARGIN) accepts additional
   %  parameters that are forwarded to parseMapProjection function for
   %  advanced projection definitions.
   %
   % Example:
   %  S = struct('Lat', 67.7749, 'Lon', -122.4194);
   %  mapproj = projcrs(3338, 'Authority', 'EPSG');
   %  S_updated = updateCoordinates(S, mapproj);
   % Now you can plot the struct using either mapshow or geoshow:
   %  mapshow(S_updated)
   %  geoshow(S_updated)
   %
   % Requirements:
   %  - Geostruct S must contain either 'Lat' and 'Lon' fields or 'X' and 'Y'
   %  fields.
   %
   % Outputs:
   %  - S: Modified geostruct with updated coordinates.
   %
   % See also: geostructCoordinates, updateBoundingBox, parseMapProjection

   % Flags for determining what kind of coordinate transformation is needed
   needXY = false;
   needLL = false;

   if isfield(S, 'Lat') && isfield(S, 'Lon')

      % Extract coordinates using geostructCoordinates
      [Lat, Lon] = geostructCoordinates(S, 'geographic', 'ascell');
      needXY = true;
      tfGeoCoords = true;

   elseif isfield(S, 'X') && isfield(S, 'Y')

      % Extract coordinates using geostructCoordinates
      [X, Y] = geostructCoordinates(S, 'projected', 'ascell');

      [tfGeoCoords, tfLatLonOrder] = cellfun(@(x, y) isGeoGrid(y, x), X, Y);

      if all(tfGeoCoords)
         if all(tfLatLonOrder)
            Lat = Y;
            Lon = X;
         else
            Lat = X;
            Lon = Y;
         end
         needXY = true;
      else
         needLL = true;
      end
   else
      error('Invalid input: Geostruct must contain either Lat-Lon or X-Y fields.');
   end

   % Verify the mapproj, and convert
   mapproj = parseMapProjection(false, mapproj, 'inverse', varargin{:});

   if needXY

      % Forward projection to obtain X and Y
      [X, Y] = cellfun(@(lat, lon) ...
         projfwd(mapproj, lat, lon), Lat, Lon, 'Uniform', false);
      for n = 1:numel(S)
         S(n).X = X{n};
         S(n).Y = Y{n};
      end
   elseif needLL
      % Inverse projection to obtain Lat and Lon
      [Lat, Lon] = cellfun(@(x, y) ...
         projinv(mapproj, x, y), X, Y, 'Uniform', false);
      for n = 1:numel(S)
         S(n).Lat = Lat{n};
         S(n).Lon = Lon{n};
      end
   end

   % In case it ends up being easier to use a loop, this is how I did it before
   % I wrote this function. The poly2cw and closePolygonParts prevented the
   % insertion of a phantom pole (90o Lat) for nan-separated polygons
   % for n = 1:numel(S)
   %    y = [S(n).Y];
   %    x = [S(n).X];
   %    [x, y] = poly2cw(x, y);
   %    [x, y] = closePolygonParts(x, y);
   %    [lat, lon] = projinv(mapproj, x, y);
   %
   %    % In case the steps above did not work
   %    if lat(end) == 90
   %       lat(end) = NaN;
   %       lon(end) = NaN;
   %    end
   %
   %    % This might be too conservative, instead rely on (end) check aboves
   %    % lon(lat == 90) = [];
   %    % lat(lat == 90) = [];
   %
   %    drop = (isnan(lon) && ~isnan(lat)) || (isnan(lat) && ~isnan(lon));
   %    lat(drop) = [];
   %    lon(drop) = [];
   %
   %    S(n).Lat = lat;
   %    S(n).Lon = lon;
   % end
end
