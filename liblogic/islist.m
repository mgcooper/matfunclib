function tf = islist(x)
%ISLIST return true if input X is a cellstr, char, or string array
% 
% Syntax
% 
%  tf = ISLIST(X) returns true if X is either a cellstr, char, or string array
% 
% Example
%  
% 
% Matt Cooper, 29-Nov-2022, https://github.com/mgcooper
% 
% See also

%------------------------------------------------------------------------------

tf = iscellstr(x) | ischar(x) | isstring(x) | ...
   (isstruct(x) && isfield(x,'name')) | ...
   (isstruct(x) && isfield(x,'folder'));











