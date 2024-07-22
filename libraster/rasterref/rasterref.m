function [R, X, Y] = rasterref(X, Y, varargin)
   %RASTERREF construct spatial referencing object R from full grids X,Y
   %
   % R = rasterref(X,Y,cellInterpretation) constructs spatial
   % referencing object R from 2-d grids X,Y that define the E-W and N-S
   % coordinates of each grid cell. User provides cellInterpretation as
   % 'Postings' if the X,Y coordinate pairs represent the centroids of each
   % grid cell, typical of climate model data, or 'Cells' if the X,Y coordinate
   % pairs represent the edges of the grid cells, typical of image-based
   % satellite data. X and Y can be geographic or projected (planar)
   % coordinates.
   %
   %   This function exists because many geospatial datasets are provided with
   %   vectors or grids of latitude/longitude and/or planar coordinate values
   %   that represent the centroid or cell edges of each grid-cell, but many
   %   Matlab Mapping Toolbox functions require the spatial referencing object
   %   R as input. This function creates the object R from the
   %   latitude/longitude or x/y coordinate vectors or grids.
   %
   %   Author: Matt Cooper, guycooper@ucla.edu, June 2019 Citation: Matthew
   %   Cooper (2019). matrasterlib: a software library for processing
   %   satellite and climate model data in Matlab
   %   (https://www.github.com/mguycooper/matrasterlib), GitHub. Retrieved MMM
   %   DD, YYYY.
   %
   %   Syntax
   %
   %   R = rasterref(X,Y,cellInterpretation)
   %   R = rasterref(LON,LAT,cellInterpretation)
   %
   %   Description
   %
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
   %
   %   R = rasterref(X,Y,'Cells') applies the 'Cells' intepretation instead of
   %   'Postings', which is consistent with an interpretation that X,Y define
   %   the E-W and N-S coordinates of the grid cell edges, for example as
   %   is commonly the case for image-based data (e.g. MODIS satellite
   %   imagery).
   %
   %  NOTE: this function does not work with irregular X,Y grids, so you can't
   %  do something like:
   %  [lt,ln] = projinv(proj,x,y);
   %  [xnew,ynew] = projfwd(projnew,lt,ln);
   %  Rnew = rasterref(xnew,ynew)
   %
   %  See also rasterref, georefcells, maprefcells, meshgrid

   % Programming note:
   % Based on the results of my comparison, rasterref is correct. The issue is
   % with Matlab's interpretation of 'surface' vs 'texture' and 'cells' vs
   % 'postings'. But also check the latest results with
   % test_cells_vs_postings_v2. This suggests if I use 'postings' I need to
   % adjust the limits at the poles.

   % April 2024 - IMPORTANT NOTE: Because I added prepareMapGrid, this function
   % may produce different results than rasterize or other functions, because
   % prepareMapGrid confirms that the actual X, Y points are ... ok figured it
   % out, this is wrong, b/c if there are missing pixels, they are not
   % identified or accounted for, the X, Y returned by prepareMapGrid won't have
   % regular spacing, there may be missing rows or columns so
   % unique(diff(Y(:, 1)) may return 5000, 10000, 15000, where all but one or
   % two values are 5000, and one or two are 10000 or 15000. So until that is
   % fixed, error. HOWEVER, also pay attention to rasterize since it creates an
   % interpolation grid from R using R2grid, so if there are missing pixels,
   % this means they are interpolated. But Note the check for that using
   % gridmember at the end of rasterize, so it should be ok.

   % Actually rasterize depends on rasterref ... and rasterref remains
   % dependable if we know we're working with a full grid, so allow it.
   % ... moved warning from here to isfullgrid check

   %% Prepare inputs

   % Confirm mapping toolbox is installed.
   assert(license('test', 'map_toolbox') == 1, ...
      [mfilename ' requires Matlab''s Mapping Toolbox.'])

   % Parse inputs.
   [X, Y, cellType, mapProj, UseGeoCoords] = parseinputs( ...
      X, Y, mfilename, varargin{:});

   if ~isfullgrid(X(:), Y(:))
      wid = ['custom:' mfilename ':NonFullGridInput'];
      warning(wid,  ...
         ['Input X and Y coordinates do not represent fullgrids. ' ...
         'Returning a raster reference object for their fullgrid ' ...
         'representation, including cells which are missing from ' ...
         'X and Y. To register the data associated with the input ' ...
         'X and Y coordinates to the raster reference object returned ' ...
         'by this function, try RASTERIZE with "extrap=true"'], mfilename)
   end

   % Convert grid vectors to mesh, ensure the X,Y arrays are oriented W-E and
   % N-S, get an estimate of the grid resolution, and determine if the data is
   % geographic or planar.
   [X, Y, cellsizeX, cellsizeY] = prepareMapGrid(X, Y, 'fullgrids');

   % extend the lat/lon limits by 1/2 cell in both directions
   halfX = cellsizeX/2;
   halfY = cellsizeY/2;

   % this is the basic approach, does not deal with small errors
   % assert(all(xres(1) == xres), ...
   %    'Input argument 1, X, must have uniform grid spacing');
   % assert(all(yres(1) == yres), ...
   %    'Input argument 2, Y, must have uniform grid spacing');

   % call the appropriate function depending on if R is planar or geographic
   if UseGeoCoords
      R = rasterrefgeo(X, Y, halfX, halfY, cellType);
   else
      R = rasterrefmap(X, Y, halfX, halfY, cellType);
   end

   % if provided, add the projection
   if isa(mapProj, 'projcrs')
      R.ProjectedCRS = mapProj;
   end

   % Note: to see the intrinsic coordinates:
   % [cq, rq] = worldToIntrinsic(R, xq, yq);
end

%% Apply the appropriate function
function R = rasterrefmap(X, Y, halfX, halfY, cellInterpretation, tol)

   % Note: rounding wont work in general esp for large and/or global grids e.g.
   % if the min coordinate is near the edge round to 0 will force the x/ymin
   % values to the edge and then adjusting by half cell will put the edge
   % outside the limits.
   if nargin < 6
      tol = 0;
   end

   % convert X,Y grids stored as type uint to double.
   xmin = round(min(X(:)), tol); % changed from floor(min(X(:)))
   xmax = round(max(X(:)), tol); % changed from ceil(max(X(:)))
   ymin = round(min(Y(:)), tol);
   ymax = round(max(Y(:)), tol);
   xlims = double([xmin-halfX xmax+halfX]);
   ylims = double([ymin-halfY ymax+halfY]);
   rasterSize = size(X);

   if strcmp(cellInterpretation,'cells')
      R = maprefcells(xlims, ylims, rasterSize, ...
         'ColumnsStartFrom', 'north', ...
         'RowsStartFrom', 'west');
   elseif strcmp(cellInterpretation, 'postings')
      R = maprefpostings(xlims, ylims, rasterSize, ...
         'ColumnsStartFrom', 'north', ...
         'RowsStartFrom', 'west');
   end
end

function R = rasterrefgeo(X, Y, halfX, halfY, cellInterpretation, tol)

   % May 2024, removed round(xmin, tol), see notes in map version.
   if nargin < 6
      tol = 0;
   end

   % 'columnstartfrom','south' is default and corresponds to S-N oriented grid
   % as often provided by netcdf and h5 but I require this function accept N-S
   % oriented grids i.e. index (1,1) is NW corner, consequently set
   % 'columnstartfrom','north'
   [xmin, xmax, ymin, ymax] = deal(...
      min(X(:)), max(X(:)), min(Y(:)), max(Y(:)));

   xlims = double([xmin-halfX xmax+halfX]);
   ylims = double([ymin-halfY ymax+halfY]);

   rasterSize = size(X);

   if strcmp(cellInterpretation,'cells')

      R = georefcells(ylims, xlims, rasterSize, ...
         'ColumnsStartFrom', 'north', ...
         'RowsStartFrom', 'west');

      % 'georefcells' gets the limits/size/spacing/extent correct in
      % the structure, but I need to confirm its behavior with
      % functions such as ll2val etc.

      % Rcell1 = georefcells(ylims,xlims,rasterSize, ...
      %  'ColumnsStartFrom','north', ...
      %  'RowsStartFrom', 'west');
      % Rcell2 = georefcells(ylims,xlims,2*halfY,2*halfX, ...
      %  'ColumnsStartFrom','north', ...
      %  'RowsStartFrom', 'west');

   elseif strcmp(cellInterpretation,'postings')

      R = georefpostings(ylims,xlims,rasterSize, ...
         'ColumnsStartFrom','north', ...
         'RowsStartFrom', 'west');

      % 'georefcells' gets the limits/size/spacing/extent correct as
      % saved in the structure, but I need to confirm its behavior
      % with functions such as ll2val etc.

      % Rpost1 = georefpostings(ylims,xlims,rasterSize, ...
      %    'ColumnsStartFrom','north', ...
      %    'RowsStartFrom', 'west');
      % Rpost2 = georefpostings(ylims,xlims,2*halfY,2*halfX, ...
      %    'ColumnsStartFrom','north', ...
      %    'RowsStartFrom', 'west');

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
end

function [X, Y, cellType, mapProj, UseGeoCoords] = ...
      parseinputs(X, Y, funcname, varargin)

   UseGeoCoordsDefault = false;

   parser = inputParser;
   parser.FunctionName = funcname;
   addRequired( parser, 'X', @validateGridCoordinates);
   addRequired( parser, 'Y', @validateGridCoordinates);
   addParameter(parser, 'cellInterpretation', 'cells', @mustBeTextScalar);
   addParameter(parser, 'projection', 'unknown', @validateProjection);
   addParameter(parser, 'UseGeoCoords', UseGeoCoordsDefault, @islogicalscalar);
   addParameter(parser, 'silent', false, @islogicalscalar);
   parse(parser, X, Y, varargin{:});

   % Confirm X and Y are numeric and of equal size.
   % validateattributes(X, ...
   %    {'numeric'}, {'size', size(Y)}, 'rasterref', 'X', 1)

   % Retreive parameter values.
   cellType = char(parser.Results.cellInterpretation);
   mapProj = parser.Results.projection;
   UseGeoCoords = parser.Results.UseGeoCoords;

   % Resolve UseGeoCoords user choice versus detected coordinate system.
   tfGeoCoords = isGeoGrid(Y, X);
   UsingDefault = ismember('UseGeoCoords', parser.UsingDefaults);

   UseGeoCoords = parseGeoCoordsChoice(tfGeoCoords, UseGeoCoords, ...
      UseGeoCoordsDefault, UsingDefault, silent=parser.Results.silent, ...
      caller=funcname);
end

function tf = validateProjection(x)
   assert(isa(x, 'projcrs') || ischar(x))
   tf = true;
end
function tf = validateGridCoordinates(x)
   validTypes = {'numeric'};
   attributes = {'real', 'finite', 'nonsparse'};
   validateattributes(x, validTypes, attributes);
   tf = true;
end

%% Notes

% for reference, the N-S E-W could be handled here but the built-in error
% message handling is less informative than the custom message option with
% using assert

% % confirm X and Y are 2d numeric grids of equal size oriented N-S and E-W
% validateattributes(X(1,:),  {'numeric'}, ...
%    {'2d','size',size(Y(1,:)),'increasing'}, ...
%    mfilename, 'X', 1)
% validateattributes(Y(1,:),  {'numeric'}, ...
%    {'2d','size',size(X(1,:)),'decreasing'}, ...
%    mfilename, 'Y', 2)
%
% % Dealing with unique lat-lon values vs coordinate pairs
% % if a vector of non-unique lat/lon values is passed in, e.g. a list of
% % coordinate pairs, meshgrid will build a redundant matrix e.g.:
%
% X1 = [-49.375 -49.375 -48.75 -48.75];
% Y1 = [67.5 67 67.5 67];
%
% if isvector(X1) && isvector(Y1)
%     [X2,Y2] = meshgrid(X1,Y1)
% end
%
% % rasterref is designed to build a grid of unique lat/lon pairs, so I use
% % the unique function to deal with this but the overall behavior of this
% % approach is unknown - UPDATE below - I think unique fixes it, it will reduce
% % the coordinate pairs to grid vectors
%
% uX1 = unique(X1);
% uY1 = unique(Y1);
%
% if isvector(uX1) && isvector(uY1)
%     [uX2,uY2] = meshgrid(uX1,uY1)
% end
%
% numel(uX1) * numel(uY1) == numel(uX2)
%
% % UPDATE april 2023 - some variant of the check below may work for
% % distinguishing coordine pairs from grid vecors
%
%    % Convert input formats to grid vectors
%    if ismatrix(x) && ismatrix(y) && numel(x) == numel(y)
%       % grids (i.e. 2-d matrices aka arrays)
%       x = unique(x(:),'sorted');
%       y = unique(y(:),'sorted');
%    else
%       unique_x = unique(x,'sorted');
%       unique_y = unique(y,'sorted');
%
%       if numel(unique_x) * numel(unique_y) == numel(x)
%           % grid vectors or coordinate-pairs representing grid cell coordinates
%           x = unique_x;
%           y = unique_y;
%       else
%           error(['The input x, y data do not represent the coordinates ' ...
%              'of a regular or uniform grid.']);
%       end
%    end


% % the original method enforced input
% assert(X(1,1)==min(X(:)) & X(1,2)>X(1,1), ...
%    'Input argument 1, X, must be oriented E-W');
% assert(Y(1,1)==max(Y(:)) & Y(1,1)>Y(2,1), ...
%    'Input argument 2, Y, must be oriented N-S');
