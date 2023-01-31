function tf = allnan(x)
%ALLNAN logical check if all element of array are NaN.
% 
%  tf = allnan(x)
% 
% See also notnan, nonenan, notempty 
tf = all(isnan(x));