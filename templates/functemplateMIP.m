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
   p                 = MipInputParser;
   p.FunctionName    = 'funcname';
   p.CaseSensitive   = false;
   p.KeepUnmatched   = true;

   p.addRequired(   'x',                     @(x)isnumeric(x)     );
   p.addParameter(  'namevalue',    false,   @(x)islogical(x)     );
   p.addOptional(   'option',       nan,     @(x)ischar(x)        );
   
   p.parseMagically('caller');
   
%------------------------------------------------------------------------------













