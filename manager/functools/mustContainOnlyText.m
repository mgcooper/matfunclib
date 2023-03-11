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