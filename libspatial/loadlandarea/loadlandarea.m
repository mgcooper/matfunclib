function S = loadlandarea(landarea,varargin)
   %LOADLANDAREA load global land area shapefile
   %
   % Syntax
   %
   %  S = LOADLANDAREA(landarea) Loads a shapefile for the landarea into memory.
   %
   % Examples
   %
   %  S = loadlandarea('Antarctica');
   %
   % Matt Cooper, 05-Dec-2022, https://github.com/mgcooper
   %
   % See also loadstateshapefile

   parser = inputParser();
   parser.FunctionName = mfilename;
   parser.CaseSensitive = false;
   parser.KeepUnmatched = true;
   parser.addRequired('landarea', @ischarlike);
   parser.parse(landarea);

   S = shaperead('landareas.shp', 'UseGeoCoords', true,...
      'Selector',{@(name) strcmpi(name,landarea), 'Name'});
end
