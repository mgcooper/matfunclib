function [val,idx] = findnearest(X,target,varargin)
%FINDNEAREST general description of function
% 
%  Y = FINDNEAREST(X) description
%  Y = FINDNEAREST(X,'name1',value1) description
%  Y = FINDNEAREST(X,'name1',value1,'name2',value2) description
%  Y = FINDNEAREST(___,method). Options: 'flag1','flag2','flag3'.
%        The default method is 'flag1'. 
% 
% Example
%  
% 
% Matt Cooper, 16-Feb-2023, https://github.com/mgcooper
% 
% See also

%-------------------------------------------------------------------------------
% input parsing
%-------------------------------------------------------------------------------
p                 = magicParser;
p.FunctionName    = mfilename;
p.CaseSensitive   = false;
p.KeepUnmatched   = true;  

% for backdoor default matlab options, use:
% varargs = namedargs2cell(p.Unmatched);
% then pass varargs{:} as the last argument. but for autocomplete, copy the
% json file arguments to the local one.

% validstrings      = {''}; % or [""]
% validoption       = @(x)~isempty(validatestring(x,validstrings));
% 
p.addRequired(    'X',                 @(x)isnumeric(x) | isdatetime(x));
p.addRequired(    'target',            @(x)isnumeric(x) | isdatetime(x));
p.addOptional(    'n',        1,       @(x)isnumericscalar(x));
% p.addParameter(   'namevalue',   false,      @(x)islogical(x)     );

p.parseMagically('caller');

% https://www.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html
%-------------------------------------------------------------------------------


idx = find(min(abs(X-target))==abs(X-target),n,'first');
val = X(idx);











