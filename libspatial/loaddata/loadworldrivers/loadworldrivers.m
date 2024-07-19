function S = loadworldrivers(river,varargin)
   %LOADWORLDRIVERS Load world river shapefile.
   %
   % Syntax
   %
   %  S = LOADWORLDRIVERS(river) description
   %  S = LOADWORLDRIVERS(river, 'latlims', latlims, 'lonlims', lonlims)
   %
   % Matt Cooper, 06-Dec-2022, https://github.com/mgcooper
   %
   % See also

   % input parsing
   validstrings = worldriverlist;
   validoption = @(x)any(validatestring(x,validstrings));

   parser = inputParser();
   parser.FunctionName = mfilename;
   parser.CaseSensitive = false;
   parser.KeepUnmatched = true;
   parser.addOptional('river', 'Yukon', validoption);
   parser.addParameter('latlims', nan, @isnumeric);
   parser.addParameter('lonlims', nan, @isnumeric);
   parser.parse(river, varargin{:});
   river = parser.Results.river;
   latlims = parser.Results.latlims;
   lonlims = parser.Results.lonlims;

   if ~isnan(latlims)
      S = shaperead('worldrivers.shp', 'UseGeoCoords', true);
      Lat = [S(:).Lat];
      Lon = [S(:).Lon];
      % I stopped here b/c the rivers are not as fine-grained as I thought so
      % clipping by region is not that relevant, easier to just load a major
      % river. but if i have a detailed rivers shapefile I could loop over all
      % segments and clip them and insert nan's between them.
   else
      S = shaperead('worldrivers.shp', 'UseGeoCoords', true,...
         'Selector',{@(name) strcmpi(name,river), 'Name'});
   end
end
