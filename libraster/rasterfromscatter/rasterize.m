function [Z,R,X,Y] = rasterize(x,y,z,varargin)
%RASTERIZE construct a spatially-referenced raster Z and map/geographic
%raster reference object R from scattered data z referenced to geo/map
%coordinates x,y
%[Z,R] = RASTERIZE(x,y,z,rasterSize)
%[Z,R] = RASTERIZE(x,y,z,cellextentX,cellextentY)
%[Z,R] = RASTERIZE(___,method). Options: 'linear', 'nearest', 'natural',
%'cubic', or 'v4'. The default method is 'natural'.
%[___,X,Y] = RASTERIZE(___) also returns 2-d coordinate arrays X,Y with
%size equal to size(Z) that specify the x/y map/geographic coordinates of
%each data value in Z

%   This function is similar to the in-built Matlab function geoloc2grid.m
%   (Copyright 2016 The MathWorks, Inc.) but adds a bit more functionality.
%   The function uses griddata instead of TriScatteredInterpolant, and
%   instead of returning the 1-d refvec object it returns a map/geographic
%   reference object R, which permits compatibility with the multitude of
%   other Matlab functions that require it.

%   USAGE

%   [Z,R] = RASTERIZE(x,y,z,rasterSize) constructs spatially referenced
%   raster Z and map/geographic raster reference object R from scattered
%   data z with geo/map coordinates x,y with the numbers of rows and
%   columns specified by rasterSize

%   [Z,R] = RASTERIZE(x,y,z,cellextentX,cellextentY) allows the geographic
%   cell extents to be set precisely. The geographic limits will be
%   adjusted slightly, if necessary, to ensure an integer number of cells
%   in each dimenstion.

%   [Z,R] = RASTERIZE(___,method)  specifies the interpolation
%   method used to compute Z using any of the input arguments in the
%   previous syntaxes. method can be 'linear', 'nearest', 'natural',
%   'cubic', or 'v4'. The default method is 'natural'. For more information
%   on why this option is default, see:
%   https://blogs.mathworks.com/loren/2015/07/01/natural-neighbor-a-superb-interpolation-method/

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

%   EXAMPLES


%% Check inputs

% must be 4-6 inputs
narginchk(4,6)

% confirm mapping toolbox is installed
assert(license('test','map_toolbox')==1, ...
   'rasterize requires Matlab''s Mapping Toolbox.')

% check if lat/lon or planar and validate attributes accordingly
tf = islatlon(y,x);

% confirm x, y, and z are 2d numeric arrays of equal size
validateattributes(x,{'numeric'},{'real','2d','nonempty','size',size(y)}, ...
   'rasterize', 'x', 1)
validateattributes(y,{'numeric'},{'real','2d','nonempty','size',size(x)}, ...
   'rasterize', 'y', 2)
validateattributes(z,{'numeric'},{'real','2d','nonempty','size',size(x)}, ...
   'rasterize', 'z', 3)

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

switch numarg
   case 1 % user passed in rasterSize, validate it here
      inrasterSize = true;
      rasterSize = varargin{1};
      if tf % x,y are geographic coordinates
         validateattributes(rasterSize, {'numeric'}, ...
            {'real','2d','finite','positive'}, ...
            'rasterize','rasterSize', 4)
      else % x,y are map coordinates (validation is identical)
         validateattributes(rasterSize, {'numeric'}, ...
            {'real','2d','finite','positive'}, ...
            'rasterize','rasterSize', 4)
      end
   case 2 % user passed in cellextentX and cellextentY, validate them here
      inrasterSize = false;
      cellextentX = varargin{1};
      cellextentY = varargin{2};
      if tf % x,y are geographic coordinates
         validateattributes(cellextentX, {'numeric'}, ...
            {'real','scalar','finite','positive','<=',360}, ...
            'rasterize','cellextentX', 4)
         validateattributes(cellextentY, {'numeric'}, ...
            {'real','scalar','finite','positive','<=',180}, ...
            'rasterize','cellextentY', 5)
      else % x,y are map coordinates (validation is identical)
         validateattributes(cellextentX, {'numeric'}, ...
            {'real','scalar','finite','positive'}, ...
            'rasterize','cellextentX', 4)
         validateattributes(cellextentY, {'numeric'}, ...
            {'real','scalar','finite','positive'}, ...
            'rasterize','cellextentY', 5)
      end
end

%% we now have 1) rasterSize or 2) cellextent, build the spatial reference object R

% Check if the user passed in regularly-spaced data that isn't gridded
tfreg = isxyregular(x,y);
if tfreg == true % if so, then simply grid it
   [X,Y] = meshgrid(unique(x(:),'sorted'),flipud(unique(y(:),'sorted')));
   Z = reshape(z,size(X,1),size(Y,2));
   R = rasterref(x,y,'cell');
else % build a query grid and interpolate the scattered data onto it

   % we need to determine the x-y extent of the grid onto which the data
   % will be interpolated. If we just use

   % this method attempts to account for both very small and large domains
   xdiffs      =   abs(diff(x(:)));
   ydiffs      =   abs(diff(y(:)));
   xmindif     =   min(xdiffs(xdiffs>0.0));
   ymindif     =   min(ydiffs(ydiffs>0.0));
   xtol        =   floor(log10(xmindif))-1;
   ytol        =   floor(log10(ymindif))-1;
   xmin        =   roundn(min(x(:)),xtol);
   xmax        =   roundn(max(x(:)),xtol); % extending by xmindif can substantially increase the extent
   ymin        =   roundn(min(y(:)),ytol);
   ymax        =   roundn(max(y(:)),ytol);
   %     ymin        =   roundn(min(y(:)),ytol)-ymindif;
   %     ymax        =   roundn(max(y(:)),ytol)+ymindif;
   %     xmin        =   roundn(min(x(:)),xtol)-xmindif;
   %     xmax        =   roundn(max(x(:)),xtol)+xmindif;
   xlims = [xmin xmax];
   ylims = [ymin ymax];

   % i could also push the extent outward by 1/10th of its value ...
   %     xoffset = (max(x(:))-min(x(:)))/10; % but this will fail for global datasets
   %     yoffset = (max(y(:))-min(y(:)))/10;

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

   % update April 10,2020 - convert from geographic/map coordinates to
   % intrinsic to perform the interpolation
   % I could use F = scatteredInterpolant(x,y,z) then query F(xq,yq).
   % Might be even better to convert lat,lon to real world distances.

   % commenting this out - I don't think this is right. This would reduce the
   % precision of the x,y coordinates, e.g. if you have a scattered coordinate that is
   % within a grid cell, that scattered coordinate gets converted to an
   % intrinsic grid cell coordinate, unless worldToIntrinsic has sub-grid cell
   % precision. Keeping it for refrence.

   %     if tf % note order of output xq,yq vs input xq,yq
   %          [xq,yq] =   geographicToIntrinsic(R,yq,xq);
   %          [x,y]   =   geographicToIntrinsic(R,y,x);
   %     else
   %         [xq,yq] =   worldToIntrinsic(R,xq,yq);
   %         [x,y]   =   worldToIntrinsic(R,y,x);
   %     end

   % apply griddata and reshape to a grid
   Z = griddata(x,y,z,xq,yq,method);

   assert(~isempty(Z), ['The interpolated surface, Z, is empty. You may not ' ...
      'have provided sufficient x,y values to fit a surface.']);
   Z = reshape(Z,size(X,1),size(X,2));

end

end


% this is the logic behind the argin checks

% if rasterize(x,y,z,rasterSize)
% numarg = 1
% method = 'natural'
% ischar test fails
% numarg = 1
% need to validate rasterSize

% if rasterize(x,y,z,rasterSize,'method')
% numarg = 2
% ischar test passes
% method = 'method'
% numarg = 1
% need to validate rasterSize

% if rasterize(x,y,z,cellextentX,cellextentY)
% numarg = 2
% method = 'natural'
% ischar test fails
% numarg = 2
% need to validate cellextentX and cellextentY

% if rasterize(x,y,z,cellextentX,cellextentY,'method')
% numarg = 3
% ischar test passes
% method = 'method'
% numarg = 2
% need to validate cellextentX and cellextentY

% so the outcome is either numarg == 1 and we need to validate rasterSize
% or numarg == 2 and we need to validate cellextentX and cellextentY

% might change to rasterregularize or similar and explain that this
% function is explicitly for regularizing gridded data. Occasionally,
% gridded data is on a non-uniform grid, but many mapping functions require
% a uniform grid. Interpolating from non-uniform grid to uniform grid is
% fundamentally a problem of interpolation. For geophysical data, a problem
% arises when there are zero values. For exmaple, you might have a snow
% depth dataset, with many zeros surrounded by positive values. Depending
% on the interpolation method, those zeros will acquire non-zero values.
% Replacing them with zero is tricky due to scale differences. For precise
% results, one must know that support of the data. For gridded data, the
% support is the grid spacing. For point measurements, one must estimate
% the support. The support can then be used to define the areas that should
% acquire the value "zero" in the output interpolated surface. Dealing with
% these issues is beyond the scope of this function.


%% notes on determining the spatial extent

% this function builds a regular grid on which the scattered data is
% interpolated, so it needs to know the spatial extent in the x,y direction
% for that grid, and it needs to do that for geographic and planar
% coordinates. Sometimes, x,y data provided by netcdf or other datasets
% have false precision / rounding errors. So the user might pass in x,y
% coordinates like 60.00001 61.00001 etc. For this reason, simply rounding
% to some default value could be problematic.

% 1. The first thing I tried was extending the limits to even degrees in
% lat and lon i.e. the first approach I used in rasterref
%     ylims           =   [floor(min(y(:))) ceil(max(y(:)))];
%     xlims           =   [floor(min(x(:))) ceil(max(x(:)))];
% but for very small spatial extent it does not work e.g. limits of 67.02
% to 67.08 would become 67 to 68.

% 2. Then I tried to determine a rounding tolerance based on the x/y extent
%     xextent     =   max(x(:)) - min(x(:));
%     yextent     =   max(y(:)) - min(y(:));
%     if xextent < 1; xtol = floor(log10(xextent))-1; else; xtol = 0; end
%     if yextent < 1; ytol = floor(log10(yextent))-1; else; ytol = 0; end
%     xlims       =   [roundn(min(x(:)),xtol) roundn(max(x(:)),xtol)];
%     ylims       =   [roundn(min(y(:)),ytol) roundn(max(y(:)),ytol)];

%
%     xdiffs = diff(x);
%     xmindif = min(xdiffs)
%     xmaxdif = max(xdiffs)
%     xmeandif = mean(xdiffs)
%
% This did not work. Conceptually, at one extreme i could have a huge
% domain with some points separated by a huge distance and some points very
% close, in which case min/max/mean could give weird output

% 3. Then I used the minimum difference between points in each direction
%   xextent     =   max(x(:)) - min(x(:));
%   yextent     =   max(y(:)) - min(y(:));
%   xmindif     =   abs(min(diff(x(:))));
%   ymindif     =   abs(min(diff(y(:))));
%   if xextent < 1; xtol = floor(log10(xmindif))-1; else; xtol = 0; end
%   if yextent < 1; ytol = floor(log10(ymindif))-1; else; ytol = 0; end
%   xlims       =   [roundn(min(x(:)),xtol) roundn(max(x(:)),xtol)];
%   ylims       =   [roundn(min(y(:)),ytol) roundn(max(y(:)),ytol)];

% THis seems to work

% NOTE: this simple approach might also work for the majority of cases
%     if tf
%         tol     =   -7; % approximately 1 cm in units of degrees
%     else
%         % tol     =   -2; % nearest cm
%         tol     =   0; % nearest m (changed for MAR)
%     end
%     xlims       =   [roundn(min(x(:)),tol) roundn(max(x(:)),tol)];
%     ylims       =   [roundn(min(y(:)),tol) roundn(max(y(:)),tol)];

% Finally, one way to get around it completely is to force the user to pass
% in a query grid, or allow it, and if the output is weird, they can get
% around it by passing in the grid, add notes to documentation that the
% function tries to figure it out, but for very sparse or very small
% domains the output could be weird

% after I thought it was fixed I realized there can be a situation where
% the domain is large but the spacing is very small and so setting tol = 0
% can cutout some of the data if the limits are rounded inward, so method 3
% above which I had settled on as final did not work. I think it might be
% best to use the small-domain method for all domains, then I could add a
% check where for large domains I round to the nearest whole-integer ...

%     xextent     =   max(x(:)) - min(x(:));
%     yextent     =   max(y(:)) - min(y(:));
%     if xextent < 1; xtol = floor(log10(xmindif))-1; else; xtol = 0; end
%     if yextent < 1; ytol = floor(log10(ymindif))-1; else; ytol = 0; end
%     xlims       =   [roundn(min(x(:)),xtol) roundn(max(x(:)),xtol)];
%     ylims       =   [roundn(min(y(:)),ytol) roundn(max(y(:)),ytol)];
