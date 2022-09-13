function Zclip = rasterclip(Z,R,Rclip,varargin)

% read in the R to get the bounding box then try mapoutline and then feed 
% that to poly2mask or maybe maptrims

%RASTERINTERP Clip spatially referenced raster Z associated with
% map raster reference object R using the template grid defined by map 
% raster reference object Rclip. Default interpolation is nearest neighbor, 
% user may specify alternate methods 'bilinear', 'cubic', or 'spline' 
% following syntax of mapinterp.m. Cell size of Z is preserved in Zclip,
% for resampling to Rclip cell size use rasterinterp.m. The upper left
% corner of Zclip is aligned with the upper left corner defined by Rclip,
% but the right and bottom edges may not align if the cell size of Z is not
% a perfect divisor of the cell size defined by Rclip (identical to
% behavior of arcpy 'clip_raster.py' function

% I realized I can use mapoutline to create a vector bounding box and
% poly2mask to do the clipping

%   Author: Matt Cooper, guycooper@ucla.edu, May 2019

%   Syntax

%   Zq = rasterinterp(Z,R,Rq)
%   Zq = rasterinterp(...,method)

%   Description

%   Zq = rasterinterp(Z,R,Rq) interpolates the spatially referenced
%   raster Z, returning a value in Zq for each of the query points in
%   the grid defined by Rq. R is a map raster reference object, which
%   specifies the location and extent of data in Z. Rq is a map raster 
%   reference object, which specifies the location and extent of data in Zq

%   Zq = rasterinterp(...,method) specifies alternate methods. The default
%   is linear interpolation. Available methods are:
%
%     'nearest' - nearest neighbor interpolation
%     'linear'  - bilinear interpolation
%     'cubic'   - bicubic interpolation
%     'spline'  - spline interpolation
%
%   See also mapinterp geointerp, interp2, griddedInterpolant, meshgrid

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

end
