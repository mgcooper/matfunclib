function Y = functemplate(X,varargin)
%FUNCNAME general description of function
% 
% Syntax
% 
%  Y = FUNCNAME(X) description
%  Y = FUNCNAME(X,'name1',value1) description
%  Y = FUNCNAME(X,'name1',value1,'name2',value2) description
%  Y = FUNCNAME(___,method). Options: 'flag1','flag2','flag3'.
%        The default method is 'flag1'. 
% 
% Example
%  
% 
% Matt Cooper, DD-MMM-YYYY, https://github.com/mgcooper
% 
% See also

%------------------------------------------------------------------------------
% input parsing
%------------------------------------------------------------------------------
p                 = magicParser;
p.FunctionName    = 'funcname';
p.CaseSensitive   = false;
p.KeepUnmatched   = true;  

% for backdoor default matlab options, use:
% varargs = namedargs2cell(p.Unmatched);
% then pass varargs{:} as the last argument. but for autocomplete, copy the
% json file arguments to the local one.

validstrings      = {''}; % or [""]
validoption       = @(x)any(validatestring(x,validstrings));

p.addRequired(    'X',                       @(x)isnumeric(x)     );
p.addOptional(    'option',      nan,        validoption          );
p.addParameter(   'namevalue',   false,      @(x)islogical(x)     );

p.parseMagically('caller');

% https://www.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html
%------------------------------------------------------------------------------














