function R1 = bbox2R(bbox,gridRes)

%BBOX2R R = bbox2R(bbox,grid_res) constructs spatial referencing object R
%from 2-by-2 bounding box bbox, for example as provided by mapbbox. The
%cell spacing set by gridRes must be constant. If necessary, maprefcells
%adjusts the limits of the raster slightly to ensure an integer number of
%cells in each dimension.

%   Author: Matt Cooper, guycooper@ucla.edu, June 2019
%   Citation: Matthew Cooper (2019). matrasterlib
%   (https://www.github.com/mguycooper/matrasterlib), GitHub. Retrieved MMM
%   DD, YYYY.

%   Syntax

%   R = bbox2R(bbox,gridRes)

%   Description

%   R = bbox2R(bbox,gridRes) constructs spatial referencing object R from
%   2-by-2 bounding box BBOX. BBOX bounds the outer edges of the image in
%   map coordinates:
%
%                           [minX minY
%                            maxX maxY]

%   parameter gridRes sets the grid spacing. 

%   See also mapbbox

%   Examples

% % Example 1: verify function accuracy against in-built functions
% %   load a raster Z and its referencing object R
%     [Z,R1]  = readgeoraster('MtWashington-ft.grd','OutputType','double');
% %   take the bounding box 
%     bbox    = mapbbox(R1,R1.RasterSize(1),R1.RasterSize(2));
%     R2      = bbox2R(bbox,R1.CellExtentInWorldY);
%     Rcheck  = [R1;R2];
% %   examine Rcheck to confirm the function works
    
% % Example 2: build a custom bbox and georeference it
% %   load a raster Z and its referencing object R
%     [Z,R]   = readgeoraster('concord_ortho_w.tif');
% %   load a shapefile, and make a bounding box around it
%     pond    = shaperead('concord_hydro_area.shp', 'RecordNumbers', 14);
% %   query the ortho intensity values within the area defined by pond
%     bbox    = pond.BoundingBox;
%     Rbox    = bbox2R(bbox,10);
%     [xq,yq] = R2grid(Rbox);
%     I       = mapinterp(Z,R,xq,yq,'nearest');
%     mean(I(:)) % mean intensity value inside 'pond'
    
    
%% Check inputs

% confirm mapping toolbox is installed
assert(license('test','map_toolbox')==1, ...
                        'bb2R requires Matlab''s Mapping Toolbox.')

% confirm there is one inputs
narginchk(1,2)

% confirm BBOX is a 2-by-2 numeric grid
validateattributes(bbox, {'numeric'}, {'2d','size',[2,2]}, 'bb2R', 'bbox', 1)
validateattributes(gridRes, {'numeric'}, {'scalar'}, 'bb2R', 'gridRes', 2)

% bounding box edges
minX    =   bbox(1,1);
maxX    =   bbox(2,1);
minY    =   bbox(1,2);
maxY    =   bbox(2,2);
ylims   =   double([floor(minY) ceil(maxY)]);
xlims   =   double([floor(minX) ceil(maxX)]);

% set the grid spacing
xres    =   gridRes;
yres    =   gridRes;

% determine if the data is planar or geographic and call the appropriate function
tf      =   islatlon(minY,minX);
if tf == 1
    R1  =   geobox2R(xlims,ylims,xres,yres);
else
    R1  =   mapbox2R(xlims,ylims,xres,yres);
end

%% apply the appropriate function

    function R = mapbox2R(xlims,ylims,xres,yres)
        
        % build R
        R   =   maprefcells(    xlims,ylims,xres,yres,      ...
                                'ColumnsStartFrom','north', ...
                                'RowsStartFrom', 'west');
    end

    function R = geobox2R(xlims,ylims,xres,yres)
        
        % 'columnstartfrom','south' is default and corresponds to N-S
        % oriented grid as in index (1,1) is NW corner
        R   =   georefcells(    ylims,xlims,xres,yres, ...
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

