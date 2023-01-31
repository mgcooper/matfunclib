function S = loadlandarea(landarea,varargin)
%LOADLANDAREA load global land area shapefile
% 
% Syntax
% 
%  S = LOADLANDAREA(landarea) description
%  S = LOADLANDAREA(landarea,'name1',value1) description
%  S = LOADLANDAREA(landarea,'name1',value1,'name2',value2) description
% 
% Examples
% 
%  S = loadlandarea('Antarctica');
% 
% Matt Cooper, 05-Dec-2022, https://github.com/mgcooper
% 
% See also loadstateshapefile

%------------------------------------------------------------------------------
% input parsing
%------------------------------------------------------------------------------
p                 = magicParser;
p.FunctionName    = mfilename;
p.CaseSensitive   = false;
p.KeepUnmatched   = true;

% validstrings      = {''}; % or [""]
% validoption       = @(x)any(validatestring(x,validstrings));

p.addRequired(    'landarea',               @(x)ischarlike(x)    );

% p.addOptional(    'option',      nan,        validoption          );
% p.addParameter(   'namevalue',   false,      @(x)islogical(x)     );

p.parseMagically('caller');

% https://www.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html
%------------------------------------------------------------------------------

S = shaperead('landareas.shp', 'UseGeoCoords', true,...
            'Selector',{@(name) strcmpi(name,landarea), 'Name'});












