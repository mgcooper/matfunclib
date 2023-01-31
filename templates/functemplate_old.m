function z = functemplate(x,y,nameval,option,ax,varargin)

%-------------------------------------------------------------------------------
p                 = magicParser;
p.FunctionName    = mfilename;
p.CaseSensitive   = false;
p.KeepUnmatched   = true;

validx         = @(x)validateattributes(x,{'numeric'},               ...
   {'real','column','size',size(y)},               ...
   'myfunc','x',1);
validy         = @(x)validateattributes(x,{'numeric'},               ...
   {'real','column','size',size(x)},               ...
   'myfunc','y',2);
validparameter = @(x)validateattributes(x,{'char','string'},         ...
   {'scalartext'},                                 ...
   'myfunc','namevalue');
validoption    = @(x)validateattributes(x,{'char','string'},         ...
   {'scalartext'},                                 ...
   'myfunc','opts');
validax        = @(x)validateattributes(x,                           ...
   {'matlab.graphics.axis.Axes'},{ 'scalar' },     ...
   'myfunc','ax');


p.addRequired(   'x',                           validx            );
p.addRequired(   'y',                           validy            );
p.addParameter(  'nameval',   false,            validparameter    );
p.addOptional(   'option',    nan,              validoption       );
p.addOptional(   'ax',        gca,              validax           );

%    % for rapid deployment (no 'valid' stuff):
%    p.addRequired(   'x',                     @(x)isnumeric(x)     );
%    p.addParameter(  'namevalue',    false,   @(x)islogical(x)     );
%    p.addOptional(   'option',       nan,     @(x)ischar(x)        );

p.parseMagically('caller');

% NOTE: careful with struct inputs - set p.StructExpand false for input
% structures treated as single inputs, default is true where name-value
% options are structure fields. Also, if using struct input with
% name-value parameters, see magicparserusage.xlsx for details on
% potential traps using optional inputs (tldr: default values get used
% when in fact you want the values you passed in to get used)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~