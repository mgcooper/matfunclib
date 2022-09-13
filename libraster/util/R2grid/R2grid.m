function [X,Y] = R2grid(R)
%R2GRID [X,Y] = R2grid(R) constructs 2-d grids X and Y of coordinate pairs 
%from spatial referencing object R

%% Check inputs

% confirm mapping toolbox is installed
assert(license('test','map_toolbox')==1, ...
                        'rasterinterp requires Matlab''s Mapping Toolbox.')
                    
% confirm R is either MapCells or GeographicCellsReference objects
validateattributes(R, ...
                        {'map.rasterref.MapCellsReference', ...
                        'map.rasterref.GeographicCellsReference'}, ...
                        {'scalar'}, 'R2grid', 'R', 2)

% note regarding the construction of the grid from the R object. From the
% documentation for MapCellsReference: "The Mapping Toolbox™ and Image
% Processing Toolbox™ use the convention for the location of the origin
% relative to the raster cells or sampling points such that, at a sample
% location or at the center of a cell, x has an integer value equal to the
% column index. Likewise, at a sample location or at the center of a cell,
% y has an integer value equal to the row index.". This is why we construct
% the grid by adding the cell size /2 to the first X world coordinate, and
% subtracting the cells size/2 from the last X world coordinate (m+0.5)
% 
% center of first cell                 center of last cell
%           |                                   |
%           v                                   v         
%                                                         
% 0   0.5   1   1.5   2   2.5  m-1.5 m-1 m-0.5  m  m+0.5  
% o    |    o    |    o    | ... |    o    |    o    |    o 
%                                    
% ^    ^                                             ^    
% |    |                                             |
% |     \                                             \
%  \    raster left edge                              raster right edge 
%   \
%    origin


% o <- origin
% 
% - <- raster top edge ( R.YWorldLimits(1) )
% 
% o <- center of first cell
% 
% -
% 
% .
% .
% .
% 
% -
% 
% o <- center of last cell
% 
% - <- raster bottom edge ( R.YWorldLimits(2) )
% 
% o


% determine if R is planar or geographic and call the appropriate function
if strcmp(R.CoordinateSystemType,'planar')
    [X,Y]   =   mapR2grid(R);
elseif strcmp(R.CoordinateSystemType,'geographic')
    [X,Y]   =   geoR2grid(R);
end

%% apply the appropriate function

    function [X,Y] = mapR2grid(R)
        
        % build query grid from R, adjusted INWARD to cell centroids
        xps         =   R.CellExtentInWorldX;       % x pixel size
        xmin        =   R.XWorldLimits(1)+xps/2;    % left limit
        xmax        =   R.XWorldLimits(2)-xps/2;    % right limit
        xq          =   xmin:xps:xmax;

        % y direction
        yps         =   R.CellExtentInWorldY;       % y pixel size
        ymin        =   R.YWorldLimits(1)+yps/2;    % bottom limit
        ymax        =   R.YWorldLimits(2)-yps/2;    % top limit
        yq          =   ymin:yps:ymax;

        % construct unique x,y pairs for each Zq grid centroid
        [X,Y]       =   meshgrid(xq,yq);
        
        % UPDATE Jul 2019 added this based on experience, this is the
        % reverse of how it's done in rasterinterp
        if strcmp(R.ColumnsStartFrom,'north')
            Y       =   flipud(Y);
        end
        
        % flip the data left/right if oriented E-W
        if strcmp(R.ColumnsStartFrom,'east')
            X       =   fliplr(X);
        end
        
    end

    function [X,Y] = geoR2grid(R)
        
        % build query grid from R, adjusted INWARD to cell centroids
        lonps       =   R.CellExtentInLongitude;        % x pixel size
        lonmin      =   R.LongitudeLimits(1)+lonps/2;   % left limit
        lonmax      =   R.LongitudeLimits(2)-lonps/2;   % right limit
        lonq        =   lonmin:lonps:lonmax;
        
        % y direction
        latps       =   R.CellExtentInLatitude;         % y pixel size
        latmin      =   R.LatitudeLimits(1)+latps/2;    % bottom limit
        latmax      =   R.LatitudeLimits(2)-latps/2;    % top limit
        latq        =   latmin:latps:latmax;
        
        % construct unique x,y pairs for each Zq grid centroid
        [X,Y]       =   meshgrid(lonq,latq);
        
        % UPDATE Jul 2019 added this based on experience, this is the
        % reverse of how it's done in rasterinterp
        if strcmp(R.ColumnsStartFrom,'north')
            Y       =   flipud(Y);
        end
        
        % flip the data left/right if oriented E-W
        if strcmp(R.ColumnsStartFrom,'east')
            X       =   fliplr(X);
        end
    end
        
end

