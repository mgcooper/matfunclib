function [Z,R,X,Y] = rasterize(x,y,z,varargin)
%RASTERIZE convert x,y,z data to full grids
%
% RASTERIZE construct a spatially-referenced raster Z and map/geographic
% raster reference object R from scattered data z referenced to geo/map
% coordinates x,y
% [Z,R] = RASTERIZE(x,y,z,rasterSize)
% [Z,R] = RASTERIZE(x,y,z,cellextentX,cellextentY)
% [Z,R] = RASTERIZE(___,method). Options: 'linear', 'nearest', 'natural',
% 'cubic', or 'v4'. The default method is 'natural'.
% [Z,R] = RASTERIZE(___,method,extrap). Extrapolates to missing values.
% [___,X,Y] = RASTERIZE(___) also returns 2-d coordinate arrays X,Y with
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
%   https://blogs.mathworks.com/loren/2015/07/01/natural-neighbor-a-superb-interpolation-method/
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

% must be 4-6 inputs
narginchk(4,6)

% confirm mapping toolbox is installed
assert( license('test','map_toolbox')==1, ...
   [mfilename ' requires Matlab''s Mapping Toolbox.'])

% check if lat/lon or planar and validate attributes accordingly
tf = islatlon(y,x);

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

% initialize 'method' to natural and then override if passed in by user
numarg = nargin-3; % three required arguments
method = 'natural';
checkarg = varargin{numarg};
if ischar(checkarg) || (isstring(checkarg) && isscalar(checkarg))
   method = checkarg;
   method = lower(method);
   numarg = numarg-1;
end % else, varargin{numarg} is not method

% check if 'extrap' was provided
extrap = any(cellfun(@(v) strcmp('extrap', v), varargin));
if extrap
   varargin(cellfun(@(v) strcmp('extrap', v), varargin)) = [];
   numarg = numarg -1;
end

% parse remaining args
switch numarg
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
end

%% we now have 1) rasterSize or 2) cellextent, build the spatial reference object R

% Check if the user passed in regularly-spaced data that isn't gridded
tfreg = isxyregular(x,y);
if tfreg == true % if so, then simply grid it
   [X,Y] = meshgrid(unique(x(:),'sorted'),flipud(unique(y(:),'sorted')));
   Z = reshape(z,size(X,1),size(Y,2));
   R = rasterref(x,y,'cellInterpretation','cells');

   % check for missing values
   if any(isnan(Z(:))) && extrap
      Z = inpaintn(Z);
      prec = ceil(log10(Z));
      prec(prec>0) = 0;
      Z = round(Z, mode(prec(:)));
   end

else % build a query grid and interpolate the scattered data onto it

   % Determine the x-y extent of the interpolation query grid. This method
   % attempts to account for both very small and large domains. It might not
   % work all the time.
   xdiffs = abs(diff(x(:)));
   ydiffs = abs(diff(y(:)));
   xmindif = min(xdiffs(xdiffs>0.0));
   ymindif = min(ydiffs(ydiffs>0.0));
   xtol = floor(log10(xmindif))-1;
   ytol = floor(log10(ymindif))-1;
   xmin = round(min(x(:)),-xtol);
   xmax = round(max(x(:)),-xtol); % extending by xmindif can substantially increase the extent
   ymin = round(min(y(:)),-ytol);
   ymax = round(max(y(:)),-ytol);

   % This can rectify some issues where rounding to x/ytol fails to
   % encompass the entire extent, but extending by xmindif can also
   % substantially increase the extent and therefore slow down the
   % function because it increases the interpolation below

   % ymin = round(min(y(:)),-ytol)-ymindif;
   % ymax = round(max(y(:)),-ytol)+ymindif;
   % xmin = round(min(x(:)),-xtol)-xmindif;
   % xmax = round(max(x(:)),-xtol)+xmindif;
   xlims = [xmin xmax];
   ylims = [ymin ymax];

   % i could also push the extent outward by 1/10th of its value ...
   % xoffset = (max(x(:))-min(x(:)))/10; % but this will fail for global datasets
   % yoffset = (max(y(:))-min(y(:)))/10;

   % determine if the data is planar or geographic and build the R object

   % NOTE: to allow either rasterSize or cellextent to be specified, I use
   % inbuilt map/georefcells, but that means the lat/lon limits are not
   % adjusted for 1/2 cell size as they would be with rasterref.
   % since the data are scattered, we cannot know the desired cell size
   % unless the user provides it. If provided, we can adjust the x/y
   % limits in the R structure by 1/2 cell size so the raster is correctly
   % interpreted as an image. Below this tf block, I use R2grid to
   % construct the X,Y query grid, but R2grid assumes the R structure was
   % built correctly using rasterref and adjusts for 1/2 cell size INWARD
   % i.e. it assumes the x,y limits in R are the image borders, not the
   % outermost x,y cell centers.

   % to avoid all of this, I could build the grid myself and then use
   % rasterref, which is basically the opposite of this approach. But then
   % I would need to figure out how to deal with rasterSize vs cellExtent
   % checking. For now I am leaving it alone.

   if tf
      if inrasterSize
         R = georefcells(ylims,xlims,rasterSize, ...
            'ColumnsStartFrom', 'north', ...
            'RowsStartFrom','west');
      else
         R = georefcells(ylims,xlims,cellextentY,cellextentX, ...
            'ColumnsStartFrom', 'north', ...
            'RowsStartFrom','west');
      end
   else % note: x,y positioning is reversed for maprefcells
      if inrasterSize
         R = maprefcells(xlims,ylims,rasterSize, ...
            'ColumnsStartFrom', 'north', ...
            'RowsStartFrom','west');
      else
         R = maprefcells(xlims,ylims,cellextentX,cellextentY, ...
            'ColumnsStartFrom', 'north', ...
            'RowsStartFrom','west');
      end
   end

   % build a grid and reshape to arrays for interpolation
   [X,Y] = R2grid(R);
   xq = reshape(X,size(X,1)*size(X,2),1);
   yq = reshape(Y,size(Y,1)*size(Y,2),1);

   % convert from geographic/map coordinates to intrinsic to improve the speed
   % and accuracy of the interpolation. note the order of output xq,yq vs input
   % xq,yq for geographicToIntrinsic.

   % Commented this out pending further tests. Does this reduce the precision of
   % the x,y coordinates, e.g. if you have a scattered coordinate that is within
   % a grid cell, that scattered coordinate gets converted to an intrinsic grid
   % cell coordinate, unless worldToIntrinsic has sub-grid cell precision.
   % Keeping it for refrence.

   % if tf % note order of output xq,yq vs input xq,yq
   %    [xq,yq] = geographicToIntrinsic(R,yq,xq);
   %    [x,y] = geographicToIntrinsic(R,y,x);
   % else
   %    [xq,yq] = worldToIntrinsic(R,xq,yq);
   %    [x,y] = worldToIntrinsic(R,y,x);
   % end

   % apply griddata and reshape to a grid
   Z = griddata(x,y,z,xq,yq,method);

   assert(~isempty(Z), ['The interpolated surface, Z, is empty. You may not ' ...
      'have provided sufficient x,y values to fit a surface.']);
   Z = reshape(Z,size(X,1),size(X,2));

end

%%
function [B, R] = gridmapdata(X, Y, V, cellsize, method, extrap)
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
%   [B,R] = GRIDMAPDATA(_, METHOD, EXTRAP) uses the specified extrapolation scheme
%   EXTRAP to extrapolate values outside the area covered by V.
% 
%   NOTE: Unlike the Matlab function GEOLOC2GRID, this function correctly
%   adjusts the raster XWORLDLIMITS and YWORLDLIMITS by 1/2 cellsize OUTWARD
%   from the minimum and maximum X, Y coordinates. This is consistent with an
%   interpretation that X and Y represent the coordinates of grid cell (raster)
%   CENTERS, not frame edges. 
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
   method (1,1) string {mustBeMember(method, ["linear", "nearest", "natural"])} = "linear"
   extrap (1,1) string {mustBeMember(extrap, ["linear", "nearest", "none"])} = "none"
end

validateGridCoordinates(X, Y, mfilename, 'X', 'Y', 'coordinates')
if any(size(Y) ~= size(V))
   error("matfunclib:validate:inconsistentSizes3", mfilename, "X", "Y", "V")
end

% Use 1/2 cell size to extend the GRID pixels to the MAP LIMITS
halfcell = cellsize/2;

% Obtain the minimum and maximum X and Y grid cell center values and adjust them
% to create map frame limits (X/YWORLDLIMITS).
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

%%
function [B, R] = gridgeodata(lat, lon, V, cellsize, method, extrap)
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
%   with an interpretation that X and Y represent the coordinates of grid cell
%   (raster) CENTERS, not frame edges.
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
   method (1,1) string {mustBeMember(method, ["linear", "nearest", "natural"])} = "linear"
   extrap (1,1) string {mustBeMember(extrap, ["linear", "nearest", "none"])} = "none"
end

checklatlon(lat, lon, mfilename, "LAT", "LON", 1, 2);
if any(size(lat) ~= size(V))
   error("matfunclib:validate:inconsistentSizes3", mfilename, "LAT", "LON", "A")
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






