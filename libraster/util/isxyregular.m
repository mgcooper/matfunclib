function tf = isxyregular(x,y,varargin)
%ISXYREGULAR returns 1 if the values in x and y are regularly spaced i.e.
%if the distance between each element of x and each element of y is
%constant. It does not check for distance between x and y values.

% check if the coordinates are lat lon or planar
tflatlon = islatlon(y,x);

% check that the gridding is uniform.
if nargin>2
    tol = varargin{1};
elseif tflatlon
    tol = -7; % approximately 1 cm in units of degrees
else
    tol = -2; % nearest cm
end

% get the unique coordinate values
xu = unique(x(:),'sorted');
yu = unique(y(:),'sorted');

% get an estimate of the grid resolution (i.e. the grid cell size)
xres = diff(xu);
yres = diff(yu);

% if length(xu) or length(yu) is <= 2, then 

% check x
if length(xres) == 1
    tfx = true;
else
    tfx = all(roundn(diff(xres,1),tol)==0);
end
    
% check y
if length(yres) == 1
    tfy = true;
else
    tfy = all(roundn(diff(yres,1),tol)==0);
end

tf = tfx == true && tfy == true;

