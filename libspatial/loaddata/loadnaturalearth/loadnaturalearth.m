function S = loadnaturalearth(varargin)
   %LOADNATURALEARTH general description of function
   %
   % Syntax
   %
   %  S = LOADNATURALEARTH()
   %  S = LOADNATURALEARTH(RiverName)
   %  S = LOADNATURALEARTH(_, 'latlims', latlims)
   %  S = LOADNATURALEARTH(_, 'lonlims', lonlims)
   %
   % Matt Cooper, 06-Dec-2022, https://github.com/mgcooper
   %
   % See also: loadhydrorivers

   % Parse inputs
   [river, latlims, lonlims] = parseinputs(mfilename, varargin{:});

   % Set path to naturalearth data
   pathdata = fullfile(getenv('USERDATAPATH'), 'naturalearth', '50m_physical');

   if ~isnan(latlims)
      S = shaperead(fullfile(pathdata, 'ne_50m_rivers_lake_centerlines.shp'), ...
         'UseGeoCoords', true);
      %Lat = [S(:).Lat];
      %Lon = [S(:).Lon];

      Lat = nan; Lon = nan;
      for n = 1:numel(S)
         lat = S(n).Lat;
         lon = S(n).Lon;
         idx = lat<latlims(2) & lat>latlims(1) & lon<lonlims(2) & lon>lonlims(1);
         Lat = [Lat lat(idx) nan];
         Lon = [Lon lon(idx) nan];
      end

      [Lon, Lat] = removeExtraNanSeparators(Lon,Lat);

      % note: inserting nan's didn't seem to work, try the method i used with the
      % polylinez read by m_shaperead in cell_fun:
      %latcells = cellfun(@(x)vertcat(x(:,2)),C,'Uni',0);
      %loncells = cellfun(@(x)vertcat(x(:,1)),C,'Uni',0);
      %[lat,lon] = polyjoin(latcells,loncells);

      % I also may just need:
      %[lat, lon] = closePolygonParts(lat, lon, angleunits)

      % I stopped here b/c the rivers are not as fine-grained as I thought so
      % clipping by region is not that relevant, easier to just load a major river.
      % but if i have a detailed rivers shapefile I could loop over all segments
      % and clip them and insert nan's between them.
   else
      S = shaperead(fullfile(pathdata,'ne_50m_rivers_lake_centerlines.shp'), ...
         'UseGeoCoords', true, 'Selector',{@(name) strcmpi(name,river), 'name'});
   end
end

%% Input Parser
function [river, latlims, lonlims] = parseinputs(mfilename, varargin)

   parser = inputParser;
   parser.FunctionName = mfilename;
   parser.CaseSensitive = false;
   parser.KeepUnmatched = true;

   validstrings = naturalearthrivers;
   validoption = @(x) any(validatestring(x, validstrings));

   parser.addOptional('river', 'Yukon', validoption);
   parser.addParameter('latlims', nan, @isnumeric);
   parser.addParameter('lonlims', nan, @isnumeric);
   parser.parse(varargin{:});

   river = parser.Results.river;
   latlims = parser.Results.latlims;
   lonlims = parser.Results.lonlims;
end
