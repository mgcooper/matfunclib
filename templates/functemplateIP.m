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
p                 = inputParser;
p.FunctionName    = 'funcname';

validstrings      = {''}; % or [""]
validoption       = @(x)any(validatestring(x,validstrings));

p.addRequired(    'X',                       @(x)isnumeric(x)     );
p.addOptional(    'option',      nan,        validoption          );
p.addParameter(   'namevalue',   false,      @(x)islogical(x)     );

parse(p,X,varargin{:});

option      = p.Results.option;
namevalue   = p.Results.namevalue;
   
% https://www.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html
%------------------------------------------------------------------------------














