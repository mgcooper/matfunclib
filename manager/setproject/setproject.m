function msg = setproject(cmd,varargin)
%SETPROJECT general description of function
% 
%  msg = SETPROJECT(cmd) description
%  msg = SETPROJECT(cmd,'name1',value1) description
%  msg = SETPROJECT(cmd,'name1',value1,'name2',value2) description
%  msg = SETPROJECT(___,method). Options: 'flag1','flag2','flag3'.
%        The default method is 'flag1'. 
% 
% Example
%  
% 
% Matt Cooper, 19-Jan-2023, https://github.com/mgcooper
% 
% See also


% SEE NOTE IN GETPROJECT

%-------------------------------------------------------------------------------
% input parsing
%-------------------------------------------------------------------------------
p                 = magicParser;
p.FunctionName    = 'setproject';
p.CaseSensitive   = false;
p.KeepUnmatched   = true;  

% for backdoor default matlab options, use:
% varargs = namedargs2cell(p.Unmatched);
% then pass varargs{:} as the last argument. but for autocomplete, copy the
% json file arguments to the local one.

validstrings      = {''}; % or [""]
validoption       = @(x)any(validatestring(x,validstrings));

p.addRequired(    'cmd',                       @(x)isnumeric(x)     );
p.addOptional(    'option',      nan,        validoption          );
p.addParameter(   'namevalue',   false,      @(x)islogical(x)     );

p.parseMagically('caller');

% https://www.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html
%-------------------------------------------------------------------------------














