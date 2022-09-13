function [in,on] = rasterclip(R,shp)

%RASTERCLIP [in,on] = rasterclip(x,y,shp) clips raster to shp

% constructs spatial
%referencing object R from 2-d grids X,Y that define the E-W and N-S
%coordinates of each grid cell. User provides rasterInterpretation as
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

%   R = rasterref(X,Y,rasterInterpretation)
%   R = rasterref(LON,LAT,rasterInterpretation)

%   Description

%   R = rasterref(X,Y) constructs spatial referencing object R from 1-d
%   vectors or 2-d grids of E-W (longitude) and N-S (latitude) coordinates
%   X,Y. If X and Y are 2-d numeric matrices (grids) they must be equal
%   size. If they are not oriented E-W and N-S such that the linear
%   (row,col) index (1,1) is the northwest corner grid cell, they are
%   re-oriented E-W and N-S. The coordinate pair X(1,1),Y(1,1) is
%   intepreted as the centroid of the northwest corner grid cell for
%   rasterInterpretation 'Postings' and as the edge of the northwest corner
%   grid cell for rasterInterpretation 'Cells'. X defines the E-W
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
narginchk(2,2)

% confirm R is either MapCells or GeographicCellsReference objects
validateattributes(R, ...
                        {'map.rasterref.MapCellsReference', ...
                        'map.rasterref.GeographicCellsReference', ...
                        'map.rasterref.MapPostingsReference', ...
                        'map.rasterref.GeographicPostingsReference'}, ...
                        {'scalar'}, 'rasterclip', 'R', 1)

% determine if the data are planar or geographic
% tf                  =   islatlon(Y(1,1),X(1,1));

%% apply the appropriate function
[X,Y]               =   R2grid(R);
x                   =   reshape(X,size(X,1)*size(X,2),1);
y                   =   reshape(Y,size(Y,1)*size(Y,2),1);
[polyx,polyy]       =   closePolygonParts(shp.X,shp.Y);
[in,on]             =   inpolygon(x,y,polyx,polyy);

% %%
%     function R = rasterrefmap(X,Y,cellInterpretation)
%         
%         % NOTE: i convert to double because I have encountered X,Y grids
%         % provided by netcdf files that are stored as type uint, but it
%         % might be better to convert X and Y to single or double and
%         % confirm what is most compatible with the functions called
%         xlims       =   double([min(X(:)) max(X(:))]);
%         ylims       =   double([min(Y(:)) max(Y(:))]);
%         rasterSize  =   size(X);
%         if strcmp(cellInterpretation,'cells')
%             R       =   maprefcells(xlims,ylims,rasterSize, ...
%                             'ColumnsStartFrom','north', ...
%                             'RowsStartFrom', 'west');
%         elseif strcmp(cellInterpretation,'postings')
%             R       =   maprefpostings(xlims,ylims,rasterSize, ...
%                             'ColumnsStartFrom','north', ...
%                             'RowsStartFrom', 'west');
%         end
%     end
% 
%     function R = rasterrefgeo(X,Y,cellInterpretation)
%         
%         % 'columnstartfrom','south' is default and corresponds to S-N
%         % oriented grid as often provided by netcdf and h5 but for sanity 
%         % I require this function accept N-S oriented grids i.e. index 
%         % (1,1) is NW corner, consequently set 'columnstartfrom','north'
%         
%         xlims       =   double([min(X(:)) max(X(:))]);
%         ylims       =   double([min(Y(:)) max(Y(:))]);
%         rasterSize  =   size(X);
%         
%         if strcmp(cellInterpretation,'cells')
%             R       =   georefcells(ylims,xlims,rasterSize, ...
%                             'ColumnsStartFrom','north', ...
%                             'RowsStartFrom', 'west');
%         elseif strcmp(cellInterpretation,'postings')
%             R       =   georefpostings(ylims,xlims,rasterSize, ...
%                             'ColumnsStartFrom','north', ...
%                             'RowsStartFrom', 'west');
%         end
%                         
%         % note: R.CellExtentInLongitude should equal:
%         % (R.LongitudeLimits(2)-R.LongitudeLimits(1))/R.RasterSize(2)
%         % but unless pre-processing is performed on standard netcdf or h5
%         % grid to adjust for edge vs centroid, a 'cells' interpretation
%         % gets it wrong
%     end
%         
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

