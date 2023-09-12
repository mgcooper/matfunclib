% Set x=3, y=1 missing.
coords = [
   4, 2
   5, 2
   5, 3
   6, 3] ;

% Create coordinate pairs, gridvecs, and fullgrids
xcoords = coords(:, 1);
ycoords = coords(:, 2);
[xvec, yvec] = gridvec(xcoords, ycoords);
[xgrid, ygrid] = fullgrid(xvec, yvec);

% xvec =
%      4     5     6
%      
% yvec =
%      3
%      2
%      
% xgrid =
%      4     5     6
%      4     5     6
%
% ygrid =
%      3     3     3
%      2     2     2
% 
% The missing coordinates are 4,3 and 6,2 so the fullgrid result should be:
% 
%   2×3 logical array
%    0   1   1
%    1   1   0
% 
% What should the gridvector representation be? 
% To represent 4, 3:
%    0   1   1
%    1   1   1 
%
% In xgrid-vector format:
%    0   1   1
% In ygrid-vector format:
%    0
%    1
% 
% To represent 6, 2:
%    1   1   1
%    1   1   0 
%
% In xgrid-vector format:
%    1   1   0
% In ygrid-vector format:
%    1
%    0
% 
% So to represent grid vectors, either need to send back one grid-vector pair
% per missing pixel, requireing cell arrays and defeating the
% compact-representation purpose of grid vectors, or stipulate that gridvector
% output means if any pixel is missing in the respective row/column. 
% 
% Clearly, linear indices would be better. 

% LI2X
% LI2Y
% LOC2X
% LOC2Y
      

[LI2, LOC1, LI1, LOC2] = gridmember( xgrid, ygrid, xcoords, ycoords);

% Expected result:
%   2×3 logical array
%    0   1   1
%    1   1   0

% The linear indices of the member pixels on X2, Y2 can be found easily:
% find(LI2)

% The second output of gridmember returns them on the input grids, which is
% typically more useful:
% Note, gridmember calls fullgrid which sorts the data, so this does not recover
% the inputs:
[xcoords ycoords]
[xcoords(LOC1(LOC1>0)) ycoords(LOC1(LOC1>0))]
% this is not meaningful, because xgrid = X2
% [xgrid(LOC1(LOC1>0)) ygrid(LOC1(LOC1>0))]

% This recovers the values on the fullgrid that also exist on the sparse grid
[xcoords ycoords]
[xgrid(LOC2) ygrid(LOC2)]


% As of now, this is returning true for rows/columns with ALL values true.
[returnedValueX, returnedValueY] = gridmember( xvec, yvec, xcoords, ycoords);


