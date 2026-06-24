function [Z,R,X,Y] = rasterize(x,y,z,varargin)
   %RASTERIZE convert x,y,z data to full grids
   %
   % RASTERIZE construct a spatially-referenced raster Z and map/geographic
   % raster reference object R from scattered data z referenced to geo/map
   % coordinates x,y
   %
   % [Z,R] = RASTERIZE(x,y,z) grids x,y,z that already lie on a grid (the grid is
   %  taken from the coordinates; no rasterSize/cellextent is needed). For
   %  scattered x,y a rasterSize or cellextent is required (forms below).
   % [Z,R] = RASTERIZE(x,y,z,rasterSize)
   % [Z,R] = RASTERIZE(x,y,z,cellextentX,cellextentY)
   % [Z,R] = RASTERIZE(_,method). Options: 'linear', 'nearest', 'natural',
   %  'cubic', or 'v4'. The default method is 'natural'.
   % [Z,R] = RASTERIZE(_,method,extrap). Extrapolates to missing values.
   % [Z,R] = RASTERIZE(_,'plot'). Also displays the result with rastersurf(Z,R).
   % [Z,R] = RASTERIZE(_,proj). Applies a projcrs projection to R (as in rasterref).
   % [_,X,Y] = RASTERIZE(_) also returns 2-d coordinate arrays X,Y with
   % size equal to size(Z) that specify the x/y map/geographic coordinates of
   % each data value in Z
   %
   %   This function is similar to the in-built Matlab function geoloc2grid.m
   %   (Copyright 2016 The MathWorks, Inc.) but adds a bit more functionality.
   %   The function uses griddata instead of TriScatteredInterpolant, and
   %   instead of returning the 1-d refvec object it returns a map/geographic
   %   reference object R, which permits compatibility with the multitude of
   %   other Matlab functions that require it.
   %
   %   USAGE
   %
   %   [Z,R] = RASTERIZE(x,y,z,rasterSize) constructs spatially referenced
   %   raster Z and map/geographic raster reference object R from scattered
   %   data z with geo/map coordinates x,y with the numbers of rows and
   %   columns specified by rasterSize
   %
   %   [Z,R] = RASTERIZE(x,y,z,cellextentX,cellextentY) allows the geographic
   %   cell extents to be set precisely. The geographic limits will be
   %   adjusted slightly, if necessary, to ensure an integer number of cells
   %   in each dimenstion.
   %
   %   [Z,R] = RASTERIZE(___,method)  specifies the interpolation
   %   method used to compute Z using any of the input arguments in the
   %   previous syntaxes. method can be 'linear', 'nearest', 'natural',
   %   'cubic', or 'v4'. The default method is 'natural'. For more information
   %   on why this option is default, see:
   %   https://blogs.mathworks.com/loren/2015/07/01/natural-neighbor-a-superb-
   %     interpolation-method/
   %
   %   Notes on griddata vs scatteredInterpolant: This function is designed to
   %   return a single 2-d surface. scatteredInterpolant is faster when
   %   querying multiple values in repeated calls, but is identical when
   %   computing a single surface as in this function. Moreover griddata
   %   includes the interpolation methods 'cubic' and 'v4' (biharmonic spline)
   %   in addition to the 'linear', 'nearest', and 'natural' methods of
   %   scatteredInterpolant. One limitation of griddata is that extrapolation
   %   is not supported, but in principle extrapolation should not be used for
   %   geophysical raster data. A future release might update to file_exchange
   %   function gridfit. More work is needed to determine if that function is
   %   a better choice.
   %
   %   EXAMPLES
   %
   % See also rasterinterp, rasterref, rastersurf

   %% Check inputs

   % x,y,z + OPTIONAL (rasterSize | cellextentX,cellextentY) + method + 'extrap'
   % flag + 'plot' flag + projection (projcrs). rasterSize/cellextent is required
   % only for SCATTERED input (to set the invented grid's resolution); for input
   % that is already on a grid, the grid comes from the coordinates, so x,y,z
   % alone suffice.
   narginchk(3, 9)

   % confirm mapping toolbox is installed
   assert( license('test','map_toolbox')==1, ...
      [mfilename ' requires Matlab''s Mapping Toolbox.'])

   % check if lat/lon or planar. Use isGeoGrid -- the same detector rasterref
   % uses -- so rasterize and rasterref agree on geographic vs planar (islatlon
   % is a looser range-only check and could disagree on small integer grids).
   tf = isGeoGrid(y, x);

   % confirm x, y, and z are 2d numeric arrays of equal size
   validateattributes(x,{'numeric'},{'real','2d','nonempty','size',size(y)}, ...
      mfilename, 'x', 1)
   validateattributes(y,{'numeric'},{'real','2d','nonempty','size',size(x)}, ...
      mfilename, 'y', 2)
   validateattributes(z,{'numeric'},{'real','2d','nonempty','size',size(x)}, ...
      mfilename, 'z', 3)

   % convert to double for compatibility with scatteredInterpolant
   x = double(x);
   y = double(y);
   z = double(z);

   % Parse optional inputs. Order-independent options (the 'extrap' and 'plot'
   % flags and a projcrs projection) are pulled out FIRST so they do not interfere
   % with the positional rasterSize/cellextent/method detection below. Each is
   % removed from varargin and numarg is decremented. This keeps the existing
   % positional API intact while allowing the added options.
   numarg = nargin - 3; % three required arguments

   % 'extrap' flag -- extrapolate beyond the convex hull.
   isopt = cellfun(@(v) (ischar(v) || isstring(v)) && strcmp('extrap', v), varargin);
   extrap = any(isopt);
   varargin(isopt) = []; numarg = numarg - nnz(isopt);

   % 'plot' flag -- display the gridded result with rastersurf(Z, R).
   isopt = cellfun(@(v) (ischar(v) || isstring(v)) && strcmp('plot', v), varargin);
   doplot = any(isopt);
   varargin(isopt) = []; numarg = numarg - nnz(isopt);

   % projection -- a projcrs object, applied to R (like rasterref).
   isopt = cellfun(@(v) isa(v, 'projcrs'), varargin);
   if any(isopt); mapProj = varargin{find(isopt, 1)}; else; mapProj = []; end
   varargin(isopt) = []; numarg = numarg - nnz(isopt);

   % 'method' -- the remaining trailing char/string (default 'natural').
   method = 'natural';
   if numarg >= 1
      checkarg = varargin{numarg};
      if ischar(checkarg) || (isstring(checkarg) && isscalar(checkarg))
         method = lower(checkarg);
         numarg = numarg - 1;
      end
   end

   % parse remaining args
   hasGridSpec = true;       % a rasterSize or cellextent was supplied
   switch numarg
      case 0 % no rasterSize/cellextent -- valid only for already-gridded input
             % (the regular branch builds the grid from the coordinates). The
             % scattered branch errors below if it is reached without a spec.
         inrasterSize = false;
         hasGridSpec = false;
      case 1 % user passed in rasterSize
         inrasterSize = true;
         rasterSize = varargin{1};
         % validation is identical for map or geo coordinates
         validateattributes(rasterSize, {'numeric'}, ...
            {'real','2d','finite','positive'}, ...
            mfilename, 'rasterSize', 4)
      case 2 % user passed in cellextentX and cellextentY, validate them here
         inrasterSize = false;
         cellextentX = varargin{1};
         cellextentY = varargin{2};
         if tf % x,y are geographic coordinates
            validateattributes(cellextentX, {'numeric'}, ...
               {'real','scalar','finite','positive','<=',360}, ...
               mfilename, 'cellextentX', 4)
            validateattributes(cellextentY, {'numeric'}, ...
               {'real','scalar','finite','positive','<=',180}, ...
               mfilename, 'cellextentY', 5)
         else % x,y are map coordinates
            validateattributes(cellextentX, {'numeric'}, ...
               {'real','scalar','finite','positive'}, ...
               mfilename, 'cellextentX', 4)
            validateattributes(cellextentY, {'numeric'}, ...
               {'real','scalar','finite','positive'}, ...
               mfilename, 'cellextentY', 5)
         end
      otherwise
         error('matfunclib:rasterize:tooManyPositionalArgs', ...
            ['Expected at most rasterSize or cellextentX,cellextentY after ' ...
            'x,y,z (got %d unmatched positional arguments).'], numarg)
   end

   %% Now have 1) rasterSize or 2) cellextent, build the spatial reference R

   % Regularly-spaced input: x,y already lie on a (uniform or regular) grid, so no
   % interpolation is needed -- place z onto the grid the coordinates imply. z may
   % or may not fill every cell (a regular grid can have gaps). Classify with
   % mapGridInfo -- the SAME classifier prepareMapGrid uses internally -- so the
   % branch decision and the gridding below can never disagree (a separate
   % isxyregular test could classify a tolerance-boundary grid differently from
   % prepareMapGrid and send it down a path that then errors).
   if ~strcmp(mapGridInfo(x, y), 'irregular')

      % Guard: if every point has a distinct x AND a distinct y there is no grid
      % structure to place values into -- the data is genuinely scattered despite
      % uniform unique-value spacing. Warn (a 1xN/Nx1 grid trips only one test).
      if numel(unique(x(:))) == numel(z) && numel(unique(y(:))) == numel(z)
         warning(...
            ['This data appears to be scattered with irregular X, Y spacing. ' ...
            'Rasterize may produce incorrect results in this case.'])
      end

      % Build the implied full grid and the input->grid index mapping with
      % prepareMapGrid -- the same machinery gridxyz uses. This replaces the
      % older hand-rolled meshgrid(unique) + reshape-or-accumarray placement:
      % prepareMapGrid is the robust form of the numel/isfullgrid test, places
      % values via the I/LOC mapping (leaving gaps NaN), and also canonicalizes
      % orientation. I is true for grid cells present in the input; LOC indexes
      % those input points.
      z1 = z;
      [X, Y, ~, ~, ~, ~, I, LOC, ~, ~, tform] = prepareMapGrid(x, y, 'fullgrids');

      % If prepareMapGrid transposed/flipped the input to reach meshgrid W-E/N-S,
      % replay the SAME transforms on z so its indices line up with I/LOC.
      % Coordinate-list input is never transformed, so this is a no-op there.
      z1 = applyGridTransform(z1, tform);
      z1 = z1(:);

      % Place known values onto the full grid; cells with no data stay NaN.
      Z = nan(numel(X), 1);
      Z(I(:)) = z1(LOC(LOC > 0));
      Z = reshape(Z, size(X));

      % Gap-fill missing cells if requested. inpaintn ignores the x,y coordinates
      % and assumes unit cell spacing -- exact for a 'uniform' grid (this branch's
      % usual case) and a good approximation for a 'regular' grid (uniform per
      % axis, anisotropic spacing). Coordinate-aware gap-fill that respects
      % anisotropy is gridxyz's job (scatteredInterpolation).
      % NOTE: inpaintn lives in fexlib (libspatial/inpaintn), not on the default
      % path; 'extrap' on a gapped regular grid requires it loaded.
      if any(isnan(Z(:))) && extrap
         Z = inpaintn(Z);
         prec = ceil(log10(Z));
         prec(prec > 0) = 0;
         Z = round(Z, mode(prec(:)));
      end

      % Construct the referencing matrix.
      R = rasterref(X, Y, 'cellInterpretation', 'cells');

   else % build a query grid and interpolate the scattered data onto it

      % Scattered input has no implied grid, so a resolution is required.
      if ~hasGridSpec
         error('matfunclib:rasterize:missingGridSpec', ...
            ['Scattered (non-gridded) x,y require a rasterSize or ' ...
            'cellextentX,cellextentY argument to set the output grid resolution.'])
      end

      % Determine the x-y extent of the interpolation query grid. This method
      % attempts to account for both very small and large domains. It might not
      % work all the time.

      % Pick a rounding precision from the smallest nonzero spacing so false
      % precision in the coordinates (e.g. 67.080001) does not leak into the grid
      % limits, then round DIRECTIONALLY -- floor the mins, ceil the maxes -- so
      % the box always covers every data point. (Nearest round() here could trim
      % the extent and drop edge points; this is the clean answer reached in
      % docs/raster-conventions-journey.md sec 4.)
      %
      % Precision-from-spacing is a recurring concept in libraster, but with two
      % distinct estimators for two purposes: for already-gridded data the cell
      % size is the MODAL spacing (mapGridCellSize/isxyregular, and exactremap's
      % axis reconstruction); for inventing a grid over SCATTERED data, as here,
      % the MINIMUM nonzero spacing is the right proxy -- it preserves the finest
      % distinguishable scale. So this stays min-based; it is not the same need as
      % the modal cell-size inference. ponytail: in-place, single caller; extract a
      % scatterExtent() helper only if a second scattered caller appears.
      xdiffs = abs(diff(x(:)));
      ydiffs = abs(diff(y(:)));
      xmindiff = min(xdiffs(xdiffs > 0.0));
      ymindiff = min(ydiffs(ydiffs > 0.0));
      xscale = 10 ^ -(floor(log10(xmindiff)) - 1);
      yscale = 10 ^ -(floor(log10(ymindiff)) - 1);
      xmin = floor(min(x(:)) * xscale) / xscale;
      xmax = ceil( max(x(:)) * xscale) / xscale;
      ymin = floor(min(y(:)) * yscale) / yscale;
      ymax = ceil( max(y(:)) * yscale) / yscale;

      % xmin..ymax are the extent of the grid-point CENTERS; rasterref pads the
      % half-cell out to the EDGES when it builds R below.

      % Build a regular grid of cell CENTERS spanning the data extent, then let
      % rasterref construct the matching reference object. rasterref treats x,y as
      % cell CENTERS and pads the limits half a cell, so rasterize and rasterref
      % now return the SAME R for the same data. (This branch previously handed the
      % raw extent to geo/maprefcells -- which treat limits as cell EDGES -- then
      % R2grid'd it back, leaving the grid offset half a cell from rasterref. The
      % history is in docs/raster-conventions-journey.md.)
      if inrasterSize
         xc = linspace(xmin, xmax, rasterSize(2));
         yc = linspace(ymax, ymin, rasterSize(1)); % rows start north (N-S)
      else
         xc = xmin:cellextentX:xmax;
         yc = ymax:-cellextentY:ymin;
      end
      [X, Y] = meshgrid(xc, yc);
      R = rasterref(X, Y, 'UseGeoCoords', tf, 'silent', true);

      % Interpolation query points are the cell centers.
      xq = X(:);
      yq = Y(:);

      % Apply griddata and reshape to a grid. NOTE: griddata uses "nearest"
      % interpolation if method is "nearest" and "none" otherwise.
      Z = griddata(x, y, z, xq, yq, method);

      assert(~isempty(Z), ...
         ['The interpolated surface, Z, is empty. You may not ' ...
         'have provided sufficient x,y values to fit a surface.']);

      Z = reshape(Z, size(X, 1), size(X, 2));

      % Trim cells outside the actual data footprint. griddata already returns
      % NaN outside the convex hull for linear/natural/cubic, but 'nearest'/'v4'
      % fill the whole query box, and even the convex hull can bulge over a
      % concave domain. Mask cells outside a concave boundary of the samples so a
      % concave footprint or a 'nearest' fill does not invent values far from any
      % data. (The previous gridmember mask did EXACT coordinate matching -- right
      % for a gapped GRID, where x,y are a subset of grid nodes, but it blanks the
      % whole surface for genuinely scattered x,y, since no grid node coincides
      % with a sample. Gapped grids now take the regular branch above, so this
      % branch only ever sees scattered data.)
      xy = unique([x(:), y(:)], 'rows');
      if size(xy, 1) >= 3
         k = boundary(xy(:, 1), xy(:, 2), 0.5);
         Z(~inpolygon(X, Y, xy(k, 1), xy(k, 2))) = NaN;
      end
   end

   % Apply the optional projection and display.
   if isa(mapProj, 'projcrs')
      R.ProjectedCRS = mapProj;
   end
   if doplot
      rastersurf(Z, R)
   end
end

%% Superseded subfunctions (kept for reference)
%
% gridmapdata/gridgeodata are the original map/geo-split scattered gridders
% (modified geoloc2grid). They are NOT called by rasterize anymore and are
% retained only as reference -- hence %#ok<DEFNU>.
%
% EDGE-CONVENTION NOTE: these build R by handing floor/ceil-padded limits
% straight to maprefcells/georefcells, which treat limits as cell EDGES. The
% production scattered branch above instead builds a grid of cell CENTERS and
% calls rasterref, which pads the half cell to the edges -- so rasterize and
% rasterref now return the SAME R (see docs/raster-conventions-journey.md sec 5,
% which records that the center convention superseded this edge approach). The
% floor/ceil-to-whole-degree padding here is also the approach sec 4 flags as
% broken for small extents. Two ideas worth salvaging if these are ever revived:
% gridgeodata's longitude-wrap warning, and scatteredInterpolant's extrapolation
% support (the production branch uses griddata, which cannot extrapolate).

%%
function [B, R] = gridmapdata(X, Y, V, cellsize, method, extrap) %#ok<DEFNU>
   %GRIDMAPDATA Convert geolocated planar data array to regular data grid.
   %
   %   [B,R] = GRIDMAPDATA(X, Y, V, CELLSIZE) converts the geolocated data
   %   array, V, given geolocation points in X and Y, to produce a regular
   %   data grid, B, and the corresponding raster reference object R.
   %   CELLSIZE is a scalar that specifies the width and height of data cells
   %   in the regular data grid, using the same map units as X and Y. Data cells
   %   in B falling outside the area covered by V are set to NaN. The default
   %   setting for R.ColumnsStartFrom is 'north' and R.RowsStartFrom is 'west'.
   %
   %   [B,R] = GRIDMAPDATA(_, METHOD) uses the specified interpolation METHOD to
   %   construct the grid B. Default method is 'linear'.
   %
   %   [B,R] = GRIDMAPDATA(_, METHOD, EXTRAP) uses the specified extrapolation
   %   scheme EXTRAP to extrapolate values outside the area covered by V.
   %
   %   NOTE: Unlike the Matlab function GEOLOC2GRID, this function correctly
   %   adjusts the raster XWORLDLIMITS and YWORLDLIMITS by 1/2 cellsize OUTWARD
   %   from the minimum and maximum X, Y coordinates. This is consistent with an
   %   interpretation that X and Y represent the coordinates of grid cell
   %   (raster) CENTERS, not frame edges.
   %
   %   Example
   %   -------
   %   % Load the geolocated data array 'map1' and grid it to 1/2-degree cells.
   %   load mapmtx
   %   cellsize = 0.5;
   %   [Z, R] = GRIDMAPDATA(lt1, lg1, map1, cellsize);
   %
   %   % Create a figure
   %   f = figure;
   %   [cmap,clim] = demcmap(map1);
   %   set(f,'Colormap',cmap,'Color','w')
   %
   %   % Define map limits
   %   latlim = [-35 70];
   %   lonlim = [0 100];
   %
   %   % Display 'map1' as a geolocated data array in subplot 1
   %   subplot(1,2,1)
   %   ax = axesm('mercator','MapLatLimit',latlim,'MapLonLimit',lonlim,...
   %              'Grid','on','MeridianLabel','on','ParallelLabel','on');
   %   set(ax,'Visible','off')
   %   geoshow(lt1, lg1, map1, 'DisplayType', 'texturemap');
   %
   %   % Display 'Z' as a regular data grid in subplot 2
   %   subplot(1,2,2)
   %   ax = axesm('mercator','MapLatLimit',latlim,'MapLonLimit',lonlim,...
   %              'Grid','on','MeridianLabel','on','ParallelLabel','on');
   %   set(ax,'Visible','off')
   %   geoshow(Z, R, 'DisplayType', 'texturemap');
   %
   % See also

   % Based on GEOLOC2GRID, Copyright 1996-2022 The MathWorks, Inc.

   arguments
      X double {mustBeNumeric, mustBeReal, mustBeNonempty, mustBeFinite}
      Y double {mustBeNumeric, mustBeReal, mustBeNonempty, mustBeFinite}
      V {mustBeNumeric, mustBeReal, mustBeNonempty}
      cellsize (1,1) double {mustBePositive}
      method (1,1) string {mustBeMember(method, ...
         ["linear", "nearest", "natural"])} = "linear"
      extrap (1,1) string {mustBeMember(extrap, ...
         ["linear", "nearest", "none"])} = "none"
   end

   validateGridCoordinates(X, Y, mfilename, 'X', 'Y', 'coordinates')
   if any(size(Y) ~= size(V))
      error("matfunclib:validate:inconsistentSizes3", mfilename, "X", "Y", "V")
   end

   % Use 1/2 cell size to extend the GRID pixels to the MAP LIMITS
   halfcell = cellsize/2;

   % Obtain the minimum and maximum X and Y grid cell center values and adjust
   % them to create map frame limits (X/YWORLDLIMITS).
   xlim = [floor(min(X(:))),ceil(max(X(:)))] + [-halfcell +halfcell];
   ylim = [floor(min(Y(:))),ceil(max(Y(:)))] + [-halfcell +halfcell];

   % Apply linear interpolation on a triangular lon-lat mesh.
   F = scatteredInterpolant(X(:), Y(:), V(:), method, extrap);

   % Interpolate onto a regular grid
   [xmesh, ymesh] = meshgrid( ...
      ((xlim(1)+halfcell):cellsize:(xlim(2)-halfcell)),...
      ((ylim(1)+halfcell):cellsize:(ylim(2)-halfcell))');
   B = F(xmesh, ymesh);

   % Create the R object. Note - ColumnsStartFrom is ambiguous.
   R = maprefcells(xlim, ylim, size(B), 'ColumnsStartFrom', 'north');

   % For reference:
   % refvec = [1/cellsize, ylim(1) + cellsize*size(V,1), xlim(1)];
   % R = refvecToGeoRasterReference(refvec,size(Z)); % mgc added
end

%%
function [B, R] = gridgeodata(lat, lon, V, cellsize, method, extrap) %#ok<DEFNU>
   %GRIDGEODATA Convert geolocated data array to regular data grid
   %
   %   [B,R] = GRIDGEODATA(LAT,LON,V,CELLSIZE) converts the geolocated data
   %   array, V, given geolocation points in LAT and LON, to produce a regular
   %   data grid, B, and the corresponding raster reference object R.
   %   CELLSIZE is a scalar that specifies the width and height of data cells
   %   in the regular data grid, using the same angular units as LAT and LON.
   %   Data cells in B falling outside the area covered by A are set to NaN.
   %
   %   NOTE: Unlike the Matlab function GEOLOC2GRID, this function correctly
   %   adjusts the raster LATITUDELIMITS and LONGITUDELIMITS by 1/2 cellsize
   %   OUTWARD from the minimum and maximum X, Y coordinates. This is consistent
   %   with an interpretation that X and Y represent the coordinates of grid
   %   cell (raster) CENTERS, not frame edges.
   %
   %   Example
   %   -------
   %   % Load the geolocated data array 'map1' and grid it to 1/2-degree cells.
   %   load mapmtx
   %   cellsize = 0.5;
   %   [Z, R] = GRIDGEODATA(lt1, lg1, map1, cellsize);
   %
   %   % Create a figure
   %   f = figure;
   %   [cmap,clim] = demcmap(map1);
   %   set(f,'Colormap',cmap,'Color','w')
   %
   %   % Define map limits
   %   latlim = [-35 70];
   %   lonlim = [0 100];
   %
   %   % Display 'map1' as a geolocated data array in subplot 1
   %   subplot(1,2,1)
   %   ax = axesm('mercator','MapLatLimit',latlim,'MapLonLimit',lonlim,...
   %              'Grid','on','MeridianLabel','on','ParallelLabel','on');
   %   set(ax,'Visible','off')
   %   geoshow(lt1, lg1, map1, 'DisplayType', 'texturemap');
   %
   %   % Display 'Z' as a regular data grid in subplot 2
   %   subplot(1,2,2)
   %   ax = axesm('mercator','MapLatLimit',latlim,'MapLonLimit',lonlim,...
   %              'Grid','on','MeridianLabel','on','ParallelLabel','on');
   %   set(ax,'Visible','off')
   %   geoshow(Z, R, 'DisplayType', 'texturemap');
   %
   % See also gridmapdata, griddata, rasterize

   % Based on GEOLOC2GRID, Copyright 1996-2022 The MathWorks, Inc.

   arguments
      lat double {mustBeNumeric, mustBeReal, mustBeNonempty, mustBeFinite}
      lon double {mustBeNumeric, mustBeReal, mustBeNonempty, mustBeFinite}
      V {mustBeNumeric, mustBeReal, mustBeNonempty}
      cellsize (1,1) double {mustBePositive}
      method (1,1) string {mustBeMember(method, ...
         ["linear", "nearest", "natural"])} = "linear"
      extrap (1,1) string {mustBeMember(extrap, ...
         ["linear", "nearest", "none"])} = "none"
   end

   checklatlon(lat, lon, mfilename, "LAT", "LON", 1, 2);
   if any(size(lat) ~= size(V))
      error("matfunclib:validate:inconsistentSizes3",mfilename,"LAT","LON","A")
   end

   loncheck = max(abs(diff(sort(lon(:)))));
   if isempty(loncheck) || (loncheck > 10 * cellsize)
      warning('matfunclib:GRIDGEODATA:possibleLongitudeWrap', ...
         'Longitude values may wrap.')
   end

   % Use 1/2 cell size to extend the GRID pixels to the MAP LIMITS
   halfcell = cellsize/2;

   % Extend limits to even degrees in lat and lon and adjust them to create map
   % frame limits (LATITUDE/LONGITUDELIMITS).
   latlim = [floor(min(lat(:))),ceil(max(lat(:)))] + [-halfcell +halfcell];
   lonlim = [floor(min(lon(:))),ceil(max(lon(:)))] + [-halfcell +halfcell];

   % Apply linear interpolation on a triangular lon-lat mesh.
   F = scatteredInterpolant(lon(:), lat(:), V(:), method, extrap);

   % Interpolate onto a regular grid of CELL CENTERS
   [lonmesh, latmesh] = meshgrid( ...
      ((lonlim(1)+halfcell):cellsize:(lonlim(2)-halfcell)),...
      ((latlim(1)+halfcell):cellsize:(latlim(2)-halfcell))');
   B = F(lonmesh, latmesh);

   % Create the R object. Note - ColumnsStartFrom is ambiguous.
   R = georefcells(latlim, lonlim, size(B), 'ColumnsStartFrom', 'north');
end
