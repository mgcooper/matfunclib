function [Lat, Lon] = latlonFromGeoStruct(Geom, outputType)
   %LATLONFROMGEOSTRUCT Extract latitude and longitude field from geostruct
   %
   %  [LAT,LON] = LATLONFROMGEOSTRUCT(GEOM) returns cell arrays LAT,LON from
   %  fields in geostruct GEOM
   %
   % Matt Cooper, 06-Apr-2023, https://github.com/mgcooper
   %
   % See also:

   arguments
      Geom (:,:) struct
      outputType (1,1) string {mustBeMember(outputType, ...
         ["ascell","asarray"])} = "asarray"
   end

   [Lat, Lon] = cellsToCoords({Geom.Lat}, {Geom.Lon});

   if outputType == "ascell"
      [Lat, Lon] = coordsToCells(Lat, Lon);
   end

   % simple, but doesn't check for nan-separators
   % Lat = [S(:).Lat];
   % Lon = [S(:).Lon];

   % Another simple method that might work with nan-sep
   % Lat = cellfun(@transpose, {Geom.Lat}, 'Uniform', false);
   % Lon = cellfun(@transpose, {Geom.Lon}, 'Uniform', false);
   % Lat = vertcat(Lat{:});
   % Lon = vertcat(Lon{:});
   % [Lat, Lon] = closePolygonParts(Lat, Lon);
end
