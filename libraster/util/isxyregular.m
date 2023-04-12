function [tf,tflatlon,tol] = isxyregular(x,y,varargin)
%ISXYREGULAR determine if the values in x and y are regularly spaced
%
%  TF = isxyregular(X,Y) returns a logical scalar TF that is true if the
%  distance between each element of X and each element of Y is constant up to
%  roundoff error. No check is made for distance between X and Y values.
%
%  [TF,TFLATLON,TOL] = isxyregular(X,Y) also returns a logical scalar TFLATLON
%  that is true if the data in X and Y are geographic coordinates, and a numeric
%  scalar TOL that represents the roundoff error used.
%
%  See also 

% % input checks not implemented yet
% if ~isreal(x) || ~isreal(y)
%    error(message('LIBRASTER:isxyregular:MustBeReal'));
% end
% 
% if isscalar(x) || isempty(x) || isscalar(y) || isempty(y)
%    tf = false;
%    return
% end
% 
% Note: I don't want this check because this function must work with grids, but
% it shows an example of how it is done for vectors.
%
% if ~isvector(x) || ~isvector(y)
%    error(message('LIBRASTER:isxyregular:MustBeVector'));
% end
% 
%step = NaN('like',x);

% check if the coordinates are lat lon or planar
tflatlon = islatlon(y,x);

% check that the gridding is uniform.
if nargin>2
    tol = varargin{1};
elseif tflatlon
    tol = 7; % approximately 1 cm in units of degrees
else
    tol = 2; % nearest cm
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
    tfx = all(round(diff(xres,1),tol)==0);
end
    
% check y
if length(yres) == 1
    tfy = true;
else
    tfy = all(round(diff(yres,1),tol)==0);
end

tf = tfx == true && tfy == true;


%% for reference, this is how isuniform does it

% maxElement = max(abs(x(1)),abs(x(end)));
% tol = 4*eps(maxElement);
% numSpaces = numel(x) - 1;
% span = x(end) - x(1);
% if isfinite(span)
%    mean_step = span/numSpaces;
% else
%    mean_step = x(end)/numSpaces - x(1)/numSpaces;
% end
% 
% stepAbs = abs(mean_step);
% if stepAbs < tol
%    % Special cases for very small step sizes
%    if stepAbs < eps(maxElement)
%       % Avoid having a tolerance that is tighter then round-off error
%       tol = eps(maxElement);
%    else
%       tol = stepAbs;
%    end
% end
% 
% tf = all(abs(diff(x) - mean_step) <= tol);
% 
% if ~tf && numel(x) == 2 && allfinite(x)
%    % Correctly handle finite data causing the mean step to overflow
%    tf = true;
%    if nargout == 2
%       error(message('MATLAB:isuniform:StepTooLarge'));
%    end
% end
% 
% if tf
%    step = mean_step;
% end
