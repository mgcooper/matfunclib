function R = rasterref(X,Y,rasterInterpretation)

% Note: I decided to make georefpostings the default behavior, since I
% think nearly all raster datasets should be interpreted this way when
% going from an X,Y meshgrid to R. The user can specify 'cells' if desired
% UPDATE: I might instead convert postings to cells using the hidden
% transformation I found, but I might need to figure out a way to discern a
% priori which it is

%RASTERREF R = rasterref(X,Y,rasterInterpretation) constructs spatial
%referencing object R from 2-d grids X,Y that define the E-W and N-S
%coordinates of each grid cell. The default interpretation is 'postings'
%i.e. that the X,Y coordinate pairs represent the centroids of each grid
%cell. User can specify 'cells' if the X,Y coordinate pairs represent the
%edges of the grid cells. X and Y can be geographic or projected (planar)
%coordinates.

%   This function exists because many geospatial datasets are provided with
%   vectors or grids of latitude/longitude and/or planar coordinate values
%   that represent the centroid or cell edges of each grid-cell, but many
%   Matlab Mapping Toolbox functions require the spatial referencing object
%   R as input. This function creates the object R from the
%   latitude/longitude or x/y coordinate vectors or grids. 

%   Author: Matt Cooper, guycooper@ucla.edu, June 2019
%   Citation: Matthew Cooper (2019). matrasterlib
%   (https://www.github.com/mguycooper/matrasterlib), GitHub. Retrieved MMM
%   DD, YYYY.

%   Syntax

%   R = rasterref(X,Y)
%   R = rasterref(LON,LAT)
%   R = rasterref(__,rasterInterpretation)

%   Description

%   R = rasterref(X,Y) constructs spatial referencing object R from 2-d
%   grids of E-W (longitude) and N-S (latitude) coordinates X,Y. X and Y
%   are 2-d numeric matrices (grids) of equal size oriented E-W and N-S
%   such that the linear (row,col) index (1,1) is the northwest corner grid
%   cell and the coordinate pair X(1,1),Y(1,1) is (by default) intepreted
%   as the centroid of the northwest corner grid cell. This is equivalent
%   to a 'postings' rasterInterpretation. X defines the E-W (longitude or
%   projected coordinate) value of every grid cell centroid and Y defines
%   the N-S (latitude or projected coordinate) value of every grid cell
%   centroid. The default 'postings' assumption is consistent with an
%   interpretation of raster grid cell values representing the centroid of
%   each grid cell, for example as would be provided in a netcdf or h5
%   scientific raster dataset or if using [X,Y]=meshgrid(x,y) where x and y
%   are vectors that span min(x):x_cell_extent:max(x) and
%   min(y):y_cell_extent:max(y) where x and y define the coordinates of
%   data values (not cell edges). X and Y can be geographic or planar
%   coordinate systems.

%   R = rasterref(X,Y,'cells') applies the 'cells' intepretation instead of
%   'postings', which is consistent with an interpretation that X,Y define
%   the E-W and N-S coordinates of the grid cell edges, for example as
%   is commonly the case for image-based data (e.g. MODIS satellite
%   imagery).

%   See also rasterref, georefcells, maprefcells, meshgrid

%   Examples

%% Check inputs
                    
% confirm there are at least two and no more than 3 inputs
narginchk(2,3)

% if no rasterInterpretation is given, assign 'postings', otherwise make
% sure either 'cells' or 'postings' is given
if nargin == 2
    rasterInterpretation = 'postings';
elseif nargin == 3
    assert(strcmp(rasterInterpretation,'cells') | ...
            strcmp(rasterInterpretation,'postings'), ...
            ['Input argument 3, rasterInterpretation, must be either ', ...
            '"cells" or "postings"']);    
end

% confirm X and Y are 2d numeric grids of equal size
validateattributes(X, {'numeric'}, {'2d','size',size(Y)}, 'rasterref', 'X', 1)
validateattributes(Y, {'numeric'}, {'2d','size',size(X)}, 'rasterref', 'Y', 2)


% TESTING. I moved the tf statement up top so I can use a custom tolerance
% for planar vs geo. I got to the point where I was going to read in a
% bunch of different raster datasets and figure out the best way to deal
% with the rounding tolerance, but the raster datasets were not working
% well (the dresden GRACDE data has weird spacing and the nc files would
% not open, no idea why). i got tired and gave up. IF I want to pick up on
% this, i htink the key is getting a handful of test data sets, maybe use
% matlab built in data, and figure out how to deal with small
% inconsistencies in the grid spacing. Otherwise, I can just make the
% funciton 'dumb', chekc for uniform spacign, if not found, issue an
% error and exit

% also see grid2R in util 

% determine if R is planar or geographic
tf                  =   islatlon(Y(1,1),X(1,1));

% get an estimate of the grid resolution (i.e. the grid cell size)
xres                =   diff(X(1,:));
yres                =   diff(Y(:,1));

% check that the gridding is uniform. if the first differences are not all
% equal, check for small errors, otherwise issue a warning and exit. This
% can be difficult because some grids have small numerical errors, and for
% the same magnitude of small error the real-world error can be very
% different in geo vs planar, so use different rounding tolerance for geo
if all(xres == xres(1)) && all(yres == yres(1))
    xres            =   xres(1);
    yres            =   yres(1);
else
    if tf
        tol         =   % insert a custom tolerance based on the size of the grid spacing. Probably best to use the maximum grid spacing found. 
    else
        tol         =   % same. might be able to remove the tf statement and just use a custom tolerance that works fo both planar and geo. Otherwise, i could replace these with generic values
    end
    
    assert(all(roundn(diff(X(1,:),2),tol)==0), ...
                'Input argument 1, X, must have uniform grid spacing');
    assert(all(roundn(diff(Y(:,1),2),tol)==0), ...
                'Input argument 2, Y, must have uniform grid spacing');
end 

% NOTE: may need to think harder about this, possibly set one tolerance for
% geographic and another for projected, or round to zero and get ndigits to
% discern a reasonable tolerance e.g. lat lon could have non-constant grid
% spacing that differs by 1/1000 of a degree, whereas it would be
% unreasonable for a utm grid in units of meters to differ by 1 mm
% confirm X and Y have constant grid spacing (rounding error tol = 10^-3)
assert(all(roundn(diff(X(1,:),2),-3)==0), ...
                'Input argument 1, X, must have uniform grid spacing');
assert(all(roundn(diff(Y(:,1),2),-3)==0), ...
                'Input argument 2, Y, must have uniform grid spacing');

% confirm X is oriented E-W and Y is N-S
assert(X(1,1)==min(X(:)) & X(1,2)>X(1,1), ...
                'Input argument 1, X, must be oriented E-W');
assert(Y(1,1)==max(Y(:)) & Y(1,1)>Y(2,1), ...
                'Input argument 2, Y, must be oriented N-S');

% call the appropriate function for planar or geographic 
if tf
    R               =   rasterrefgeo(X,Y,rasterInterpretation);
else
    R               =   rasterrefmap(X,Y,rasterInterpretation);
end

%% apply the appropriate function

    function R = rasterrefmap(X,Y,rasterInterpretation)
        
        % NOTE: i convert to double because I have encountered X,Y grids
        % provided by netcdf files that are stored as type uint, but it
        % might be better to convert X and Y to single or double and
        % confirm what is most compatible with the functions called
        xlims       =   double([min(X(:)) max(X(:))]);
        ylims       =   double([min(Y(:)) max(Y(:))]);
        rasterSize  =   size(X);
        if strcmp(rasterInterpretation,'cells')
            R       =   maprefcells(xlims,ylims,rasterSize, ...
                            'ColumnsStartFrom','north', ...
                            'RowsStartFrom', 'west');
        elseif strcmp(rasterInterpretation,'postings')
            R       =   maprefpostings(xlims,ylims,rasterSize, ...
                            'ColumnsStartFrom','north', ...
                            'RowsStartFrom', 'west');
        end
    end

    function R = rasterrefgeo(X,Y,rasterInterpretation)
        
        % 'columnstartfrom','south' is default and corresponds to S-N
        % oriented grid as often provided by netcdf and h5 but for sanity 
        % I require this function accept N-S oriented grids i.e. index 
        % (1,1) is NW corner, consequently set 'columnstartfrom','north'
        
        xlims       =   double([min(X(:)) max(X(:))]);
        ylims       =   double([min(Y(:)) max(Y(:))]);
        rasterSize  =   size(X);
        
        if strcmp(rasterInterpretation,'cells')
            R       =   georefcells(ylims,xlims,rasterSize, ...
                            'ColumnsStartFrom','north', ...
                            'RowsStartFrom', 'west');
        elseif strcmp(rasterInterpretation,'postings')
            R       =   georefpostings(ylims,xlims,rasterSize, ...
                            'ColumnsStartFrom','north', ...
                            'RowsStartFrom', 'west');
        end
                        
        % note: R.CellExtentInLongitude should equal:
        % (R.LongitudeLimits(2)-R.LongitudeLimits(1))/R.RasterSize(2)
        % but unless pre-processing is performed on standard netcdf or h5
        % grid to adjust for edge vs centroid, a 'cells' interpretation
        % gets it wrong
    end
        
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

