function S = loadworldrivers(river,varargin)
%LOADWORLDRIVERS load world river shapefile
% 
% Syntax
% 
%  S = LOADWORLDRIVERS(river) description
%  S = LOADWORLDRIVERS(river,'name1',value1) description
%  S = LOADWORLDRIVERS(X,'name1',value1,'name2',value2) description
%  S = LOADWORLDRIVERS(___,method). Options: 'flag1','flag2','flag3'.
%        The default method is 'flag1'. 
% 
% Example
%  
% 
% Matt Cooper, 06-Dec-2022, https://github.com/mgcooper
% 
% See also

%------------------------------------------------------------------------------
% input parsing
%------------------------------------------------------------------------------
p                 = magicParser;
p.FunctionName    = mfilename;
p.CaseSensitive   = false;
p.KeepUnmatched   = true;

validstrings      = worldriverlist;
validoption       = @(x)any(validatestring(x,validstrings));

p.addOptional(    'river',    'Yukon',    validoption          );
p.addParameter(   'latlims',   nan,       @(x)isnumeric(x)     );
p.addParameter(   'lonlims',   nan,       @(x)isnumeric(x)     );

p.parseMagically('caller');

% https://www.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html
%------------------------------------------------------------------------------

if ~isnan(latlims)
   S = shaperead('worldrivers.shp', 'UseGeoCoords', true);
   Lat = [S(:).Lat];
   Lon = [S(:).Lon];
   % I stopped here b/c the rivers are not as fine-grained as I thought so
   % clipping by region is not that relevant, easier to just load a major river.
   % but if i have a detailed rivers shapefile I could loop over all segments
   % and clip them and insert nan's between them.
else
   S = shaperead('worldrivers.shp', 'UseGeoCoords', true,...
               'Selector',{@(name) strcmpi(name,river), 'Name'});
end












