function [Coord1, Coord2] = geostructCoordinates(Geom, coordinateType, outputType)
   %GEOSTRUCTCOORDINATES Extract coordinates from geostruct
   %
   %  [X, Y] = geostructCoordinates(Geom, "projected")
   %  [X, Y] = geostructCoordinates(Geom, "projected", "ascell")
   %
   %  [Lat, Lon] = geostructCoordinates(Geom, "geographic")
   %  [Lat, Lon] = geostructCoordinates(Geom, "geographic", "ascell")
   %
   %  DESCRIPTION:
   %
   %  [COORD1, COORD1] = GEOSTRUCTCOORDINATES(GEOM, COORDINATETYPE, OUTPUTTYPE)
   %  extracts coordinates from the input geostruct GEOM based on the specified
   %  COORDINATETYPE and OUTPUTTYPE. COORDINATETYPE can be "geographic" or
   %  "projected". OUTPUTTYPE can be "ascell" or "asarray".
   %
   %  The function returns Coord1 and Coord2, which could be either Lat, Lon
   %  or X, Y coordinates depending on the COORDINATETYPE and/or the fields
   %  present in GEOM.
   %
   %  If COORDINATETYPE is "geographic" and GEOM contains fields 'Lat' and
   %  'Lon', Coord1 and Coord2 will be taken from GEOM.Lat and GEOM.Lon. If GEOM
   %  contains fields 'X' and 'Y', Coord1 and Coord2 will be taken from GEOM.Y
   %  and GEOM.X.
   %
   %  If COORDINATETYPE is "projected" and GEOM contains fields 'X' and 'Y',
   %  Coord1 and Coord2 will be taken from GEOM.X and GEOM.Y.
   %
   %  INPUTS:
   %  Geom       - Struct with fields either 'Lat' and 'Lon' or 'X' and 'Y'
   %  outputType - A string, either 'ascell' or 'asarray'. If set to 'ascell',
   %               Coord1 and Coord2 will be cell arrays. If set to 'asarray',
   %               Coord1 and Coord2 will be arrays.
   %
   %  OUTPUTS:
   %  Coord1, Coord2 - Either arrays or cell arrays containing the
   %                   coordinates.
   %
   %  Matt Cooper, 06-Apr-2023, https://github.com/mgcooper
   %
   %  See also: latlonFromGeoStruct, updateCoordinates

   % TODO: Change to opts.CoordinateType, opts.outputType otherwise the
   % coordinate type must be specified i.e. this is illegal:
   % geostructCoordinates(S, "ascell") b/c "ascell" is not a valid coordinate
   % type.

   arguments
      Geom (:,:) struct
      coordinateType (1,1) string {mustBeMember(coordinateType, ...
         ["geographic", "projected"])} = "geographic"
      outputType (1,1) string {mustBeMember(outputType, ...
         ["ascell", "asarray"])} = "asarray"
   end

   if coordinateType == "geographic"

      if isfield(Geom, 'Lat') && isfield(Geom, 'Lon')

         Coord1 = {Geom.Lat};
         Coord2 = {Geom.Lon};

      elseif isfield(Geom, 'X') && isfield(Geom, 'Y')

         Coord1 = {Geom.Y};
         Coord2 = {Geom.X};
      else
         error( ...
            'Invalid input: Geostruct must contain either Lat-Lon or X-Y fields.');
      end

   elseif coordinateType == "projected"

      if isfield(Geom, 'X') && isfield(Geom, 'Y')

         Coord1 = {Geom.X};
         Coord2 = {Geom.Y};
      else
         error( ...
            'Invalid input: Geostruct must contain X-Y fields.');
      end

   end

   if outputType == "asarray"
      [Coord1, Coord2] = polyvec(Coord1, Coord2);
   end
end
