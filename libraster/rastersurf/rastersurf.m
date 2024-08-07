function varargout = rastersurf(Z, R, varargin)
   %RASTERSURF create raster surface plot using mapshow or geoshow.
   %
   % rastersurf(Z,R,varargin) project and display spatially referenced raster Z
   % associated with map/geographic raster reference object or valid referencing
   % vector/matrix R as a 2-d surface using in-built Matlab functions mapshow.m
   % or geoshow.m (Copyright 2016 The MathWorks, Inc.). Default behavior sets
   % properties ('DisplayType','surface'), ('Box','on'), ('TickDir','out'),
   % ('LineWidth',1.5), axis image, and adds a colorbar. The function accepts
   % any input to mapshow.m or geoshow.m and returns the graphics, axis, and
   % colorbar handle objects so the user can make ex-post adjustments as
   % desired.
   %
   %   This function is a wrapper for the in-built Matlab functions geoshow.m
   %   and mapshow.m (Copyright 2016 The MathWorks, Inc.). The function is
   %   designed to display spatially referenced 2-d gridded data as a surface
   %   plot by default, whereas geoshow and mapshow are more general, and are
   %   designed to display vector or raster data, requiring additional pre- or
   %   post-processing to optimize for either. The function determines
   %   on-the-fly whether planar (projected) or geographic raster data is
   %   passed to it, and inherits the functionality of either geoshow.m or
   %   mapshow.m. The function makes reasonable default assumptions about user
   %   preferences including setting 'DisplayType' to 'surface', shading flat,
   %   adding a colorbar, and a few other graphics settings. All of these can
   %   be changed, and the function accepts any argument to mapshow or
   %   geoshow, e.g. the user can modify the property 'DisplayType' from the
   %   default 'surface' to alternate values such as 'mesh', 'texturemap', or
   %   'contour', or the property 'FaceColor' (shading) to alternate values
   %   such as 'flat', 'faceted', or 'interp'. Also see rastercontour.m
   %   rastersurf3.m, and rastercontour3.m.
   %
   %   Author: Matt Cooper, guycooper@ucla.edu, May 2019
   %   Citation: Matthew Cooper (2019). matrasterlib
   %   (https://www.github.com/mguycooper/matrasterlib), GitHub. Retrieved MMM
   %   DD, YYYY
   %
   %   Syntax
   %
   %   RASTERSURF(...) displays a regular data grid Z and appends a colorbar
   %   to the current axes in the default (right) location. By default,
   %   DISPLAYTYPE is set to 'surface' and the axis is set image. Z is a 2-D
   %   array of class double. If Z is projected in map (planar) coordinates, R
   %   must be a referencing matrix or a map raster reference object that
   %   relates the subscripts of Z to map coordinates. If Z is geographic data
   %   grid, R can be a geographic raster reference object, a referencing
   %   vector, or a referencing matrix.
   %
   %   If R is a geographic raster reference object, its RasterSize property
   %   must be consistent with size(Z).
   %
   %   If R is a referencing vector, it must be a 1-by-3 with elements:
   %
   %     [cells/degree northern_latitude_limit western_longitude_limit]
   %
   %   If R is a referencing matrix, it must be 3-by-2 and transform raster
   %   row and column indices to/from geographic coordinates according to:
   %
   %                     [lon lat] = [row col 1] * R.
   %
   %   If R is a referencing matrix, it must define a (non-rotational,
   %   non-skewed) relationship in which each column of the data grid falls
   %   along a meridian and each row falls along a parallel.
   %
   %   H = RASTERSURF(...) returns a handle to a MATLAB graphics object
   %
   %   [H,AX] = RASTERSURF(...) returns a handle to a MATLAB graphics
   %   object and a MATLAB axes object
   %
   %   [H,AX,C] = RASTERSURF(...) returns a handle to a MATLAB graphics
   %   object, a MATLAB axes object, and a MATLAB colorbar object
   %
   %   RASTERSURF(..., Name, Value) specifies name-value pairs that set
   %   MATLAB graphics properties. Parameter names can be abbreviated and are
   %   case-insensitive. Refer to the MATLAB Graphics documentation on surface
   %   for a complete description of these properties and their values.
   %
   %   See also geoshow, mapshow, rastercontour, rastersurf3, rastercontour3

   %% TODO

   % accept lat, lon, z for compatibility with mapshow/geoshow, which permits lists
   % of georeferenced x,y data, but possibly also irregularly spaced data, so
   % double check if that is consistent with the intent of libraster, or if
   % rasterize should be suggested.

   % to allow postings:
   % check if R and or Rq are of type 'postings'. If so, tell the user to
   % convert to type 'cell' and exit
   % assert(~strcmp(R.RasterInterpretation,'postings') , ...
   %    ['Input argument 2, R, and input argument 3, Rq, must be of type ' ...
   %    '''cells'' rasterInterpretation. Use RPost2Cells.m to convert. ' ...
   %    'Support for type ''postings'' will be provided in a future release']);

   % support mapshow(Z, cmap, R), but see image_tricks for clarity.

   %% Check inputs

   % confirm mapping toolbox is installed
   assert( license('test','map_toolbox')==1, ...
      'rastersurf requires Matlab''s Mapping Toolbox.')

   % If varargin{2} is not a MapCells/Postings or GeographicCells/Postings
   % Reference, first try converting using refvecToGeoRasterReference, which
   % will fail if R is not a vector. Then try refmatToGeoRasterReference,
   % which will generally fail because the values in R will produce lat/lon
   % values that are inconsistent. Finally try refmatToMapRasterReference

   if (~isa(R,'map.rasterref.MapCellsReference')) && ...
         (~isa(R,'map.rasterref.GeographicCellsReference') || ...
         ~isa(R,'map.rasterref.MapPostingsReference')) && ...
         (~isa(R,'map.rasterref.GeographicPostingsReference'))
      try
         R = refvecToGeoRasterReference(R,size(Z));
      catch
         try
            R = refmatToGeoRasterReference(R,size(Z));
         catch
            try
               R = refmatToMapRasterReference(R,size(Z));
            catch
               error(['Expected input argument 2, R, to be a referencing ' ...
                  'matrix or a map raster reference object that relates ' ...
                  'the subscripts of Z to map coordinates. If Z is a ' ...
                  'geographic data grid, R can be a geographic raster ' ...
                  'reference object, a referencing vector, or a ' ...
                  'referencing matrix.']);
            end
         end
      end
   end

   % confirm Z is a numeric or logical grid of size R.RasterSize
   validateattributes(Z, {'numeric', 'logical'}, {'size', R.RasterSize}, ...
      mfilename, 'Z', 1)

   % confirm R is either a MapCells or GeographicCellsReference objects. Note,
   % this is redundant with try catch block above, but keep for further testing.
   % validateattributes(R, ...
   %    {'map.rasterref.MapCellsReference', ...
   %    'map.rasterref.GeographicCellsReference'}, ...
   %    {'scalar'}, 'rastersurf', 'R', 2)

   validateattributes(R, ...
      {'map.rasterref.MapCellsReference', ...
      'map.rasterref.GeographicCellsReference', ...
      'map.rasterref.MapPostingsReference', ...
      'map.rasterref.GeographicPostingsReference'}, ...
      {'scalar'}, mfilename, 'R', 2)

   %% convert to double if
   if isa(Z,'double') ~= 1
      Z = double(Z);
   end

   %% apply the function

   % NOTE: since this function relies on R, this is a convenient way to get meshm
   % and surfm to display the raster cells correctly using axesm based map
   % figure
   % geomap(R.LatitudeLimits, R.LongitudeLimits)
   % meshm(V, R);

   % make a surface of zeros.
   Z0 = zeros(size(Z));

   if strcmp(R.CoordinateSystemType, 'planar')
      h = mapshow(Z0, R, 'CData', Z, 'DisplayType', 'surface', varargin{:});

   elseif strcmp(R.CoordinateSystemType, 'geographic')
      h = geoshow(Z0, R, 'CData', Z, 'DisplayType', 'surface', varargin{:});
   end

   shading flat
   axis image
   hold on

   ax = gca;
   ax.Box = 'on';
   ax.TickDir = 'out';
   ax.LineWidth = 1.5;

   % % need further testing: set nan transparant and adjust aspect ratio
   % set(h,'FaceAlpha','texturemap','AlphaData',double(~isnan(Z)));
   % ax.DataAspectRatio = [diff(ax.XLim) diff(ax.XLim) diff(ax.ZLim)];

   % add colorbar using default location
   cb = colorbar;

   % make colorbar half width
   makenarrowcolorbar = false;
   if makenarrowcolorbar == true
      axpos = ax.Position;
      cbpos = cb.Position;
      cbpos(3) = 0.5*cbpos(3);
      cb.Position = cbpos;
      ax.Position = axpos;
   end

   %% arrange the outputs

   switch nargout
      case 0
      case 1
         varargout{1} = h;

      case 2
         varargout{1} = h;
         varargout{2} = ax;

      case 3
         varargout{1} = h;
         varargout{2} = ax;
         varargout{3} = cb;

      otherwise
         error('Unrecognized number of outputs.')
   end
end
