function S = table2geostruct(T, opts)

   % This is a rough implementation, needs a lot of work to inherit fields etc.

   arguments
      T tabular
      opts.geometry (1, :) char {mustBeMember(opts.geometry, ...
         {'Point', 'Polygon', 'Line', 'PolyLine'})}
   end
   geom = opts.geometry;

   try
      S = table2struct(T);
      if ~isfield(S, 'Geometry')
         [S(1:height(T)).Geometry] = deal(geom);
      end
   catch e
      S = geostructinit(geom, height(T));
   end

   % Note: If {'lat', 'long'} are used, then updategeostruct converts Geometry
   % to 'Line', even if it is already set to 'Point', so use 'Lat', 'Lon'.
   S = prepLatLonFields(S, {'Lat', 'Lon'});
   S = updategeostruct(S);
end
