function [in, on] = rasterclip(R, shp)
   %RASTERCLIP clip raster by shapefile
   %
   % RASTERCLIP [in, on] = rasterclip(R, shp) clips raster referenced by R to
   % polygon SHP
   %
   % See also rasterref, georefcells, maprefcells, meshgrid

   %% parse inputs

   % confirm mapping toolbox is installed
   assert(license('test','map_toolbox')==1, ...
      [mfilename ' requires Matlab''s Mapping Toolbox.'])

   % confirm there are at least two and no more than 3 inputs
   narginchk(2,2)

   % confirm R is either MapCells or GeographicCellsReference objects
   validateattributes(R, ...
      {'map.rasterref.MapCellsReference', ...
      'map.rasterref.GeographicCellsReference', ...
      'map.rasterref.MapPostingsReference', ...
      'map.rasterref.GeographicPostingsReference'}, ...
      {'scalar'}, mfilename, 'R', 1)

   %% main function

   % construct full grids
   [X, Y] = R2grid(R);

   % convert to vectors
   xv = reshape(X, size(X,1)*size(X,2), 1);
   yv = reshape(Y, size(Y,1)*size(Y,2), 1);

   % ensure polygon is closed
   [px, py] = closePolygonParts(shp.X, shp.Y);

   % clip raster
   [in, on] = inpolygon(xv,yv,px,py);
end
