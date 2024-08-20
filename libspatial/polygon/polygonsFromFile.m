function [polygons, shapefile, names] = polygonsFromFile(filename, kwargs)

   arguments(Input)
      filename {mustBeFile}
      kwargs.UseGeoCoords (1, 1) logical = false
   end
   % arguments(Output)
   %    polygons
   %    shapefile
   %    names
   % end

   if endsWith(filename, 'shp')
      shapefile = loadgis(filename, 'UseGeoCoords', kwargs.UseGeoCoords);
      [plat, plon] = geostructCoordinates(shapefile, "geographic", "ascell");
      polygons = [plon, plat];
      names = parsePolygonNames(shapefile, polygons);
   else
      eid = ['custom:' mfilename ':InvalidFileFormat'];
      msg = '%s supports shapefiles at this time.';
      error(eid, msg, mfilename)
   end
end
