function tf = anynan(x)
%ANYNAN logical check if all element of array are NaN.
% 
%  tf = anynan(x)
% 
% See also notnan, nonenan, notempty, allnan
tf = any(isnan(x));