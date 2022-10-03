function [Z,R] = functemplate(x,varargin)
%FUNCNAME general description of function
% 
% Syntax:
% 
%  [Z,R] = FUNCNAME(x);
%  [Z,R] = FUNCNAME(x,'name1',value1);
%  [Z,R] = FUNCNAME(x,'name1',value1,'name2',value2);
%  [Z,R] = FUNCNAME(___,method). Options: 'flag1','flag2','flag3'.
%        The default method is 'flag1'. 
% 
% Author: Matt Cooper, MMM-DD-YYYY, https://github.com/mgcooper

%------------------------------------------------------------------------------
% input parsing
%------------------------------------------------------------------------------
   p                 = inputParser;
   p.FunctionName    = 'funcname';
   
   addRequired(p,    'x',                    @(x)isnumeric(x)     );
   addParameter(p,   'namevalue',   false,   @(x)islogical(x)     );
   addOptional(p,    'option',      nan,     @(x)ischar(x)        );
   
   parse(p,x,varargin{:});
   
   namevalue = p.Results.namevalue;
   option = p.Results.option;
   
%------------------------------------------------------------------------------














