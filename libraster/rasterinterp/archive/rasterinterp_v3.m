function Zq = rasterinterp(Z,R,Rq,method)

%RASTERINTERP Interpolate the spatially referenced raster Z associated with
% the map/geographic raster reference object R onto a new grid Zq defined
% by map/geographic raster reference object Rq. Default interpolation is
% 'bilinear', user specifies alternate methods 'nearest', 'cubic',
% or 'spline' following syntax of geointerp.m / mapinterp.m (Copyright 2016
% The MathWorks, Inc.). Works with planar (projected) and geographic data,
% but R and Rq must both be planar or both be geographic.

%   This function is a wrapper for the in-built Matlab functions
%   mapinterp.m and geointerp.m (Copyright 2016 The MathWorks, Inc.), 
%   designed to support gridded data by default.
%   This function accepts and returns 2-d gridded data and accepts map or
%   geographic raster reference objects to define a new query grid Zq, 
%   whereas mapinterp.m and geointerp.m return a vector of interpolated 
%   values at each lat/lon query pair in xq,yq, requiring additional pre- 
%   and/or post-processing for gridded dataset i/o

%   Author: Matt Cooper, guycooper@ucla.edu, May 2019

%   Syntax

%   Zq = rasterinterp(Z,R,Rq)
%   Zq = rasterinterp(...,method)

%   Description

%   Zq = rasterinterp(Z,R,Rq) interpolates the spatially referenced
%   raster Z onto a new spatially referenced raster Zq. R is a map or 
%   geographic raster reference object, which specifies the location and 
%   extent of data in Z.
%   Rq is a map or geographic raster reference object, which specifies the 
%   location and extent of data in Zq. The interpolated values in Zq 
%   correspond to each grid-cell centroid. Extrapolation is not supported;
%   NaN is returned for spatial locations in Zq outside the limits of Z

%   Zq = rasterinterp(...,method) specifies alternate methods. The default
%   is linear interpolation. Available methods are:
%
%     'nearest' - nearest neighbor interpolation
%     'linear'  - bilinear interpolation
%     'cubic'   - bicubic interpolation
%     'spline'  - spline interpolation
%
%   See also mapinterp, geointerp, interp2, griddedInterpolant, meshgrid

%   Examples
%   
%   In practice, rasterinterp is expected to be used with external geotiff
%   data files that are read into matlab using geotiffread, which returns
%   the Map/Geographic Cells Reference object required as input to
%   rasterinterp. For example, one might have a raster dataset representing
%   topography, and a second raster dataset representing a climate variable
%   such as air temperature. The two rasters overlap, but have different
%   spatial extents and/or resolution. Use rasterinterp to co-register the
%   two rasters to the same spatial extent and resolution so they can be
%   compared on a cell by cell basis. In principle, these are all involve
%   interpolation. In the examples below, the in-built 'topo' dataset is
%   used, and the Geographic Cells Reference object is built from scratch
%   to illustrate the flexibility of rasterinterp, which can be used to
%   subset or resample one raster to the extent and/or resolution of a
%   second raster, or can be used to resample (interpolate) one raster to
%   any desired spatial extent or resolution as defined by Rq

%   Example 1 
%   ---------
%   % subset global topographic data to northern hemisphere
%   clean
%   load topo; Z = topo; clear topo
%   R = georefcells(topolatlim,topolonlim,size(Z));
%   newlatlim = [0 90];
%   newlonlim = [0 360];
%   newsize = [newlatlim(2) newlonlim(2)];
%   Rq = georefcells(newlatlim,newlonlim,newsize);
%   Zq = rasterinterp(Z,R,Rq);
%   figure; geoshow(Z,R,'DisplayType','surface'); title('Original');
%   figure; geoshow(Zq,Rq,'DisplayType','surface'); title('Interpolated');

%   Example 2 
%   ---------
%   % subset global topographic data to northern hemisphere and resample
%   the data to 3x finer resolution
%   clean
%   load topo; Z = topo; clear topo
%   R = georefcells(topolatlim,topolonlim,size(Z));
%   newlatlim = [0 90];
%   newlonlim = [0 360];
%   newsize = 3.*[newlatlim(2) newlonlim(2)];
%   Rq = georefcells(newlatlim,newlonlim,newsize);
%   Zq = rasterinterp(Z,R,Rq);
%   figure; geoshow(Z,R,'DisplayType','surface'); title('Original');
%   figure; geoshow(Zq,Rq,'DisplayType','surface'); title('Interpolated');

%% Check inputs

% Confirm Z is a numeric or logical grid of size R.RasterSize
validateattributes(Z,   {'numeric', 'logical'}, ...
                        {'size', R.RasterSize}, 'rasterinterp', 'Z', 1)
                    
% Confirm R and Rq are either MapCells or GeographicCellsReference objects
validateattributes(R, ...
                        {'map.rasterref.MapCellsReference', ...
                        'map.rasterref.GeographicCellsReference'}, ...
                        {'scalar'}, 'rasterinterp', 'R', 2)
validateattributes(Rq, ...
                        {'map.rasterref.MapCellsReference', ...
                        'map.rasterref.GeographicCellsReference'}, ...
                        {'scalar'}, 'rasterinterp', 'Rq', 3)
                    
% Set interpolation to 'linear' or as user-defined
if nargin < 4
    method          =   'linear';
else
    method          =   validatestring(method, ...
                        {'nearest', 'linear', 'cubic', 'spline'}, ...
                        'rasterinterp', 'method');
end

% Confirm R and Rq are either both planar or both geographic
assert(strcmp(R.CoordinateSystemType,Rq.CoordinateSystemType), ...
                        ['R and Rq must both be planar or both be ' ...
                        'geographic coordinate systems. Re-projection ' ...
                        'on the fly is not supported at this time']);
                    
% Confirm R and Rq are oriented in the same N/S direction
assert(strcmp(R.ColumnsStartFrom,Rq.ColumnsStartFrom), ...
                        ['R and Rq must be oriented in the same N/S ' ...
                        'direction. Check the ''ColumnsStartFrom'' ' ...
                        'property in the Map/Geographic Cells Reference ' ... 
                        'object']);
                    
% Confirm R and Rq are oriented in the same E/W direction
assert(strcmp(R.RowsStartFrom,Rq.RowsStartFrom), ...
                        ['R and Rq must be oriented in the same E/W ' ...
                        'direction. Check the ''RowsStartFrom'' ' ...
                        'property in the Map/Geographic Cells Reference ' ... 
                        'object']);                    
                    
% If both R and Rq are planar, call the appropriate function
if strcmp(R.CoordinateSystemType,'planar')
    Zq              =   maprasterinterp(Z,R,Rq,method);
elseif strcmp(R.CoordinateSystemType,'geographic')
    Zq              =   georasterinterp(Z,R,Rq,method);
end

%% apply the appropriate function

    function Zq = maprasterinterp(Z,R,Rq,method)
        
        % build query grid from Rq, adjusted to cell centroids
        xps         =   Rq.CellExtentInWorldX; % x pixel size
        xmin        =   Rq.XWorldLimits(1)+xps/2; % left limit
        xmax        =   Rq.XWorldLimits(2)-xps/2; % right limit
        xq          =   xmin:xps:xmax;
        
        % y direction
        yps         =   Rq.CellExtentInWorldY; % y pixel size
        ymin        =   Rq.YWorldLimits(1)+yps/2; % bottom limit
        ymax        =   Rq.YWorldLimits(2)-yps/2; % top limit
        yq          =   ymin:yps:ymax;

        % construct unique x,y pairs for each Zq grid centroid
        [X,Y]       =   meshgrid(xq,yq);
        Xq          =   reshape(X,size(X,1)*size(X,2),1);
        Yq          =   reshape(Y,size(Y,1)*size(Y,2),1);

        % call mapinterp and reshape back into a grid, Zq
        Zq          =   mapinterp(Z,R,Xq,Yq,method);
        Zq          =   reshape(Zq,length(yq),length(xq)); 
        
        % flip the data upside down if oriented S-N
        if strcmp(R.ColumnsStartFrom,'north')
            Zq      =   flipud(Zq);
        end
        
        % flip the data left/right if oriented E-W
        if strcmp(R.ColumnsStartFrom,'east')
            Zq      =   fliplr(Zq);
        end
    end

    % note, geointerp wants latq,lonq whereas mapinterp wants xq,yq
    
    function Zq = georasterinterp(Z,R,Rq,method)
        
        % build query grid from Rq, adjusted to cell centroids
        lonps       =   Rq.CellExtentInLongitude; % x pixel size
        lonmin      =   Rq.LongitudeLimits(1)+lonps/2; % left limit
        lonmax      =   Rq.LongitudeLimits(2)-lonps/2; % right limit
        lonq        =   lonmin:lonps:lonmax;
        
        % y direction
        latps       =   Rq.CellExtentInLatitude; % y pixel size
        latmin      =   Rq.LatitudeLimits(1)+latps/2; % bottom limit
        latmax      =   Rq.LatitudeLimits(2)-latps/2; % top limit
        latq        =   latmin:latps:latmax;
        
        % construct unique x,y pairs for each Zq grid centroid
        [LON,LAT]   =   meshgrid(lonq,latq);
        LONq        =   reshape(LON,size(LON,1)*size(LON,2),1);
        LATq        =   reshape(LAT,size(LAT,1)*size(LAT,2),1);
        
        % call geointerp and reshape back into a grid, Zq
        Zq          =   geointerp(Z,R,LATq,LONq,method);
        Zq          =   reshape(Zq,length(latq),length(lonq)); 
        
        % flip the data or issue a warning if the data are oriented S-N
        if strcmp(R.ColumnsStartFrom,'north')
            Zq      =   flipud(Zq);
        else
%             disp(['The Map/Geographic Cells Reference object says ' ...
%                 'the raster is oriented south up which is unusual. If the ' newline ...
%                 'interpolated output appears upside down, try flipud(Zq) and ' ...
%                 'confirm both Z/R and Zq/Rq are oriented in the same ' newline ...
%                 'N/S direction.']);
        end
        
        % if the data are oriented E-W, flip the data left/right and issue a warning 
        if strcmp(R.ColumnsStartFrom,'east')
            Zq      =   fliplr(Zq);
%             disp(['The Map/Geographic Cells Reference object says ' ...
%                 'the raster is oriented E-W which is unusual. If the ' newline ...
%                 'interpolated output appears backward, try fliplr(Zq) and ' ...
%                 'confirm both Z/R and Zq/Rq are oriented in the same ' newline ...
%                 'E/W direction.']);
        end
    end

end
