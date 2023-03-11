function tf = notempty(x)
%NOTEMPTY Determine whether array X contains any non-empty elements 
% 
%  TF = NOTEMPTY(X) returns true if ~all(isempty(X)) is true
% 
% Example
% 
% 
% Matt Cooper, 27-Oct-2022, https://github.com/mgcooper
% 
% See also any, isempty, notempty
tf = ~all(isempty(x));