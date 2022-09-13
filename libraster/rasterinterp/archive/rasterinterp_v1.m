function Zq = rasterinterp(Z,R,Rq,varargin)

% todo: add support for fname in, fname out

%RASTERINTERP Interpolate spatially referenced raster Z defined by
% map/geographic raster reference object R onto a new grid Zq defined by 
% map/geographic raster reference object Rq. Default interpolation is 
% nearest neighbor, user specifies alternate methods 'bilinear', 'cubic', 
% or 'spline' following syntax of geointerp.m / mapinterp.m (Copyright 2016 
% The MathWorks, Inc.). Works with planar (projected) and geographic data.

%   This function is a wrapper for the in-built Matlab functions
%   mapinterp.m and geointerp.m (Copyright 2016 The MathWorks, Inc.), 
%   designed to support gridded data by default.
%   This function accepts and returns 2-d gridded data and accepts map 
%   raster reference objects to define a new query grid Zq, whereas 
%   mapinterp.m and geointerp.m return a vector of interpolated values at
%   each lat/lon query pair in xq,yq, requiring additional pre- and/or 
%   post-processing for gridded dataset i/o

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

if strcmp(Rq.CoordinateSystemType,'planar')
    Zq = maprasterinterp(Z,R,Rq,varargin);
elseif strcmp(Rq.CoordinateSystemType,'Geographic')
    Zq = georasterinterp(Z,R,Rq,varargin);
end

    function maprasterinterp(
% build query grid from Rq, adjusted to cell centroids
xps                 =   Rq.CellExtentInWorldX; % x pixel size
xmin                =   Rq.XWorldLimits(1)+xps/2; % left limit
xmax                =   Rq.XWorldLimits(2)-xps/2; % right limit
xq                  =   xmin:xps:xmax;

% y direction
yps                 =   Rq.CellExtentInWorldY; % y pixel size
ymin                =   Rq.YWorldLimits(1)+yps/2; % bottom limit
ymax                =   Rq.YWorldLimits(2)-yps/2; % top limit
yq                  =   ymin:yps:ymax;

% construct unique x,y pairs for each Zq grid centroid
[X,Y]               =   meshgrid(xq,yq);
Xq                  =   reshape(X,size(X,1)*size(X,2),1);
Yq                  =   reshape(Y,size(Y,1)*size(Y,2),1);

% call mapinterp and reshape back into a grid, Zq
Zq                  =   mapinterp(Z,R,Xq,Yq,varargin{:});
Zq                  =   reshape(Zq,length(yq),length(xq)); 

% mapinterp behavior changed in ver2019a and Zq needs to be flipped ud
vrelease            =   version('-release');
if strcmp(vrelease,'2019a')
    Zq              =   flipud(Zq);
end

end
