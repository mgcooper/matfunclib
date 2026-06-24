function [R, X, Y] = rasterref(X, Y, varargin)
   %RASTERREF Construct a spatial referencing object R from grids/vectors X, Y.
   %
   % R = rasterref(X, Y) builds a raster reference object from the E-W (X /
   % longitude) and N-S (Y / latitude) coordinates of a regular grid. X, Y may be
   % 2-d full grids or 1-d grid vectors; if 2-d they must be the same size. They
   % are reoriented so the (1,1) element is the northwest cell, and a full grid is
   % built from grid vectors. By default X, Y are treated as cell CENTERS, and R's
   % outer limits are placed half a cell beyond them so the cell centers coincide
   % with X, Y -- the correct choice for centroid grids such as climate-model /
   % netCDF data. X, Y may be geographic (lon/lat) or projected (planar)
   % coordinates; rasterref detects which (override with 'UseGeoCoords').
   %
   % R = rasterref(X, Y, cellInterpretation) sets the interpretation:
   %   'cells'    (default) X,Y are cell CENTERS; R's limits pad half a cell beyond.
   %   'postings'           X,Y are the sample (posting) positions; R's limits
   %                        coincide with the outer X,Y, with no half-cell offset.
   % cellInterpretation may be given positionally (e.g. rasterref(X,Y,'postings'))
   % or as the 'cellInterpretation' name-value pair; it is case-insensitive and the
   % singular form ('cell'/'posting') is accepted.
   %
   % R = rasterref(__, Name, Value) sets additional options:
   %   'cellInterpretation'  'cells' (default) | 'postings'  (see above)
   %   'projection'          a projcrs to assign to R.ProjectedCRS (planar grids)
   %   'UseGeoCoords'        true/false to force geographic vs planar (default:
   %                         auto-detected from the coordinate ranges)
   %   'silent'              true to suppress the geographic/planar detection note
   %
   % [R, X, Y] = rasterref(__) also returns the reoriented, gridded X, Y (2-d full
   % grids oriented W-E and N-S) that were actually used to build R.
   %
   % R is a MapCellsReference / MapPostingsReference (planar) or a
   % GeographicCellsReference / GeographicPostingsReference (geographic) object.
   %
   % rasterref exists because many geospatial datasets provide coordinate
   % vectors/grids of cell centers (or edges), while many Mapping Toolbox functions
   % require a raster reference object R; rasterref builds R from those coordinates.
   %
   % Limitations: X, Y must form a regular (uniform or rectilinear) grid -- X
   % varies only across columns and Y only down rows. rasterref does NOT accept
   % irregular / curvilinear grids. The usual way to end up with one is
   % reprojection: a grid that is regular in ITS OWN coordinate system becomes
   % curvilinear when reprojected to a different, non-aligned system. For example,
   % starting from a grid that is regular in projection 'proj', going to lon/lat
   % and then forward into a different projection 'projnew' yields xnew,ynew whose
   % spacing varies in both dimensions:
   %   [lat, lon]   = projinv(proj, x, y);          % x,y regular in 'proj'
   %   [xnew, ynew] = projfwd(projnew, lat, lon);   % xnew,ynew curvilinear in 'projnew'
   %   Rnew = rasterref(xnew, ynew)                 % errors: not a rectilinear grid
   % (The same happens to a regular lon/lat grid projected into a planar CRS.) To
   % reference such data, first regularize it onto a uniform grid -- e.g. RASTERIZE
   % (resample scattered / curvilinear x,y,z onto a new regular grid) or GRIDXYZ
   % (build the implied regular grid and gap-fill it) -- then call rasterref.
   %
   % Example:
   %   [LON, LAT] = meshgrid(0:30:90, 30:-30:-60);   % cell centers, 30-deg grid
   %   R  = rasterref(LON, LAT);                      % 'cells': limits padded +-15
   %   Rp = rasterref(LON, LAT, 'postings');          % limits = outer LON,LAT
   %
   % Author: Matt Cooper, guycooper@ucla.edu, June 2019.
   %
   % See also: georefcells, georefpostings, maprefcells, maprefpostings,
   %   rasterize, prepareMapGrid, meshgrid

   % Convention: rasterref treats X,Y as cell CENTERS and pads the limits half a
   % cell to build a 'cells' reference (see the header and
   % docs/raster-conventions-journey.md). rasterize now shares this convention.
   %
   % Caveat: if X,Y are not a full grid (missing rows/columns), prepareMapGrid's
   % cell-size inference can be off -- unique(diff(Y(:,1))) returns the modal
   % spacing plus the gaps. The isfullgrid check below warns about this; rasterize
   % guards it with a gridmember mask.

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
function R = rasterrefmap(X, Y, halfX, halfY, cellInterpretation)

   % Use the raw coordinate min/max -- do NOT round the limits. The old
   % round(min(X(:)), tol) with tol = 0 snapped the limits to the nearest INTEGER,
   % which is wrong for any planar grid with non-integer coordinates (UTM,
   % polar-stereo metres, ...): it shifts the limits up to half a unit and breaks
   % the cell center/edge alignment (the half-cell pad below then lands the edges
   % off the data). The geographic branch dropped this same snapping in May 2024
   % for the same reason; the two now match. See matfunclib-43n.
   [xmin, xmax, ymin, ymax] = deal( ...
      min(X(:)), max(X(:)), min(Y(:)), max(Y(:)));
   rasterSize = size(X);

   if strcmp(cellInterpretation,'cells')
      % 'cells': X,Y are cell CENTERS; maprefcells limits are the outer cell
      % edges, so pad the center extent outward by half a cell.
      xlims = double([xmin-halfX xmax+halfX]);
      ylims = double([ymin-halfY ymax+halfY]);
      R = maprefcells(xlims, ylims, rasterSize, ...
         'ColumnsStartFrom', 'north', ...
         'RowsStartFrom', 'west');
   elseif strcmp(cellInterpretation, 'postings')
      % 'postings': X,Y are the sample (posting) positions themselves; use their
      % extent directly with NO half-cell padding (padding would shift every
      % posting by half a cell).
      xlims = double([xmin xmax]);
      ylims = double([ymin ymax]);
      R = maprefpostings(xlims, ylims, rasterSize, ...
         'ColumnsStartFrom', 'north', ...
         'RowsStartFrom', 'west');
   end
end

function R = rasterrefgeo(X, Y, halfX, halfY, cellInterpretation)

   % May 2024: removed the round(xmin, tol) snapping (and its unused tol
   % argument), see the note in the map version above -- rounding the limits is
   % wrong for global/edge grids.

   % 'columnstartfrom','south' is default and corresponds to S-N oriented grid
   % as often provided by netcdf and h5 but I require this function accept N-S
   % oriented grids i.e. index (1,1) is NW corner, consequently set
   % 'columnstartfrom','north'
   [xmin, xmax, ymin, ymax] = deal(...
      min(X(:)), max(X(:)), min(Y(:)), max(Y(:)));

   rasterSize = size(X);

   if strcmp(cellInterpretation,'cells')

      % 'cells': LON/LAT are cell CENTERS; georefcells limits are the outer cell
      % edges, so pad outward by half a cell. Clamp latitude to [-90, 90] so a
      % grid whose cells reach the poles does not produce limits outside the
      % valid latitude range (georefcells errors otherwise).
      xlims = double([xmin-halfX xmax+halfX]);
      ylims = double([max(ymin-halfY, -90) min(ymax+halfY, 90)]);

      % Warn when the clamp actually fires: a cell CENTERED at +/-90 cannot have a
      % symmetric half-cell edge (it would pass the pole), so the polar row's cell
      % is distorted and R2grid will not recover those centers exactly. Common for
      % pole-touching grids (e.g. MERRA-2 lat -90:0.5:90). Pass the data as
      % 'postings' to reference the pole points exactly. See matfunclib-m0x.
      if (ymin - halfY) < -90 || (ymax + halfY) > 90
         warning([mfilename ':LatitudeClampedAtPole'], ...
            ['Latitude limits clamped to [-90, 90]: cells centered at the pole ' ...
            'are distorted (R2grid will not recover the polar centers exactly). ' ...
            'Use cellInterpretation=''postings'' to reference pole points exactly.'])
      end

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

      % 'postings': LON/LAT are the sample (posting) positions themselves; use
      % their extent directly with NO half-cell padding (padding would shift
      % every posting by half a cell).
      xlims = double([xmin xmax]);
      ylims = double([ymin ymax]);

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

   validCellTypes = {'cells', 'postings'};

   % Accept cellInterpretation as a leading positional argument
   % (rasterref(X,Y,'cells'|'postings'), case-insensitive, singular accepted) in
   % addition to the 'cellInterpretation',value name-value pair. If the first
   % extra argument matches a valid cell type, consume it; otherwise it is a
   % name-value key (e.g. 'projection') and is left for the parser.
   cellTypePositional = '';
   if ~isempty(varargin) && (ischar(varargin{1}) || isstring(varargin{1}))
      try
         cellTypePositional = validatestring(varargin{1}, validCellTypes);
         varargin(1) = [];
      catch
         cellTypePositional = '';
      end
   end

   UseGeoCoordsDefault = false;

   parser = inputParser;
   parser.FunctionName = funcname;
   addRequired( parser, 'X', @validateGridCoordinates);
   addRequired( parser, 'Y', @validateGridCoordinates);
   addParameter(parser, 'cellInterpretation', 'cells', ...
      @(s) ~isempty(validatestring(s, validCellTypes)));
   addParameter(parser, 'projection', 'unknown', @validateProjection);
   addParameter(parser, 'UseGeoCoords', UseGeoCoordsDefault, @islogicalscalar);
   addParameter(parser, 'silent', false, @islogicalscalar);
   parse(parser, X, Y, varargin{:});

   % Retrieve parameter values. Normalize cellInterpretation to its canonical
   % form ('cells'/'postings') so the downstream strcmp branches match regardless
   % of case or singular/plural input. A positional value takes precedence.
   if ~isempty(cellTypePositional)
      cellType = cellTypePositional;
   else
      cellType = validatestring(parser.Results.cellInterpretation, validCellTypes);
   end
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
