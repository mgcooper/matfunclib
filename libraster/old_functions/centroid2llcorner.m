function [ X,Y ] = point2arcgrid( X1,Y1 )
%POINT2ARCGRID This function deals with the problem that arises when you
%have gridded data where the lat lon coords correspond to the center of the
%grid cells. If you try to use arcgridwrite for example, it will interpret
%the lower left coordinates as the lower left corners of the lower left
%grid cell, when in fact the coords are the center of the lower left grid
%cell. The output of this function is the X and Y matrices that are then
%passed to arcgridwrite2 to create the grids with correct llcorners
%   Detailed explanation goes here

format long

dims = size(X1);
ncols = dims(2);
nrows = dims(1);
xpointll = X1(nrows,1);
ypointll = Y1(nrows,1);
cellsize = Y1(1,1) - Y1(2,1);

xllcorner = xpointll - cellsize/2;
yllcorner = ypointll - cellsize/2;

xlrcorner = xllcorner + (ncols-1)*cellsize;
yulcorner = yllcorner + (nrows-1)*cellsize;

x = xllcorner:cellsize:xlrcorner;
y = yllcorner:cellsize:yulcorner;
y = y'; y = flipud(y);

y1 = y;
a = size(y);
while a(2) < ncols
    y = [y y1];
    a = size(y);
end
Y = y;

x1 = x;
b = size(x);
while b(1) < nrows
    x = [x; x1];
    b = size(x);
end
X = x;
end

