function R = rasterref(X,Y,cell_interpretation)

% NOTE: This is only being kept for the section around line 96 where I
% initially tried adjusting for cell edges. I think Rpost2cells negates the
% need for that infomration, but could be useful reference

%RASTERREF R = rasterref(X,Y) constructs spatial referencing object R from 
%2-d grids X,Y that define the E-W and N-S coordinates of each grid cell. 
%The default interpretation is that the X,Y coordinate pairs
%represent the centroids of each grid cell, which is consistent with the
%matlab 'Postings' interpretation. To avoid 
%X and Y can be geographic or projected (planar) coordinates.

%   Author: Matt Cooper, guycooper@ucla.edu, June 2019
%   Citation: Matthew Cooper (2019). matrasterlib
%   (https://www.github.com/mguycooper/matrasterlib), GitHub. Retrieved MMM
%   DD, YYYY.

%   Syntax

%   R = rasterref(X,Y)
%   R = rasterref(LON,LAT)

%   Description

%   R = rasterref(X,Y) constructs spatial referencing object R from 2-d
%   grids of E-W (longitude) and N-S (latitude) coordinates X,Y. X and Y
%   are 2-d numeric matrices (grids) of equal size oriented E-W and N-S
%   such that the linear (row,col) index (1,1) is the northwest corner and
%   the coordinate pair X(1,1),Y(1,1) is the centroid of the northwest
%   corner grid cell, consistent with an interpretation of raster grid cell
%   values representing the centroid of each grid cell. X defines the E-W
%   (longitude or projected coordinate) value of every grid cell and Y
%   defines the N-S (latitude or projected coordinate) value of every grid
%   cell, as would be provided by a netcdf or h5 scientific raster dataset
%   or using [X,Y]=meshgrid(x,y) where x and y are vectors that span
%   min(x):x_cell_extent:max(x) and min(y):y_cell_extent:max(y). X and Y
%   can be geographic or planar coordinate systems.

%   See also rasterref, georefcells, maprefcells, meshgrid

%   Examples

%% Check inputs
                    
% confirm there are two inputs
narginchk(3,3)

% confirm X and Y are 2d numeric grids of equal size
validateattributes(X, {'numeric'}, {'2d','size',size(Y)}, 'rasterref', 'X', 1)
validateattributes(Y, {'numeric'}, {'2d','size',size(X)}, 'rasterref', 'Y', 2)

% confirm X and Y have constant grid spacing (rounding error tol = 10^-6)
assert(all(roundn(diff(X(1,:),2),-6)==0), ...
                'Input argument 1, X, must have uniform grid spacing');
assert(all(roundn(diff(Y(:,1),2),-6)==0), ...
                'Input argument 2, Y, must have uniform grid spacing');

% confirm X is oriented E-W and Y is N-S
assert(X(1,1)==min(X(:)) & X(1,2)>X(1,1), ...
                'Input argument 1, X, must be oriented E-W');
assert(Y(1,1)==max(Y(:)) & Y(1,1)>X(2,1), ...
                'Input argument 2, Y, must be oriented N-S');

% determine if R is planar or geographic and call the appropriate function
tf                  =   islatlon(Y(1,1),X(1,1));
if tf
    R               =   rasterrefgeo(X,Y,cell_interpretation);
else
    R               =   rasterrefmap(X,Y,cell_interpretation);
end

%% apply the appropriate function

    function R = rasterrefmap(X,Y,cell_interpretation)
        
        xlims       =   [min(X(:)) max(X(:))];
        ylims       =   [min(Y(:)) max(Y(:))];
        rasterSize  =   size(X);
        if strcmp(cell_interpretation,'Cells')
            R       =   maprefcells(xlims,ylims,rasterSize, ...
                            'ColumnsStartFrom','north', ...
                            'RowsStartFrom', 'west');
        elseif strcmp(cell_interpretation,'Postings')
            R       =   maprefpostings(xlims,ylims,rasterSize, ...
                            'ColumnsStartFrom','north', ...
                            'RowsStartFrom', 'west');
        end
    end

    function R = rasterrefgeo(X,Y,cell_interpretation)
        
        % 'columnstartfrom','south' is default and corresponds to S-N
        % oriented grid as often provided by netcdf and h5 but for sanity 
        % I require this function accept N-S oriented grids i.e. index 
        % (1,1) is NW corner, consequently set 'columnstartfrom','north'
        
        xcellsize   =   abs(X(1,2)-X(1,1));
        ycellsize   =   abs(Y(2,1)-Y(1,1));
        xlims       =   [min(X(:)) max(X(:))];
        ylims       =   [min(Y(:)) max(Y(:))];
        xlims(1)    =   xlims(1)-xcellsize/2;
        xlims(2)    =   xlims(2)+xcellsize/2;
        ylims(1)    =   ylims(1)-ycellsize/2;
        ylims(2)    =   ylims(2)+ycellsize/2;
        rasterSize  =   size(X);
        
        if strcmp(cell_interpretation,'Cells')
            R       =   georefcells(ylims,xlims,rasterSize, ...
                            'ColumnsStartFrom','north', ...
                            'RowsStartFrom', 'west');

%             R       =   georefcells(ylims,xlims,ycellsize,xcellsize, ...
%                             'ColumnsStartFrom','north', ...
%                             'RowsStartFrom', 'west');
        elseif strcmp(cell_interpretation,'Postings')
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

