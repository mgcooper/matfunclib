function [cellsizeX,cellsizeY,tflatlon,tol] = mapgridcellsize(X,Y)

% determine if the data are planar or geographic
tflatlon = islatlon(Y(1,1),X(1,1));

% get an estimate of the grid resolution (i.e. the grid cell size)
xres = diff(X(1,:));
yres = diff(Y(:,1));

% check that the gridding is uniform.
if tflatlon
   tol = -7; % approximately 1 cm in units of degrees
else
   % tol = -2; % nearest cm
   tol = 0; % nearest m (changed for MAR)
end

% round to tol and take second derivative, should == 0 everywhere
assert(all(roundn(diff(abs(xres),2),tol)==0), ...
   ['Input argument 1, X, must have uniform grid spacing. ' ...
   'You might need to round the X/Y or LON/LAT grids ' ...
   'to a uniform precision']);
assert(all(roundn(diff(abs(yres),2),tol)==0), ...
   ['Input argument 2, Y, must have uniform grid spacing. ' ...
   'You might need to round the X/Y or LON/LAT grids ' ...
   'to a uniform precision']);

% extend the lat/lon limits by 1/2 cell in both directions
cellsizeX = abs(xres(1));
cellsizeY = abs(yres(1));
% cellsize = [cellsizeX, cellsizeY];