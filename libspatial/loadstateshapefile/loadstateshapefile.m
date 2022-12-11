function S = loadstateshapefile(statename)
%LOADSTATESHAPEFILE load shapefile of US state
% 
% Syntax
% 
%  S = LOADSTATESHAPEFILE(statename) description
%  S = LOADSTATESHAPEFILE(statename,'name1',value1) description
%  S = LOADSTATESHAPEFILE(statename,'name1',value1,'name2',value2) description
%  S = LOADSTATESHAPEFILE(___,method). Options: 'flag1','flag2','flag3'.
%        The default method is 'flag1'. 
% 
% Example
%  
% 
% Matt Cooper, 02-Dec-2022, https://github.com/mgcooper
% 
% See also

%------------------------------------------------------------------------------
% input parsing
%------------------------------------------------------------------------------
p                 = magicParser;
p.FunctionName    = 'loadstateshapefile';
p.CaseSensitive   = false;
p.KeepUnmatched   = true;

% validstrings      = {''}; % or [""]
% validoption       = @(x)any(validatestring(x,validstrings));

p.addRequired(    'statename',               @(x)ischarlike(x)    );
% p.addOptional(    'option',      nan,        validoption          );
% p.addParameter(   'namevalue',   false,      @(x)islogical(x)     );

p.parseMagically('caller');

% https://www.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html
%------------------------------------------------------------------------------

S = shaperead('usastatehi', 'UseGeoCoords', true,...
            'Selector',{@(name) strcmpi(name,statename), 'Name'});












