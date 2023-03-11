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
p.FunctionName    = mfilename;
p.CaseSensitive   = false;
p.KeepUnmatched   = true;

p.addRequired(   'X',                  @(x)isnumeric(x));
p.addOptional(   'option',    nan,     @(x)any(validatestring(x,validstrings)));
p.addParameter(  'namevalue', false,   @(x)islogical(x)     );

p.parseMagically('caller');

% https://www.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html
%------------------------------------------------------------------------------














