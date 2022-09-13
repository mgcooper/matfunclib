function [Z,R] = rasterfromscatter(x,y,z,varargin)
%RASTERFROMSCATTER constructs a spatially referenced raster Z and
%map/geographic raster reference object R from scattered data z refrenced
%to geo/map coordinates x,y

% note; v2 adds simplified attribute validation

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

% must be 4-6 inputs
narginchk(4,6)

% confirm mapping toolbox is installed
assert(license('test','map_toolbox')==1, ...
                'rasterfromscatter requires Matlab''s Mapping Toolbox.')

% check if lat/lon or planar, initialize r, and validate attributes
tf              =   islatlon(y,x);
if tf; R        =   georefcells(); else, R = maprefcells();
[x,y,z]         =   validateXYZ(x,y,z);
% this check borrows from griddata. 'method' is always the last argument. 
numarg          =   nargin-3; % three required arguments
method          =   'natural';
checkarg        =   varargin{numarg};
if ischar(checkarg) || (isstring(checkarg) && isscalar(checkarg))
    method      =   checkarg;
    method      =   lower(method);
    numarg      =   numarg-1;
end % else, varargin{numarg} is not method
switch numarg
    case 1 % validate rasterSize 
        inrasterSize    =   true;
        rasterSize      =   varargin{1};
        R.RasterSize    =   validateRasterSize(rasterSize);
    case 2 % validate cellextentX and cellextentY
        inrasterSize    =   false;
        cellextentX     =   varargin{1};
        cellextentY     =   varargin{2};
        if tf
        [R.CellExtentInWorldX, R.CellExtentInWorldY] = ...
            validateCellExtent(cellextentX,cellextentY,tf);
        else
            [R.CellExtentInLongitude, R.CellExtentInLatitude] = ...
            validateCellExtent(cellextentX,cellextentY,tf);
        end
end

%% now that we have 1) rasterSize or 2) cellextent, build the R object

% NOTE: if i want to pursue the simplified validation I will need to pick
% up here and figure out how to deal with the initialized R object

% Extend limits to even degrees in lat and lon
ylims           =   [floor(min(y(:))) ceil(max(y(:)))];
xlims           =   [floor(min(x(:))) ceil(max(x(:)))];

% i think i can divide xlim(2)-xlim(1) by rastersize(1) to estimate the
% number of cells and then get cell extent from that and then adjust for
% half cell size

% alternaitively I can require cell size and disallow rasterrise

((lonlim(1)+halfcell):cellsize:(lonlim(2)-halfcell)),...
    ((latlim(1)+halfcell):cellsize:(latlim(2)-halfcell))');

% determine if the data is planar or geographic and build the R object
if tf
    if inrasterSize
        R       =   georefcells(ylims,xlims,rasterSize, ...
                                'ColumnsStartFrom', 'north', ...
                                'RowsStartFrom','west');
    else
        R       =   georefcells(ylims,xlims,cellextentY,cellextentX, ...
                                'ColumnsStartFrom', 'north', ...
                                'RowsStartFrom','west');
    end
else % note: x,y positioning is reversed for maprefcells
    if inrasterSize
        R       =   maprefcells(xlims,ylims,rasterSize, ...
                                'ColumnsStartFrom', 'north', ...
                                'RowsStartFrom','west');
    else
        R       =   maprefcells(xlims,ylims,cellextentX,cellextentY, ...
                                'ColumnsStartFrom', 'north', ...
                                'RowsStartFrom','west');
    end
end

% build a grid and reshape to arrays for interpolation
[X,Y]       =   R2grid(R);
xq          =   reshape(X,size(X,1)*size(X,2),1);
yq          =   reshape(Y,size(Y,1)*size(Y,2),1);

% apply griddata and reshape to a grid
Z           =   griddata(x,y,z,xq,yq,method);
Z           =   reshape(Z,size(X,1),size(X,2));
        
end

    function [x,y,z] = validate
% confirm x, y, and z are 2d numeric arrays of equal size
validateattributes(x,{'numeric'},{'real','2d','nonempty','size',size(y)}, ...
                            'rasterfromscatter', 'x', 1)
validateattributes(y,{'numeric'},{'real','2d','nonempty','size',size(x)}, ...
                            'rasterfromscatter', 'y', 2)
validateattributes(z,{'numeric'},{'real','2d','nonempty','size',size(x)}, ...
                            'rasterfromscatter', 'z', 3)
                        
    function rasterSize = validateRasterSize(rasterSize,tf)
        if tf % geo coordinates
            validateattributes(rasterSize, {'numeric'}, ...
                                {'real','2d','finite','positive'}, ...
                                'rasterfromscatter','rasterSize', 4)
        else % map coordinates (for this, I think identical
            validateattributes(rasterSize, {'numeric'}, ...
                                {'real','2d','finite','positive'}, ...
                                'rasterfromscatter','rasterSize', 4)
        end
    end
        
    function [cellextentX,cellextentY] = validateCellExtent(cellextentX,cellextentY,tf)
        if tf % geo coordinates
                validateattributes(cellextentX, {'numeric'}, ...
                        {'real','scalar','finite','positive','<=',360}, ...
                        'rasterfromscatter','cellextentX', 4)
                validateattributes(cellextentY, {'numeric'}, ...
                        {'real','scalar','finite','positive','<=',180}, ...
                        'rasterfromscatter','cellextentY', 5)
        else % map coordinates
                validateattributes(cellextentX, {'numeric'}, ...
                        {'real','scalar','finite','positive'}, ...
                        'rasterfromscatter','cellextentX', 4)
                validateattributes(cellextentY, {'numeric'}, ...
                        {'real','scalar','finite','positive'}, ...
                        'rasterfromscatter','cellextentY', 5)
        end
     end
        
 
function latlim = validateLatitudeLimits(latlim)
    validateattributes(latlim, {'double'}, ...
        {'real','finite','size',[1 2],'>=',-90,'<=',90}, '', 'latlim')

    map.internal.assert(latlim(1) < latlim(2), ...
        'map:spatialref:expectedAscendingLimits','latlim')
end


function lonlim = validateLongitudeLimits(lonlim)
    validateattributes(lonlim, ...
        {'double'}, {'real','finite','size',[1 2]}, '', 'lonlim')

    map.internal.assert(lonlim(1) < lonlim(2), ...
        'map:spatialref:expectedAscendingLimits','lonlim')
end

% this is the logic behind the argin checks

% if rasterfromscatter(x,y,z,rasterSize)
% numarg = 1
% method = 'natural'
% ischar test fails
% numarg = 1
% need to validate rasterSize

% if rasterfromscatter(x,y,z,rasterSize,'method')
% numarg = 2
% ischar test passes
% method = 'method'
% numarg = 1
% need to validate rasterSize

% if rasterfromscatter(x,y,z,cellextentX,cellextentY)
% numarg = 2
% method = 'natural'
% ischar test fails
% numarg = 2
% need to validate cellextentX and cellextentY

% if rasterfromscatter(x,y,z,cellextentX,cellextentY,'method')
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