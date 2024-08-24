function [Vq,Rq] = rasterinterp(V, varargin)
   %RASTERINTERP interpolate raster from reference R to Rq using method
   %
   % RASTERINTERP rasterinterp(V,R,Rq,method) Interpolate spatially referenced
   % raster V associated with map/geographic raster reference object R onto new
   % grid Vq defined by map/geographic raster reference object Rq. Default
   % interpolation is 'bilinear', user specifies alternate methods 'nearest',
   % 'cubic', or 'spline' following syntax of geointerp.m / mapinterp.m
   % (Copyright 2016 The MathWorks, Inc.). Works with planar (projected) and
   % geographic data, but R and Rq must both be planar or both be geographic.
   %
   %   This function is a wrapper for the in-built Matlab functions
   %   mapinterp.m and geointerp.m (Copyright 2016 The MathWorks, Inc.),
   %   designed to support gridded data by default.
   %   This function accepts and returns 2-d gridded data and accepts map or
   %   geographic raster reference objects to define a new query grid Vq,
   %   whereas mapinterp.m and geointerp.m return a vector of interpolated
   %   values at each lat/lon query pair in xq,yq, requiring additional pre-
   %   and/or post-processing for gridded dataset i/o
   %
   %   Author: Matt Cooper, guycooper@ucla.edu, May 2019
   %   Citation: Matthew Cooper (2019). matrasterlib
   %   (https://www.github.com/mguycooper/matrasterlib), GitHub. Retrieved MMM
   %   DD, YYYY.
   %
   %   Syntax
   %
   %   Vq = rasterinterp(V,R,Rq)
   %   Vq = rasterinterp(...,method)
   %
   %   Description
   %
   %   Vq = rasterinterp(V,R,Rq) interpolates the spatially referenced raster
   %   V onto a new spatially referenced raster Vq. R is a map or geographic
   %   raster reference object, which specifies the location and extent of
   %   data in V. Rq is a map or geographic raster reference object, which
   %   specifies the location and extent of data in Vq. The interpolated
   %   values in Vq correspond to each grid-cell centroid. Extrapolation is
   %   not supported; NaN is returned for spatial locations in Vq outside the
   %   limits of V
   %
   %   Vq = rasterinterp(...,method) specifies alternate methods. The default
   %   is linear interpolation. Available methods are:
   %
   %     'nearest' - nearest neighbor interpolation
   %     'linear'  - bilinear interpolation
   %     'cubic'   - bicubic interpolation
   %     'spline'  - spline interpolation
   %     'makima'  - modified Akima cubic interpolation
   %
   %   See also mapinterp, geointerp, interp2, griddedInterpolant, meshgrid
   %
   %   Examples
   %
   %   rasterinterp requires as input the Map/GeographicCellsReference or
   %   Map/GeographicPostingsReference object. This object is returned by
   %   geotiffread but can also be built if the lat/lon limits and cell size
   %   are known, as in the examples below. rasterinterp can be used to
   %   co-register two rasters that overlap to the same spatial extent and
   %   resolution so they can be compared on a cell by cell basis, which
   %   requires interpolation to a new grid. The new grid (Vq) is defined by
   %   Rq, which can be the Map/GeographicCellsReference or
   %   Map/GeographicPostingsReference object of one of the two rasters, used
   %   as a template, or it can be a new grid altogether, but care should be
   %   taken to ensure the correct interpretation is used (i.e. 'Cells' vs
   %   'Postings'). In the examples below, the in-built 'topo' dataset is used
   %   and the Geographic Cells Reference object is built from scratch.
   %   rasterinterp is used to both subset and resample 'topo' to a new
   %   spatial extent and a new resolution.
   %
   %   Example 1
   %   ---------
   %   % subset global topographic data to northern hemisphere
   %   load topo; V = topo; clear topo
   %   R = georefcells(topolatlim,topolonlim,size(V));
   %   newlatlim = [0 90];
   %   newlonlim = [0 360];
   %   newsize = [newlatlim(2) newlonlim(2)];
   %   Rq = georefcells(newlatlim,newlonlim,newsize);
   %   Vq = rasterinterp(V,R,Rq);
   %   figure; geoshow(V,R,'DisplayType','surface'); title('Original');
   %   figure; geoshow(Vq,Rq,'DisplayType','surface'); title('Subset');
   %
   %   Example 2
   %   ---------
   %   % subset global topographic data to northern hemisphere and resample
   %   the data to 3x finer resolution
   %   load topo; V = topo; clear topo
   %   R = georefcells(topolatlim,topolonlim,size(V));
   %   newlatlim = [0 90];
   %   newlonlim = [0 360];
   %   newsize = 3.*[newlatlim(2) newlonlim(2)];
   %   Rq = georefcells(newlatlim,newlonlim,newsize);
   %   Vq = rasterinterp(V,R,Rq);
   %
   %   figure;
   %   geoshow(V,R,'DisplayType','surface');
   %   title('Original')
   %
   %   figure;
   %   geoshow(Vq,Rq,'DisplayType','surface');
   %   title('Subset and Resampled')

   %% Check inputs

   narginchk(3, 7)
   % 2nd and 3rd inputs are R objects
   % Vq = rasterinterp(V,R,Rq)                     % 3 inputs
   % Vq = rasterinterp(V,R,Rq,method)              % 4 inputs
   % Vq = rasterinterp(V,R,Rq,method,extrap)       % 5 inputs

   % 2nd inputs is R object, third is grid
   % Vq = rasterinterp(V,R,Xq,Yq)                  % 4 inputs
   % Vq = rasterinterp(V,R,Xq,Yq,method)           % 5 inputs
   % Vq = rasterinterp(V,R,Xq,Yq,method,extrap)    % 6 inputs

   % 2nd and 3rd inputs are grids
   % Vq = rasterinterp(V,X,Y,Xq,Yq)                % 5 inputs
   % Vq = rasterinterp(V,X,Y,Xq,Yq,method)         % 6 inputs
   % Vq = rasterinterp(V,X,Y,Xq,Yq,method,extrap)  % 7 inputs

   % confirm mapping toolbox is installed
   assert(license('test','map_toolbox')==1, ...
      [mfilename ' requires Matlab''s Mapping Toolbox.'])

   % Determine the inputs
   useR = false;
   useRq = false;
   args = varargin;
   if isRasterReference(args{1})
      R = args{1};
      useR = true;

      if isRasterReference(args{2})    % Vq = rasterinterp(V,R,Rq,_)
         Rq = args{2};
         args = args(3:end);
         useRq = true;

      else                             % Vq = rasterinterp(V,R,Xq,Yq,_)
         assert(nargin >= 4, ...
            [mfilename ' requires at least four inputs: V, R, Xq, Yq'])

         Xq = args{2};
         Yq = args{3};
         args = args(4:end);
      end
   else                                % Vq = rasterinterp(V,X,Y,Xq,Yq,_)
      assert(nargin >= 5, ...
         [mfilename ' requires at least five inputs: V, X, Y, Xq, Yq'])

      X = args{1};
      Y = args{2};
      Xq = args{3};
      Yq = args{4};
      args = args(5:end);
   end

   % Anything remaining in args is method, extrap
   if numel(args) < 2
      extrap = 'nearest';
   else
      extrap = validatestring(args{2}, ...
         {'nearest', 'linear', 'cubic', 'spline', 'makima', 'none'}, ...
         mfilename, 'extrap');
   end
   if numel(args) < 1
      method = 'linear'; % default
   else
      method = validatestring(args{1}, ...
         {'nearest', 'linear', 'cubic', 'spline', 'makima'}, ...
         mfilename, 'method');
   end

   % The purpose of adding Xq,Yq syntax is to support non-fullgrid coordinate
   % lists, so I commented out the

   % if useRq == false
   %    % For now, create Rq. Later, simplify the parsing and use Xq, Yq directly.
   %    Rq = rasterref(Xq, Yq, 'cellInterpretation', 'cells');
   % end

   if useR && useRq

      % confirm R and Rq are either MapCells or GeographicCellsReference objects
      [V, R] = validateRasterReference(V, R, mfilename);
      [~, Rq] = validateRasterReference([], Rq, mfilename);

      % confirm V is a numeric or logical grid of size R.RasterSize
      validateattributes(V, {'numeric', 'logical'}, ...
         {'size', R.RasterSize}, mfilename, 'V', 1)

      % confirm R and Rq are either both planar or both geographic
      assert(strcmp(R.CoordinateSystemType,Rq.CoordinateSystemType), ...
         ['R and Rq must both be planar or both be ' ...
         'geographic coordinate systems. Projection ' ...
         'on the fly is not supported at this time']);

      % confirm R and Rq are oriented in the same N/S direction
      assert(strcmp(R.ColumnsStartFrom,Rq.ColumnsStartFrom), ...
         ['R and Rq must be oriented in the same N/S ' ...
         'direction. Check the ''ColumnsStartFrom'' ' ...
         'property in the Map/Geographic Cells Reference ' ...
         'object']);

      % confirm R and Rq are oriented in the same E/W direction
      assert(strcmp(R.RowsStartFrom,Rq.RowsStartFrom), ...
         ['R and Rq must be oriented in the same E/W ' ...
         'direction. Check the ''RowsStartFrom'' ' ...
         'property in the Map/Geographic Cells Reference ' ...
         'object']);

      % check if R and or Rq are of type 'postings'. If so, tell the user to
      % convert to type 'cell' and exit
      assert(strcmp(R.RasterInterpretation,'cells') && ...
         strcmp(Rq.RasterInterpretation,'cells'), ...
         ['Input argument 2, R, and input argument 3, Rq, must be of type ' ...
         '''cells'' rasterInterpretation. Use RPost2Cells.m to convert. ' ...
         'Support for type ''postings'' will be provided in a future release']);
   else

      % % X,Y parsing is complete but full syntax is not currently supported
      % error( ...
      %    ['rasterinterp currently supports the syntax \n' ...
      %    'Vq = rasterinterp(V, R, Rq, _']);
   end

   % if both R and Rq are planar/geographic, call the appropriate function
   if strcmp(R.CoordinateSystemType, 'planar')

      % build query grid of Vq grid centroids from Rq
      if useRq
         [Xq, Yq] = Rq.worldGrid;
      end

      Vq = maprasterinterp(V, R, Xq, Yq, method, extrap);

   elseif strcmp(R.CoordinateSystemType, 'geographic')

      % build query grid of Vq grid centroids from Rq
      if useRq
         [Yq, Xq] = Rq.geographicGrid;
      end

      Vq = georasterinterp(V, R, Yq, Xq, method, extrap);
   end

   if ~useRq && nargout == 2
      % error?
   end
end

%% apply the appropriate function
function Vq = maprasterinterp(V, R, Xq, Yq, method, extrap)
   %MAPRASTERINTERP Map raster interpolation.
   %
   %  Vq = MAPRASTERINTERP(V,R,xq,yq) interpolates the spatially referenced
   %  raster V, returning a value in Vq for each of the query points in
   %  arrays xq and yq. R is a map raster reference object, which
   %  specifies the location and extent of data in V.
   %
   %  Vq = MAPRASTERINTERP(...,method) specifies alternate methods.  The default
   %    is linear interpolation.  Available methods are:
   %
   %  'nearest' - nearest neighbor interpolation
   %  'linear'  - bilinear interpolation
   %  'cubic'   - bicubic interpolation
   %  'spline'  - spline interpolation
   %  'makima'  - modified Akima cubic interpolation
   %
   %  Vq = MAPRASTERINTERP(...,method,extrap) specifies alternate extrapolation
   %  method. The default is nearest neighbor. Extrapolation is used to fill in
   %  the 1/2 cell that extends beyond the grid cell centers to the
   %  World/IntrisicLimits. Unlike mapinterp/geointerp, this function uses
   %  'nearest' by default, rather than defaulting to 'method', which can
   %  produce bad results especially if 'cubic' is used.
   %
   %  Based on mapinterp, Copyright 2016 The MathWorks, Inc.
   %  Modified by Matt Cooper, 2023.
   %  Changes relative to mapinterp:
   %  extrap is set to 'nearest'.
   %  'makima' interpolation (and extrapolation) is supported.
   %
   % See also mapinterp, interp2, griddedInterpolant, meshgrid

   % Convert data types if necessary
   origClassV = class(V);
   changeClassV = ~isfloat(V);
   if changeClassV
      V = double(V);
   end

   % Make any data outside of map limits NaN (extrapolation not supported)
   % Check for query point size mismatch in the process
   try
      idxToRemove = ~contains(R, Xq, Yq);
   catch ME
      if strcmp(ME.identifier, ...
            'map:spatialref:sizeMismatchInCoordinatePairs')
         error(message('map:validate:inconsistentSizes', ...
            'xq', 'yq'))
      end
      validateattributes(Xq, {'double', 'single'}, {'real'}, ...
         mfilename, 'xq')
      validateattributes(Yq, {'double', 'single'}, {'real'}, ...
         mfilename, 'yq')
      rethrow(ME)
   end
   Xq(idxToRemove) = NaN;
   Yq(idxToRemove) = NaN;

   % Convert projected coordinates to intrinsic (row and column indices)
   % to perform the interpolation
   [cq, rq] = worldToIntrinsic(R, Xq, Yq);

   % Perform interpolation
   % Use same method for extrapolation to account for data points within
   % x and y limits, but beyond 'cells' data points
   F = griddedInterpolant(V, method, extrap);
   Vq = F(rq, cq);

   % Convert class back if necessary
   if strcmp(origClassV, 'logical') %#ok<ISLOG>
      Vq = (Vq >= 0.5);
   elseif changeClassV || isempty(Vq)
      Vq = cast(Vq, origClassV);
   end
end

function Vq = georasterinterp(V, R, latq, lonq, method, extrap)
   %GEORASTERINTERP Geographic raster interpolation.
   %
   %  Vq = GEORASTERINTERP(V,R,latq,lonq) interpolates the geographically
   %  referenced raster V, returning a value in Vq for each of the query points
   %  in arrays latq and lonq. R is a geographic raster reference object, which
   %  specifies the location and extent of data in V.
   %
   %  Vq = GEORASTERINTERP(...,method) specifies alternate methods. The default
   %  is linear interpolation.  Available methods are:
   %
   %     'nearest' - nearest neighbor interpolation
   %     'linear'  - bilinear interpolation
   %     'cubic'   - bicubic interpolation
   %     'spline'  - spline interpolation
   %     'makima'  - modified Akima cubic interpolation
   %
   %  Vq = GEORASTERINTERP(...,method,extrap) specifies alternate extrapolation
   %  method. The default is nearest neighbor. Extrapolation is used to fill in
   %  the 1/2 cell that extends beyond the grid cell centers to the
   %  World/IntrisicLimits. Unlike mapinterp/geointerp, this function uses
   %  'nearest' by default, rather than defaulting to 'method', which can
   %  produce bad results especially if 'cubic' is used.
   %
   %  Based on mapinterp, Copyright 2016 The MathWorks, Inc.
   %  Modified by Matt Cooper, 2023.
   %  Changes relative to mapinterp:
   %  extrap is set to 'nearest'.
   %  'makima' interpolation (and extrapolation) is supported.
   %
   % See also mapinterp, interp2, griddedInterpolant, meshgrid

   % Convert data types if necessary
   origClassV = class(V);
   changeClassV = ~isfloat(V);
   if changeClassV
      V = double(V);
   end

   % Make any data outside of map limits NaN (extrapolation not supported)
   % Check for query point size mismatch in the process
   try
      idxToRemove = ~contains(R, latq, lonq);
   catch ME
      if strcmp(ME.identifier, ...
            'map:spatialref:sizeMismatchInCoordinatePairs')
         error(message('map:validate:inconsistentSizes', ...
            'latq', 'lonq'))
      else
         validateattributes(latq, {'double', 'single'}, {'real'}, ...
            mfilename, 'latq')
         validateattributes(lonq, {'double', 'single'}, {'real'}, ...
            mfilename, 'lonq')
         rethrow(ME)
      end
   end
   latq(idxToRemove) = NaN;
   lonq(idxToRemove) = NaN;

   % Convert geographic coordinates to intrinsic (row and column indices)
   % to perform the interpolation
   [cq, rq] = geographicToIntrinsic(R, latq, lonq);

   % Perform interpolation
   % Use same method for extrapolation to account for data points within
   % latitude and longitude limits, but beyond 'cells' data points
   F = griddedInterpolant(V, method, extrap);
   Vq = F(rq, cq);

   % Convert class back if necessary
   if strcmp(origClassV, 'logical') %#ok<ISLOG>
      Vq = (Vq >= 0.5);
   elseif changeClassV || isempty(Vq)
      Vq = cast(Vq, origClassV);
   end
end
