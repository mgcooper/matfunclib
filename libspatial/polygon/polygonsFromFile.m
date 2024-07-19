function P = polygonsFromFile(P, kwargs)

   arguments
      P {mustBeFile}
      kwargs.UseGeoCoords (1, 1) logical = false
   end

   if endsWith(P, 'shp')
      sf = loadgis(P, 'UseGeoCoords', kwargs.UseGeoCoords);
      [plat, plon] = geostructCoordinates(sf, "geographic", "ascell");
      P = [plon, plat];
   else
      eid = ['exactremap:' mfilename ':InvalidFileFormat'];
      msg = '%s supports shapefiles at this time.';
      error(eid, msg, mfilename)
   end
end
