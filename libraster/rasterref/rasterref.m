function [R,X,Y] = rasterref(X,Y,varargin)

% NOTE: it doesn't work if X,Y are irregular, so you can't do something
% like:
% [lt,ln] = projinv(proj,x,y);
% [xnew,ynew] = projfwd(projnew,lt,ln);
% Rnew = rasterref(xnew,ynew)

% Based on the results of my comparison, rasterref is correct. The issue is
% with Matlab's interpretation of 'surface' vs 'texture' and 'cells' vs
% 'postings'. But also check the latest results with
% test_cells_vs_postings_v2. This suggests if I use 'postings' I need to
% adjust the limits at the poles.

%RASTERREF R = rasterref(X,Y,cellInterpretation) constructs spatial
%referencing object R from 2-d grids X,Y that define the E-W and N-S
%coordinates of each grid cell. User provides cellInterpretation as
%'Postings' if the X,Y coordinate pairs represent the centroids of each
%grid cell, typical of climate model data, or 'Cells' if the X,Y coordinate
%pairs represent the edges of the grid cells, typical of image-based
%satellite data. X and Y can be geographic or projected (planar)
%coordinates.

%   This function exists because many geospatial datasets are provided with
%   vectors or grids of latitude/longitude and/or planar coordinate values
%   that represent the centroid or cell edges of each grid-cell, but many
%   Matlab Mapping Toolbox functions require the spatial referencing object
%   R as input. This function creates the object R from the
%   latitude/longitude or x/y coordinate vectors or grids.

%   Author: Matt Cooper, guycooper@ucla.edu, June 2019 Citation: Matthew
%   Cooper (2019). matrasterlib: a software library for processing
%   satellite and climate model data in Matlab?
%   (https://www.github.com/mguycooper/matrasterlib), GitHub. Retrieved MMM
%   DD, YYYY.

%   Syntax

%   R = rasterref(X,Y,cellInterpretation)
%   R = rasterref(LON,LAT,cellInterpretation)

%   Description

%   R = rasterref(X,Y) constructs spatial referencing object R from 1-d
%   vectors or 2-d grids of E-W (longitude) and N-S (latitude) coordinates
%   X,Y. If X and Y are 2-d numeric matrices (grids) they must be equal
%   size. If they are not oriented E-W and N-S such that the linear
%   (row,col) index (1,1) is the northwest corner grid cell, they are
%   re-oriented E-W and N-S. The coordinate pair X(1,1),Y(1,1) is
%   intepreted as the centroid of the northwest corner grid cell for
%   cellInterpretation 'Postings' and as the edge of the northwest corner
%   grid cell for cellInterpretation 'Cells'. X defines the E-W
%   (longitude or projected coordinate) value of every grid cell centroid
%   and Y defines the N-S (latitude or projected coordinate) value of every
%   grid cell centroid. The 'Postings' interpretation is consistent
%   with an interpretation of raster grid cell values representing the
%   centroid of each grid cell, for example as would be provided in a
%   netcdf or h5 scientific raster dataset or if using [X,Y]=meshgrid(x,y)
%   where x and y are vectors that span min(x):x_cell_extent:max(x) and
%   min(y):y_cell_extent:max(y) where x and y define the coordinates of
%   data values (not cell edges). X and Y can be geographic or planar
%   coordinate systems.

%   R = rasterref(X,Y,'Cells') applies the 'Cells' intepretation instead of
%   'Postings', which is consistent with an interpretation that X,Y define
%   the E-W and N-S coordinates of the grid cell edges, for example as
%   is commonly the case for image-based data (e.g. MODIS satellite
%   imagery).

%   See also rasterref, georefcells, maprefcells, meshgrid
% 
%   Examples - forthcoming

% Input parsing
%-------------------------------------------------------------------------------

% confirm mapping toolbox is installed
assert(license('test','map_toolbox')==1, ...
   'rasterref requires Matlab''s Mapping Toolbox.')

p              = inputParser;
p.FunctionName = 'rasterref';
addRequired( p, 'X',                               @(x)isnumeric(x));
addRequired( p, 'Y',                               @(x)isnumeric(x));
addParameter(p, 'cellInterpretation',  'cells',    @(x)ischar(x));
addParameter(p, 'projection',          'unknown',  @(x)isa(x,'projcrs')||ischar(x));

parse(p,X,Y,varargin{:});

celltype   = p.Results.cellInterpretation;
projection = p.Results.projection;

% % confirm X and Y are 2d numeric grids of equal size
% validateattributes(X, {'numeric'}, {'2d','size',size(Y)}, 'rasterref', 'X', 1)
% validateattributes(Y, {'numeric'}, {'2d','size',size(X)}, 'rasterref', 'Y', 2)
%-------------------------------------------------------------------------------

% convert grid vectors to mesh, ensure the X,Y arrays are oriented W-E and N-S,
% get an estimate of the grid resolution, and determine if the data is
% geographic or planar  
[X,Y,cellsizeX,cellsizeY,tf,tol] = prepareMapGrid(X,Y);

% extend the lat/lon limits by 1/2 cell in both directions
halfX = cellsizeX/2;
halfY = cellsizeY/2;

% this is the basic approach, does not deal with small errors
% assert(all(xres(1) == xres), ...
%             'Input argument 1, X, must have uniform grid spacing');
% assert(all(yres(1) == yres), ...
%             'Input argument 2, Y, must have uniform grid spacing');

% call the appropriate function depending on whether R is planar or geographic 
if tf
   R = rasterrefgeo(X,Y,halfX,halfY,celltype,tol);
else
   R = rasterrefmap(X,Y,halfX,halfY,celltype,tol);
end

% if provided, add the projection
if isa(projection,'projcrs')
   R.ProjectedCRS = projection;
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% apply the appropriate function
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function R = rasterrefmap(X,Y,halfX,halfY,cellInterpretation,tol)

% NOTE: i convert to double because I have encountered X,Y grids
% provided by netcdf files that are stored as type uint, but it
% might be better to convert X and Y to single or double and
% confirm what is most compatible with the functions called
xmin        =  roundn(min(X(:)),tol); % changed from floor(min(X(:)))
xmax        =  roundn(max(X(:)),tol); % changed from ceil(max(X(:)))
ymin        =  roundn(min(Y(:)),tol);
ymax        =  roundn(max(Y(:)),tol);
xlims       =  double([xmin-halfX xmax+halfX]);
ylims       =  double([ymin-halfY ymax+halfY]);
rasterSize  =  size(X);

if strcmp(cellInterpretation,'cells')
   R = maprefcells(xlims,ylims,rasterSize, ...
      'ColumnsStartFrom','north', ...
      'RowsStartFrom', 'west');
elseif strcmp(cellInterpretation,'postings')
   R = maprefpostings(xlims,ylims,rasterSize, ...
      'ColumnsStartFrom','north', ...
      'RowsStartFrom', 'west');
end


function R = rasterrefgeo(X,Y,halfX,halfY,cellInterpretation,tol)

% 'columnstartfrom','south' is default and corresponds to S-N
% oriented grid as often provided by netcdf and h5 but I require
% this function accept N-S oriented grids i.e. index (1,1) is NW
% corner, consequently set 'columnstartfrom','north'
xmin        =  roundn(min(X(:)),tol); % changed from floor(min(X(:)))
xmax        =  roundn(max(X(:)),tol); % changed from ceil(max(X(:)))
ymin        =  roundn(min(Y(:)),tol);
ymax        =  roundn(max(Y(:)),tol);
xlims       =  double([xmin-halfX xmax+halfX]);
ylims       =  double([ymin-halfY ymax+halfY]);
rasterSize  =  size(X);

if strcmp(cellInterpretation,'cells')

   R = georefcells(ylims,xlims,rasterSize, ...
      'ColumnsStartFrom','north', ...
      'RowsStartFrom', 'west');

   % 'georefcells' gets the limits/size/spacing/extent correct in
   % the structure, but I need to confirm its behavior with
   % functions such as ll2val etc.

   % Rcell1  =   georefcells(ylims,xlims,rasterSize, ...
   %                'ColumnsStartFrom','north', ...
   %                'RowsStartFrom', 'west');
   % Rcell2  =   georefcells(ylims,xlims,2*halfY,2*halfX, ...
   %                'ColumnsStartFrom','north', ...
   %                'RowsStartFrom', 'west');

elseif strcmp(cellInterpretation,'postings')

   R = georefpostings(ylims,xlims,rasterSize, ...
      'ColumnsStartFrom','north', ...
      'RowsStartFrom', 'west');

   % 'georefcells' gets the limits/size/spacing/extent correct as
   % saved in the structure, but I need to confirm its behavior
   % with functions such as ll2val etc.

   % Rpost1  =   georefpostings(ylims,xlims,rasterSize, ...
   %                'ColumnsStartFrom','north', ...
   %                'RowsStartFrom', 'west');
   % Rpost2  =   georefpostings(ylims,xlims,2*halfY,2*halfX, ...
   %                'ColumnsStartFrom','north', ...
   %                'RowsStartFrom', 'west');

   % if you manually update it, matlab adjusts the limits incorrectly

   % Rpost1.SampleSpacingInLatitude = 2*halfY;
   % Rpost1.SampleSpacingInLongitude = 2*halfX;

   % Matlab is interpreting these correctly - if the data are
   % 'postings' then the halfX/halfY adjustment is incorrect. The
   % problem is that my initial tests suggests other functions
   % such as ll2val are incorrect if type 'cell' is specified

   % note: R.CellExtentInLongitude (for type 'cell') and
   % R.SampleSpacingInLatitude should equal:
   % (R.LongitudeLimits(2)-R.LongitudeLimits(1))/R.RasterSize(2)
   % but unless pre-processing is performed on standard netcdf or
   % h5 grid to adjust for edge vs centroid, a 'cells'
   % interpretation gets it wrong

end

% Notes

% for reference, the N-S E-W could be handled here but the built-in error
% message handling is less informative than the custom message option with
% using assert

% % confirm X and Y are 2d numeric grids of equal size oriented N-S and E-W
% validateattributes(X(1,:),  {'numeric'}, ...
%                             {'2d','size',size(Y(1,:)),'increasing'}, ...
%                             'R2grid', 'X', 1)
% validateattributes(Y(1,:),  {'numeric'}, ...
%                             {'2d','size',size(X(1,:)),'decreasing'}, ...
%                             'R2grid', 'Y', 2)

% Dealing with unique lat-lon values vs coordinate pairs
% if a vector of non-unique lat/lon values is passed in, e.g. a list of
% coordinate pairs, meshgrid will build a redundant matrix e.g.:

% X1 = [-49.375 -49.375 -48.75 -48.75];
% Y1 = [67.5 67 67.5 67];

% if isvector(X1) && isvector(Y1)
%     [X1,Y1] = meshgrid(X1,Y1)
% end

% rasterref is designed to build a grid of unique lat/lon pairs, so I use
% the unique function to deal with this but the overall behavior of this
% approach is unknown

% X2 = unique(X);
% Y2 = unique(Y);

% if isvector(X2) && isvector(Y2)
%     [X2,Y2] = meshgrid(X2,Y2)
% end



% the original method enforced input
% assert(X(1,1)==min(X(:)) & X(1,2)>X(1,1), ...
%                 'Input argument 1, X, must be oriented E-W');
% assert(Y(1,1)==max(Y(:)) & Y(1,1)>Y(2,1), ...
%                 'Input argument 2, Y, must be oriented N-S');
