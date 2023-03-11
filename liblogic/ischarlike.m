function tf = ischarlike(x)
%ISCHARLIKE return true if input X is a cellstr, char, or string array
% 
% Syntax
% 
%  tf = ISCHARLIKE(X) returns true if X is either a cellstr, char, or string array
% 
% Example
%  
% 
% Matt Cooper, 29-Nov-2022, https://github.com/mgcooper
% 
% See also islist

%------------------------------------------------------------------------------

% handle layered cells 
if iscell(x)
   tf = all(cellfun(@(x)ischarlike(x),x),'all');
else
   tf = iscellstr(x) | ischar(x) | isstring(x) ;
end

% this was posted to fex, but I think containsOnlyText may just do exactly what
% iscellstr does already
% tf = ischar(x) || ...
%    isstring(x) || ...
%    iscell(x) && ( containsOnlyText( [x{:}] ) );