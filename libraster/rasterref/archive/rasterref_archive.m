function R = rasterref(X,Y,cellInterpretation)

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
%   satellite and climate model data in Matlab©
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

%   Examples - forthcoming

%% Check inputs

% confirm mapping toolbox is installed
assert(license('test','map_toolbox')==1, ...
                        'rasterref requires Matlab''s Mapping Toolbox.')
                    
% confirm there are at least two and no more than 3 inputs
narginchk(3,3)

% if x,y are 1-d vectors, build a 2-d grid. E-W/N-S orientation is handled below
if isvector(X) && isvector(Y)
    [X,Y]           =   meshgrid(X,Y);
end

% confirm X and Y are 2d numeric grids of equal size
validateattributes(X, {'numeric'}, {'2d','size',size(Y)}, 'rasterref', 'X', 1)
validateattributes(Y, {'numeric'}, {'2d','size',size(X)}, 'rasterref', 'Y', 2)

% allow user to pass in the following cellInterpretation values
cellInterpretation = validatestring(cellInterpretation, ...
            {'posting','postings','Posting','Postings', ...
            'cell','cells','Cell','Cells', ...
            'centroid','centroids','Centroid','Centroids', ...
            'edge','edges','Edge','Edges', ...
            'model','modeled','Model','Modeled', ...
            'image','Image'}, ...
            'rasterref', 'cellInterpretation', 3);

% set cellInterpretation to the required values 'postings' or 'cells'        
switch cellInterpretation
    case {  'posting','postings','Posting','Postings',      ...
            'centroid','centroids','Centroid','Centroids',  ...
            'model','modeled','Model','Modeled'}
        
        cellInterpretation = 'postings';
        
    case {  'cell','cells','Cell','Cells',                  ...
            'edge','edges','Edge','Edges',                  ...
            'image','Image'}                               
        
        cellInterpretation = 'cells';
end
        
% if X is oriented W-E, orient it E-W
if X(1,1)~=min(X(:)) || X(1,2)<X(1,1)
    X               =   fliplr(X);
    disp(['Input argument 1, X, appears to be oriented W-E. It was ' ...
        're-oriented E-W, and the output of this function, R, assumes the ' ...
        'data referenced by R is oriented E-W.']);
end

% if Y is oriented S-N, orient it N-S
if Y(1,1)~=max(Y(:)) || Y(1,1)>Y(2,1)
    Y               =   flipud(Y);
    disp(['Input argument 2, Y, appears to be oriented S-N. It was ' ...
        're-oriented N-S, and the output of this function, R, assumes the ' ...
        'data referenced by R is oriented N-S.']);
end
            
% the original method enforced input
% assert(X(1,1)==min(X(:)) & X(1,2)>X(1,1), ...
%                 'Input argument 1, X, must be oriented E-W');
% assert(Y(1,1)==max(Y(:)) & Y(1,1)>Y(2,1), ...
%                 'Input argument 2, Y, must be oriented N-S');

% determine if the data are planar or geographic
tf                  =   islatlon(Y(1,1),X(1,1));

% get an estimate of the grid resolution (i.e. the grid cell size)
xres                =   diff(X(1,:));
yres                =   diff(Y(:,1));

% check that the gridding is uniform.
if tf
    tol             =   -7; % approximately 1 cm in units of degrees
else
    tol             =   -2; % nearest cm
end

% round to tol and take second derivative, should == 0 everywhere
assert(all(roundn(diff(xres,2),tol)==0), ...
            ['Input argument 1, X, must have uniform grid spacing. ' ...
            'You might need to round the X/Y or LON/LAT grids ' ...
            'to a uniform precision']);
assert(all(roundn(diff(yres,2),tol)==0), ...
            ['Input argument 2, Y, must have uniform grid spacing. ' ...
            'You might need to round the X/Y or LON/LAT grids ' ...
            'to a uniform precision']);

cellsizeX           =   abs(xres(1));
cellsizeY           =   abs(yres(1));
halfX               =   cellsizeX/2;
halfY               =   cellsizeY/2;
% this is the basic approach, does not deal with small errors
% assert(all(xres(1) == xres), ...
%             'Input argument 1, X, must have uniform grid spacing');
% assert(all(yres(1) == yres), ...
%             'Input argument 2, Y, must have uniform grid spacing');

% determine if R is planar or geographic and call the appropriate function
if tf
    R               =   rasterrefgeo(X,Y,halfX,halfY,cellInterpretation);
else
    R               =   rasterrefmap(X,Y,halfX,halfY,cellInterpretation);
end

%% apply the appropriate function

    function R = rasterrefmap(X,Y,halfX,halfY,cellInterpretation)
        
        % NOTE: i convert to double because I have encountered X,Y grids
        % provided by netcdf files that are stored as type uint, but it
        % might be better to convert X and Y to single or double and
        % confirm what is most compatible with the functions called
        xlims       =   double([floor(min(X(:))) ceil(max(X(:)))]);
        ylims       =   double([floor(min(Y(:))) ceil(max(Y(:)))]);
        xlims(1)    =   xlims(1)-halfX;
        xlims(2)    =   xlims(2)+halfX;
        rasterSize  =   size(X);
        if strcmp(cellInterpretation,'cells')
            R       =   maprefcells(xlims,ylims,rasterSize, ...
                            'ColumnsStartFrom','north', ...
                            'RowsStartFrom', 'west');
        elseif strcmp(cellInterpretation,'postings')
            R       =   maprefpostings(xlims,ylims,rasterSize, ...
                            'ColumnsStartFrom','north', ...
                            'RowsStartFrom', 'west');
        end
    end

    function R = rasterrefgeo(X,Y,cellInterpretation)
        
        % 'columnstartfrom','south' is default and corresponds to S-N
        % oriented grid as often provided by netcdf and h5 but for sanity 
        % I require this function accept N-S oriented grids i.e. index 
        % (1,1) is NW corner, consequently set 'columnstartfrom','north'
        
        xlims       =   double([min(X(:)) max(X(:))]);
        ylims       =   double([min(Y(:)) max(Y(:))]);
        rasterSize  =   size(X);
        
        if strcmp(cellInterpretation,'cells')
            R       =   georefcells(ylims,xlims,rasterSize, ...
                            'ColumnsStartFrom','north', ...
                            'RowsStartFrom', 'west');
        elseif strcmp(cellInterpretation,'postings')
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

