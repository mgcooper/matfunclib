function mustContainOnlyText(arg)
%mustContainOnlyText validates that input contains only text
%   argument is char, string, or a cell array of strings
%   Intended for use within arguments block to validate an input

% mgc this would be used in argument block validation in the manner i use
% ischarlike, eg:
% arguments
% 
%     thisarg    { mustContainOnlyText(thisarg) };
% 
% end

if ~containsOnlyText(arg)
   eid = 'custom:validators:mustContainOnlyText';
   msg = 'Value must be char, string array, or cell array of chars or strings.';
   throwAsCaller(MException(eid, msg));
end

end

function tf = containsOnlyText(x)
%containsOnlyText return true if input x contains only text
% 
%  tf = containsOnlyText(x) returns true if x is a char, string, or cell array
%  of chars or strings, otherwise returns false.
% 
% "text" means char, string, or cell array of chars or strings
% "contains" means text by itself, or text contained within an array or cell
% 
% See also mustContainOnlyText ischarlike

% NOTE: this is only needed because mustBeText doesn't check for cell arrays of
% strings (which i think is b/c iscellstr doesn't perform that check).

%Removes outer cell layer and recurses if the passed text is in a cell array
%Text passed to next version is horizontally concatenated version
tf = ischar(x) || ...
   isstring(x) || ...
   iscell(x) && ( containsOnlyText( [x{:}] ) ); %If there are layered cells
end
