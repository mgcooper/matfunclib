function tf = ischarlike(x, varargin)
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
% Examples
%  ischarlike({"test"})
%  ischarlike({"test", 1})
%  ischarlike({"test", 1}, 'all')
%  ischarlike({"test", 1}, 'any')
%  ischarlike({2, 1}, 'any')
%  ischarlike({"test1", "test2", 1})
%  ischarlike(["test1", "test2", 1])
%  ischarlike(["test1", "test2", 1], 'any')
%  ischarlike(["test1", "test2", 1], 'all') % true because [] converts 1 to "1"
%  ischarlike("test1")
%  ischarlike(cat(1,'test1','test2')) % 
%  ischarlike(cat(1,'test1','test2')) % currently returns false b/c not row char
% 
% nontrival option:
%  ischarlike('')                               % true
%  ischarlike('','nontrivial')                  % false
%  ischarlike("",'nontrivial')                  % true
%  ischarlike(string.empty,'nontrivial')        % true
%  ischarlike({},'nontrivial')                  % true
%  ischarlike({''},'nontrivial')                % false
%  ischarlike({'', ""},'nontrivial')            % false
%  ischarlike({'', ""},'each','nontrivial')     % false, true
%  ischarlike({'', ""},'any','nontrivial')      % true
% 
% Matt Cooper, 29-Nov-2022, https://github.com/mgcooper
% 
% See also: matlab.internal.datatypes.isCharString, isStringScalar

% allowEmpty not implemented
% function tf = ischarlike(x, allowEmpty)

%------------------------------------------------------------------------------

% replaced with call to containsOnlyText which also deals with cells of string
% arrays e.g. iscellstr({"test"}) vs containsOnlyText({"test"})
% ischarlike({"test"})

[opt, args, nargs] = parseoptarg(varargin, {'all', 'any', 'each'}, 'all');

if nargs > 0 && strcmpi(args{1}, 'nontrivial')
   hastext = @(x) all(strlength(x)>0, 'all');
else
   hastext = @(x) true;
end

% handle layered cells by passing 'all' to the second argument of ischarlike
if iscell(x)
   if strcmp(opt, 'all')
      tf = all(cellfun(@(arg) ischarlike(arg, 'all', args{:}), x));
   elseif strcmp(opt, 'any')
      tf = any(cellfun(@(arg) ischarlike(arg, 'all', args{:}), x));
   elseif strcmp(opt, 'each')
      tf = cellfun(@(arg) ischarlike(arg, 'all', args{:}), x);
   end
else
   tf = iscellstr(x) || isstring(x) || ...
      ( ischar(x) && (isrow(x) || isequal(x,'')) ) && hastext(x);
end

% Note: this is from containsOnlyText, and I found unexpected behavior, e.g. 
% x = {1, 'test', "test"}
% containsOnlyText( [test{:}] )
% ans =
%   logical
%    1
% 
% This occurs b/c the concatenation step converts the double 1 to a string:
% [test{:}]
% 
% ans = 
%   1×3 string array
%     "1"    "test"    "test"
    
% 
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