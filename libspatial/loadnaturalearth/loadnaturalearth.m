function S = loadnaturalearth(river,varargin)
%LOADNATURALEARTH general description of function
% 
% Syntax
% 
%  Y = LOADNATURALEARTH(X) description
%  Y = LOADNATURALEARTH(X,'name1',value1) description
%  Y = LOADNATURALEARTH(X,'name1',value1,'name2',value2) description
%  Y = LOADNATURALEARTH(___,method). Options: 'flag1','flag2','flag3'.
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

validstrings      = naturalearthrivers;
validoption       = @(x)any(validatestring(x,validstrings));

p.addOptional(    'river',    'Yukon',    validoption          );
p.addParameter(   'latlims',   nan,       @(x)isnumeric(x)     );
p.addParameter(   'lonlims',   nan,       @(x)isnumeric(x)     );

p.parseMagically('caller');

% https://www.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html
%------------------------------------------------------------------------------

pathdata = fullfile(getenv('USERDATAPATH'),'naturalearth');

if ~isnan(latlims)
   S = shaperead(fullfile(pathdata,'ne_50m_rivers_lake_centerlines.shp'),'UseGeoCoords', true);
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
   
   [Lon,Lat] = removeExtraNanSeparators(Lon,Lat);
   
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









