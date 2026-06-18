function varargout = rastersurf(varargin)
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

   %% Notes
   %
   % Input forms (all accept trailing mapshow/geoshow Name,Value pairs):
   %   rastersurf(Z, R)         gridded Z + raster reference (primary form)
   %   rastersurf(Z, R, cmap)   as above with an Nx3 colormap third argument
   %   rastersurf(lat, lon, Z)  geolocated coordinate/data arrays passed straight
   %   rastersurf(x,   y,   Z)  through to geoshow/mapshow (compatibility form)
   %
   % By default the raster is drawn with DisplayType 'texturemap', which renders
   % crisp, correctly-centered cells (like grid2image) while still using
   % geoshow/mapshow, rather than the interpolated look of 'surface'. Pass an
   % explicit 'DisplayType' (e.g. 'surface', 'mesh') to override. Postings
   % references do not support 'texturemap', so they fall back to 'surface'.
   %
   % Options handled by rastersurf itself (NOT forwarded to mapshow/geoshow):
   %   'transparent'      render NaN cells of Z as transparent
   %   'Colormap', cmap   apply an Nx3 colormap (equivalent to the third
   %                      positional argument; use this to disambiguate a 1-row
   %                      colormap from a 1-by-3 referencing vector)
   %
   % Both 'cells' and 'postings' references are accepted. In the (Z, R) form R
   % may also be a referencing vector/matrix (converted internally). The
   % (lat,lon,Z) form expects geolocated arrays that geoshow/mapshow accept -- it
   % is not a scattered-point gridder (use RASTERIZE for truly scattered data).

   %% Check inputs

   % confirm mapping toolbox is installed
   assert( license('test','map_toolbox')==1, ...
      'rastersurf requires Matlab''s Mapping Toolbox.')

   narginchk(2, Inf)
   args = varargin;

   % Pull out rastersurf-specific display options that are NOT forwarded to
   % mapshow/geoshow: the 'transparent' flag and a 'Colormap',cmap pair.
   [transparent, args] = localScanFlag(args, 'transparent');
   [cmap, args]        = localScanColormapNV(args);

   % Determine the input form from the leading positional arguments.
   isZR = localIsRasterRef(args{2}) || localIsRefMatVec(args{2});
   isCoord = ~isZR && numel(args) >= 3 ...
      && isnumeric(args{1}) && isnumeric(args{2}) && isnumeric(args{3});

   if isCoord
      % geolocated coordinate/data arrays, for mapshow/geoshow compatibility:
      % rastersurf(lat, lon, Z, ...) (geographic) or rastersurf(x, y, Z, ...).
      coord1 = args{1}; coord2 = args{2}; Z = args{3}; passthrough = args(4:end);
   else
      % primary form: rastersurf(Z, R, ...), with an optional Nx3 colormap as the
      % third positional argument: rastersurf(Z, R, cmap, ...).
      Z = args{1}; R = args{2}; passthrough = args(3:end);
      if isempty(cmap) && ~isempty(passthrough) && localIsColormap(passthrough{1})
         cmap = passthrough{1};
         passthrough = passthrough(2:end);
      end
   end

   % Did the caller pin a DisplayType? If not, default to 'texturemap' so cells
   % render crisply (like grid2image) instead of as an interpolated 'surface'.
   hasDisplayType = any(cellfun(@(a) (ischar(a) || isstring(a)) ...
      && strcmpi(a, 'DisplayType'), passthrough));

   %% Display

   if isCoord
      % Pass the coordinate/data arrays straight through to geoshow/mapshow,
      % deciding geographic vs planar from the coordinates themselves.
      extra = passthrough;
      if ~hasDisplayType, extra = [{'DisplayType', 'texturemap'}, extra]; end
      if isGeoGrid(coord1, coord2)
         h = geoshow(coord1, coord2, Z, extra{:});
      else
         h = mapshow(coord1, coord2, Z, extra{:});
      end
   else
      % (Z, R) / (Z, R, cmap) forms. If R is not already a raster reference
      % object, try converting it: first from a referencing vector
      % (refvecToGeoRasterReference, fails unless R is a vector), then a
      % geographic referencing matrix (usually fails on inconsistent lat/lon),
      % then a map referencing matrix. The first that succeeds wins.
      if ~localIsRasterRef(R)
         try
            R = refvecToGeoRasterReference(R, size(Z));
         catch
            try
               R = refmatToGeoRasterReference(R, size(Z));
            catch
               try
                  R = refmatToMapRasterReference(R, size(Z));
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

      % confirm R is a cells or postings reference (map or geographic)
      validateattributes(R, ...
         {'map.rasterref.MapCellsReference', ...
         'map.rasterref.GeographicCellsReference', ...
         'map.rasterref.MapPostingsReference', ...
         'map.rasterref.GeographicPostingsReference'}, ...
         {'scalar'}, mfilename, 'R', 2)

      if ~isa(Z, 'double')
         Z = double(Z);
      end

      % NOTE: since this relies on R, it is also a convenient way to display the
      % raster cells correctly with an axesm-based map using meshm/surfm:
      %   geomap(R.LatitudeLimits, R.LongitudeLimits); meshm(Z, R);

      % Choose the default DisplayType: 'texturemap' draws crisp cells, but it is
      % NOT supported for postings references, so those fall back to 'surface'.
      isPostings = isa(R, 'map.rasterref.MapPostingsReference') || ...
         isa(R, 'map.rasterref.GeographicPostingsReference');
      extra = {'CData', Z};
      if ~hasDisplayType
         if isPostings
            extra = [extra, {'DisplayType', 'surface'}];
         else
            extra = [extra, {'DisplayType', 'texturemap'}];
         end
      end
      extra = [extra, passthrough];

      % build a flat surface (ZData = zeros) colored by Z
      Z0 = zeros(size(Z));
      if strcmp(R.CoordinateSystemType, 'planar')
         h = mapshow(Z0, R, extra{:});
      else % 'geographic'
         h = geoshow(Z0, R, extra{:});
      end
   end

   % Keep the raster flat (z = 0) regardless of DisplayType.
   if isprop(h, 'ZData') && ~isempty(h.ZData)
      h.ZData = zeros(size(h.ZData));
   end

   %% Default styling

   shading flat
   axis image
   hold on

   ax = gca;
   ax.Box = 'on';
   ax.TickDir = 'out';
   ax.LineWidth = 1.5;

   % Render NaN cells (and only those) transparent when requested. This works
   % cleanly with the default 'texturemap' DisplayType, where AlphaData is
   % texture-mapped onto the faces just like CData; on a plain 'surface' the
   % per-cell mapping is unreliable.
   if transparent
      set(h, 'FaceAlpha', 'texturemap', 'AlphaData', double(~isnan(Z)));
   end

   % Apply a user-supplied colormap (from 'Colormap',cmap or the Z,R,cmap form).
   if ~isempty(cmap)
      colormap(ax, cmap);
   end

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

%% local helpers

function tf = localIsRasterRef(R)
   tf = isa(R, 'map.rasterref.MapCellsReference') || ...
      isa(R, 'map.rasterref.GeographicCellsReference') || ...
      isa(R, 'map.rasterref.MapPostingsReference') || ...
      isa(R, 'map.rasterref.GeographicPostingsReference');
end

function tf = localIsRefMatVec(R)
   % A referencing matrix (3-by-2) or referencing vector (1-by-3).
   tf = isnumeric(R) && (isequal(size(R), [3 2]) || isequal(size(R), [1 3]));
end

function tf = localIsColormap(A)
   % An Nx3 real matrix with all entries in [0,1] (a colormap).
   tf = isnumeric(A) && ismatrix(A) && size(A, 2) == 3 && size(A, 1) >= 1 ...
      && isreal(A) && all(A(:) >= 0 & A(:) <= 1);
end

function [tf, args] = localScanFlag(args, name)
   % Remove a standalone char/string flag from args; report whether it was present.
   idx = cellfun(@(a) (ischar(a) || isstring(a)) && strcmpi(a, name), args);
   tf = any(idx);
   args(idx) = [];
end

function [cmap, args] = localScanColormapNV(args)
   % Remove a 'Colormap',value name-value pair from args, if present.
   cmap = [];
   idx = find(cellfun(@(a) (ischar(a) || isstring(a)) && strcmpi(a, 'Colormap'), args));
   if ~isempty(idx)
      i = idx(end);
      if i + 1 <= numel(args)
         cmap = args{i + 1};
         args([i i + 1]) = [];
      end
   end
end
