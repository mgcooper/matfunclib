function R = grid2R(X,Y)

% NOTE: I might delete everything in here (which is identical to rasterref
% and replace with this:

%GRID2R R = grid2R(X,Y) is an alias for rasterref

%GRID2R R = grid2R(X,Y) constructs spatial referencing object R from 2-d
%grids of E-W (longitude) and N-S (latitude) coordinates X,Y.

%   Author: Matt Cooper, guycooper@ucla.edu, June 2019
%   Citation: Matthew Cooper (2019). matrasterlib
%   (https://www.github.com/mguycooper/matrasterlib), GitHub. Retrieved MMM
%   DD, YYYY.

%   Syntax

%   R = grid2R(X,Y)

%   Description

%   R = grid2R(X,Y) constructs spatial referencing object R from 2-d grids
%   of E-W (longitude) and N-S (latitude) coordinates X,Y. X and Y are 2-d
%   numeric matrices (grids) of equal size oriented E-W and N-S such that
%   the linear (row,col) index (1,1) is the northwest corner and the
%   coordinate pair X(1,1),Y(1,1) is the centroid of the northwest corner
%   grid cell, consistent with an interpretation of raster grid cell values
%   representing the centroid of each grid cell. X defines the E-W
%   (longitude) value of every grid cell and Y defines the N-S (latitude)
%   value of every grid cell, as would be provided by a netcdf or h5
%   scientific raster dataset or using [X,Y]=meshgrid(x,y) where x and y
%   are vectors that span min(x):x_cell_extent:max(x) and
%   min(y):y_cell_extent:max(y).
% 
%   See also rasterref, georefcells, maprefcells, meshgrid

%% Check inputs

% confirm there are two inputs
narginchk(2,2)

% confirm mapping toolbox is installed
assert( license('test','map_toolbox')==1, ...
   'rastersurf requires Matlab''s Mapping Toolbox.')

% confirm X and Y are 2d numeric grids of equal size
validateattributes(X, {'numeric'}, {'2d','size',size(Y)}, 'grid2R', 'X', 1)
validateattributes(Y, {'numeric'}, {'2d','size',size(X)}, 'grid2R', 'Y', 2)

% NaN positions correspond?
assert(isequal(isnan(X),isnan(Y)), ...
   ['grid2R expected its first and second input arguments, ', ...
   'X and Y, to have NaN-separators in corresponding positions.'])

% confirm X and Y have constant grid spacing (rounding error tol = 10^-6)
% TEST - make the tolerance dependent on the grid spacing size
% I could add an if statement that checks the assert statement and if it is
% n't true, issues a warning and takes the first difference. For now, take
% the first difference and make the function dumb i.e. assume it is
% constant grid spacing
xres = diff(X(1,:));
yres = diff(Y(:,1));
xres = xres(1);
yres = yres(1);
% assert(all(roundn(diff(X(1,:),2),-6)==0),'X must have uniform grid spacing');
% assert(all(roundn(diff(Y(:,1),2),-6)==0),'Y must have uniform grid spacing');

% confirm X is oriented W-E and Y is N-S
% assert(X(1,1)==min(X(:)) & X(1,2)>X(1,1),'X must be oriented W-E');
% assert(Y(1,1)==max(Y(:)) & Y(1,1)>Y(2,1),'Y must be oriented N-S');
if X(1,1)~=min(X(:)) && X(1,2)<X(1,1)
   X = fliplr(X);
   warning(['It appears the X grid is oriented E-W from left to right.' ...
      'The grid was re-oriented W-E. Make sure this is correct']);
elseif Y(1,1)~=max(Y(:)) && Y(1,1)<Y(2,1)
   Y = flipud(Y);
   warning(['It appears the Y grid is oriented S-N from top to bottom.' ...
      'The grid was re-oriented N-S. Make sure this is correct']);
end

% determine if R is planar or geographic and call the appropriate function
tf = islatlon(Y(1,1),X(1,1));
if tf
   R = geogrid2R(X,Y);
else
   R = mapgrid2R(X,Y);
end

%% apply the appropriate function

   function R = mapgrid2R(X,Y)

      % build query grid from R, adjusted to cell centroids
      xlims = double([min(X(:)) max(X(:))]);
      ylims = double([min(Y(:)) max(Y(:))]);
      rasterSize = size(X);
      R = maprefcells(xlims,ylims,rasterSize, ...
         'ColumnsStartFrom','north', ...
         'RowsStartFrom', 'west');
   end

   function R = geogrid2R(X,Y)

      % 'columnstartfrom','south' is default and corresponds to N-S
      % oriented grid as in index (1,1) is NW corner

      xlims = double([min(X(:)) max(X(:))]);
      ylims = double([min(Y(:)) max(Y(:))]);
      rasterSize = size(X);
      R = georefcells(ylims,xlims,rasterSize, ...
         'ColumnsStartFrom','north', ...
         'RowsStartFrom', 'west');
   end

end

% Notes

% for reference, the N-S E-W could be handled here but the error message
% is less informative than custom message with assert
% % confirm X and Y are 2d numeric grids of equal size oriented N-S and E-W
% validateattributes(X(1,:),  {'numeric'}, ...
%                             {'2d','size',size(Y(1,:)),'increasing'}, ...
%                             'R2grid', 'X', 1)
% validateattributes(Y(1,:),  {'numeric'}, ...
%                             {'2d','size',size(X(1,:)),'decreasing'}, ...
%                             'R2grid', 'Y', 2)

