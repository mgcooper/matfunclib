function borders = loadworldborders(bordername,varargin)
%LOADWORLDBORDERS loads borders for land area designated by bordername
% 
% Syntax
% 
%  borders = LOADWORLDBORDERS(bordername) loads borders for land area designated
%  by bordername
% 
% Example
% 
%  USA = loadworldborders('United States');
% 
% Matt Cooper, 05-Dec-2022, https://github.com/mgcooper
% 
% See also


%% input parsing

validstrings = {'none','merge'};
validoption = @(x)any(validatestring(x,validstrings));

parser = inputParser;
parser.FunctionName = mfilename;
parser.CaseSensitive = false;
parser.KeepUnmatched  = true;
parser.addRequired('bordername', @ischarlike);
parser.addOptional('option', 'none', validoption);
parser.parse(bordername, varargin{:});
option = parser.Results.option;


% convert bordername to cellstr 
if ischar(bordername) || isstring(bordername)
   bordername = cellstr(bordername);
end

load('world_borders.mat','borders'); all_borders = borders;

borders = all_borders(contains({all_borders.NAME},bordername));
borders = renamestructfields(borders,{'X','Y'},{'Lon','Lat'});

if option == "merge" && numel(borders)>1
   
   %b = geostructinit('Polygon',1);
   
   % use the first border as a template
   b = borders(1);
   
   % Lat/Lon for all borders (vectors end with nan so simple concatenation works)
   Lat = [borders(:).Lat];
   Lon = [borders(:).Lon];
   
   b.Lat = Lat;
   b.Lon = Lon;
   
   % combine all other fields
   fields = fieldnames(b);
   
   for n = 1:numel(fields)
      
      switch fields{n}
         case {'Geometry','BoundingBox','Lat','Lon'}
            continue
            
         case {'FIPS','ISO2','ISO3','NAME'}
            
            % this will be easier to see b/c we can do b.NAME(1)
            % b.(fields{n}) = string({borders.(fields{n})});
            
            % but I think this is needed to maintain shapefile format
            b.(fields{n}) = strjoin({borders.(fields{n})},',');
            
         case {'AREA','POP2005'}
            b.(fields{n}) = sum([borders.(fields{n})]);
           
         case {'LON','LAT'}
            b.(fields{n}) = num2str([borders.(fields{n})]);
            
         % STOPPED HERE not sure we need the others
         % case 
      end
      
   end
   
   % this updates the bounding box - not sure if it is working or not
   borders = updategeostruct(b);
   
end
