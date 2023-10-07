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
   % Matt Cooper, 02-Dec-2022, https://github.com/mgcooper
   %
   % See also: loadlandarea

   % input parsing
   parser = inputParser();
   parser.FunctionName = mfilename;
   parser.CaseSensitive = false;
   parser.KeepUnmatched = true;
   parser.addRequired('statename', @ischarlike);
   parser.parse(statename);

   S = shaperead('usastatehi', 'UseGeoCoords', true,...
      'Selector',{@(name) strcmpi(name,statename), 'Name'});
end
