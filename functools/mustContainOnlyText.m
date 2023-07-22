function mustContainOnlyText(arg)
%mustContainOnlyText validate that input contains only text
%   
% argument is char, string, or a cell array of strings
% Intended for use within arguments block to validate an input
%
% Example use in argument block validation:
% arguments 
%     thisarg    { mustContainOnlyText(thisarg) };
% end
% 
% See also: containsOnlyText, ischarlike

if ~containsOnlyText(arg)
   eid = 'custom:validators:mustContainOnlyText';
   msg = 'Value must be char, string array, or cell array of chars or strings.';
   throwAsCaller(MException(eid, msg));
end