function tf = ischarlike(x)
%ISCHARLIKE return true if input X is a cellstr, char, or string array
% 
% Syntax
% 
%  tf = ISCHARLIKE(X) returns true if X is either a cellstr, string array, or
%  1xN character vector for N>=0, or the 0x0 char array ''.
% 
%  tf = ISCHARLIKE(X,FALSE) returns true only if S is a non-empty character
%  vector, cellstr, or string array. 
% 
% Example
%  
% 
% Matt Cooper, 29-Nov-2022, https://github.com/mgcooper
% 
% See also matlab.internal.datatypes.isCharString

% allowEmpty not implemented
% function tf = ischarlike(x, allowEmpty)

%------------------------------------------------------------------------------

% replaced with call to containsOnlyText which also deals with cells of string
% arrays e.g. iscellstr({"test"}) vs containsOnlyText({"test"})


% handle layered cells 
if iscell(x)
   tf = all(cellfun(@(x)ischarlike(x),x),'all');
else
   tf = containsOnlyText(x); 
   
   % tf = iscellstr(x) | ischar(x) | isstring(x) ;
end


% tf = ischar(x) || ...
%    isstring(x) || ...
%    iscell(x) && ( containsOnlyText( [x{:}] ) );

% % This is how the allowEmpty would work, might need to add it to
% containsOnlyText or maybe best to deal with it in this function
% 
% if nargin < 2 || allowEmpty
%     tf = ischar(s) && (isrow(s) || isequal(s,''));
% else
%     tf = ischar(s) && isrow(s) && ~all(isspace(s));
% end