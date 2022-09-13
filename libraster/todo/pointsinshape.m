function [lat,lon,val] = pointsinshape(shapeLat,shapeLon,pointsLat, ...
                            pointsLon,inPoints,gridDensity)
%POINTSINSHAPE extracts point values inPoints at coordinates inLat/inLon
%   Detailed explanation goes here

% pretty sure this is for finding raster cells in a shape, but new function
% pointsinpoly should do all this and more ... otoh it looks like this
% might be worth double checking b/c it might be a form of regionprops

% convert the vector lat,lon to 
[borderGrid,rvec]   =   vec2mtx(shapeLat,shapeLon,gridDensity);
R                   =   refvecToGeoRasterReference(rvec,size(borderGrid));
maskVal             =   1;
borderVal           =   1; % note - this is auto from vec2mtx

% create a seed, this one uses the center pixel and 3 for maskVal so I can
% make a figure below to demonsrate the rasterized border, but in general i
% want to use maskVal = 1 so I can multiply
inPt                =   round([size(borderGrid)/2,3]);
testGrid            =   encodem(borderGrid,inPt,borderVal);

% fill cells inside the border with maskVal
inPt                =   round([size(borderGrid)/2,maskVal]);
maskGrid            =   encodem(borderGrid,inPt,borderVal);

% embed the point values into the grid
dataGrid            =   imbedm(pointsLat,pointsLon,inPoints,maskGrid,R);

% multiply the mask by the embedded data grid to set values outside the
% border to zero
dataGrid            =   maskGrid.*dataGrid;

% extract remaining values that are >maskVal
datamasked          =   dataGrid(dataGrid>maskVal);

% get the lat/lon values for these points
[X,Y]               =   R2grid(R);
latmasked           =   Y(dataGrid>maskVal);
lonmasked           =   X(dataGrid>maskVal);

% prep the data for output
lat                 =   latmasked;
lon                 =   lonmasked;
val                 =   datamasked;
end

