function [Lat,Lon] = latlonFromGeoSruct(Geom,outputType)
   %LATLONFROMGEOSRUCT Extract latitude and longitude field from geostruct
   %
   %  [LAT,LON] = LATLONFROMGEOSRUCT(GEOM) returns cell arrays LAT,LON from fields
   %  in geostruct GEOM
   %
   % Matt Cooper, 06-Apr-2023, https://github.com/mgcooper
   %
   % See also:

   arguments
      Geom (:,:) struct
      outputType (1,1) string {mustBeMember(outputType, ...
         ["ascell","asarray"])} = "asarray"
   end

   [Lat,Lon] = polyvec({Geom.Lat},{Geom.Lon});

   if outputType == "ascell"
      [Lat,Lon] = polycells(Lat,Lon);
   end

   % simple, but doesn't check for nan-separators
   % Lat = [S(:).Lat];
   % Lon = [S(:).Lon];
end
