function [Z,R,X,Y] = rasterfromscatter(x,y,z,varargin)

% Dont use this, it is a backup for reference.

% TLDR: this should be identical to the rasterfromscatter I used for the
% RCM extract scripts but there is some uncertainty

% after changing to rasterize I saved as rasterfromscatter_v3 and moved to
% archive, but I saved too late and some changes were made i.e. I don't
% have a 100% confirmed version of rasterfromscatter that was used for all
% the extract scripts. The main difference was the way I hanlde the raster
% limits. Below, I am 99% sure I was able to go backward and reset it to
% the original rasterfromscatter behaviro where I just used the ceil/floor
% limits.

%RASTERFROMSCATTER constructs a spatially referenced raster Z and
%map/geographic raster reference object R from scattered data z referenced
%to geo/map coordinates x,y
%[Z,R] = RASTERFROMSCATTER(x,y,z,rasterSize)
%[Z,R] = RASTERFROMSCATTER(x,y,z,cellextentX,cellextentY)
%[Z,R] = RASTERFROMSCATTER(___,method). Options: 'linear', 'nearest', 'natural',
%'cubic', or 'v4'. The default method is 'natural'.

%   This function is similar to the in-built Matlab function geoloc2grid.m
%   (Copyright 2016 The MathWorks, Inc.) but adds a bit more functionality.
%   The function uses griddata instead of TriScatteredInterpolant, and
%   instead of returning the 1-d refvec object it returns the R structure.

%   USAGE

%   [Z,R] = RASTERFROMSCATTER(x,y,z,rasterSize) constructs
%   spatially referenced raster Z and map/geographic raster reference
%   object R from scattered data z with geo/map coordinates x,y with the
%   numbers of rows and columns specified by rasterSize

%   [Z,R] = RASTERFROMSCATTER(x,y,z,cellextentX,cellextentY) allows the
%   geographic cell extents to be set precisely. The geographic limits will
%   be adjusted slightly, if necessary, to ensure an integer number of
%   cells in each dimenstion.

%   [Z,R] = RASTERFROMSCATTER(___,method)  specifies the interpolation
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

tstart = tic;

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

% this check borrows from griddata. 'method' is always the last argument.
numarg = nargin-3; % three required arguments
method = 'natural';
checkarg = varargin{numarg};
if ischar(checkarg) || (isstring(checkarg) && isscalar(checkarg))
   method = checkarg;
   method = lower(method);
   numarg = numarg-1;
end % else, varargin{numarg} is not method

switch numarg
   case 1 % validate rasterSize
      inrasterSize = true;
      rasterSize = varargin{1};
      if tf % geo coordinates
         validateattributes(rasterSize, {'numeric'}, ...
            {'real','2d','finite','positive'}, ...
            mfilename,'rasterSize', 4)
      else % map coordinates (for this, I think identical
         validateattributes(rasterSize, {'numeric'}, ...
            {'real','2d','finite','positive'}, ...
            mfilename,'rasterSize', 4)
      end
   case 2 % validate cellextentX and cellextentY
      inrasterSize = false;
      cellextentX = varargin{1};
      cellextentY = varargin{2};
      if tf % geo coordinates
         validateattributes(cellextentX, {'numeric'}, ...
            {'real','scalar','finite','positive','<=',360}, ...
            mfilename,'cellextentX', 4)
         validateattributes(cellextentY, {'numeric'}, ...
            {'real','scalar','finite','positive','<=',180}, ...
            mfilename,'cellextentY', 5)
      else % map coordinates
         validateattributes(cellextentX, {'numeric'}, ...
            {'real','scalar','finite','positive'}, ...
            mfilename,'cellextentX', 4)
         validateattributes(cellextentY, {'numeric'}, ...
            {'real','scalar','finite','positive'}, ...
            mfilename,'cellextentY', 5)
      end
end

%% now that we have 1) rasterSize or 2) cellextent, build the R object

% check for regular data that isn't in full grid format
tfreg = isxyregular(x,y);
if tfreg == 1 % then just grid it
   xu = unique(x(:),'sorted');
   yu = unique(y(:),'sorted');
   [X,Y] = meshgrid(xu,flipud(yu));
   Z = reshape(z,size(X,1),size(Y,2));
   R = rasterref(x,y,'cell');
else % build a query grid and interpolate the scattered data

   % Extend limits to even degrees in lat and lon
   ylims = [floor(min(y(:))) ceil(max(y(:)))];
   xlims = [floor(min(x(:))) ceil(max(x(:)))];

   % % this method attempts to account for both very small and large domains
   % xextent = max(x(:)) - min(x(:));
   % yextent = max(y(:)) - min(y(:));
   % xmindif = abs(min(diff(x(:))));
   % ymindif = abs(min(diff(y(:))));
   % if xextent < 1; xtol = floor(log10(xmindif))-1; else; xtol = 0; end
   % if yextent < 1; ytol = floor(log10(ymindif))-1; else; ytol = 0; end
   % xlims = [roundn(min(x(:)),xtol) roundn(max(x(:)),xtol)];
   % ylims = [roundn(min(y(:)),ytol) roundn(max(y(:)),ytol)];

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

   % tbuildR = toc(tstart) - tchecks

   % build a grid and reshape to arrays for interpolation
   % NOTE: since I use the inbuilt
   [X,Y] = R2grid(R);
   % [X,Y] = R2grat(R);
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

   % if tf % note order of output xq,yq vs input xq,yq
   %    [xq,yq] = geographicToIntrinsic(R,yq,xq);
   %    [x,y] = geographicToIntrinsic(R,y,x);
   % else
   %    [xq,yq] = worldToIntrinsic(R,xq,yq);
   %    [x,y] = worldToIntrinsic(R,y,x);
   % end

   % tbuildXY = toc(tstart) - tbuildR - tchecks

   % apply griddata and reshape to a grid
   Z = griddata(x,y,z,xq,yq,method);

   % tgriddata = toc(tstart) - tbuildXY - tbuildR - tchecks

   assert(~isempty(Z), ['The interpolated surface, Z, is empty. You may not ' ...
      'have provided sufficient x,y values to fit a surface.']);
   Z = reshape(Z,size(X,1),size(X,2));

   % ttotal = toc(tstart)
end

end
