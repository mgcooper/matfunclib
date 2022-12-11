function varargout = loadhydrorivers(varargin)
%LOADHYDRORIVERS general description of function
% 
% Syntax
% 
%  S = LOADHYDRORIVERS(X) description
%  S = LOADHYDRORIVERS(X,'name1',value1) description
%  S = LOADHYDRORIVERS(X,'name1',value1,'name2',value2) description
%  S = LOADHYDRORIVERS(___,method). Options: 'flag1','flag2','flag3'.
%        The default method is 'flag1'. 
% 
% Example
%  
% 
% Matt Cooper, 08-Dec-2022, https://github.com/mgcooper
% 
% See also

%------------------------------------------------------------------------------
% input parsing
%------------------------------------------------------------------------------
p                 = magicParser;
p.FunctionName    = 'loadhydrorivers';
p.CaseSensitive   = false;
p.KeepUnmatched   = true;  

% for backdoor default matlab options, use:
% varargs = namedargs2cell(p.Unmatched);
% then pass varargs{:} as the last argument. but for autocomplete, copy the
% json file arguments to the local one.

validregions = {'Global','Africa','Arctic','Asia','Australasia','Europe', ...
   'Greenland','NorthAmerica','SouthAmerica','Siberia'};
validoption = @(x)any(validatestring(x,validregions));

p.addOptional(    'Region',         'Global',   validoption                   );
p.addParameter(   'BoundingBox',    nan,        @(x)isnumeric(x)              );
p.addParameter(   'ClipGeometry',   nan,        @(x)isstruct(x)|isnumeric(x)  );
p.addParameter(   'ClipFile',       nan,        @(x)ischarlike(x)             );
p.addParameter(   'latlims',        nan,        @(x)isnumeric(x)              );
p.addParameter(   'lonlims',        nan,        @(x)isnumeric(x)              );
p.addParameter(   'savefile',       nan,        @(x)islogical(x)              );

p.parseMagically('caller');

% https://www.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html
%------------------------------------------------------------------------------

% convert BoundingBox from [lonmin,latmin;lonmax,latmax] ([xmin,ymin;xmax,ymax]
% for map coordinates) to latlim/lonlim format for ingeoquad:
% latlim is a vector of the form [southern-limit northern-limit]
% lonlim is a vector of the form [western-limit eastern-limit].
if ~isscalarnan(BoundingBox)
   latlims = [BoundingBox(1,2) BoundingBox(2,2)];
   lonlims = [BoundingBox(1,1) BoundingBox(2,1)];
end
% note: to go the other way: BoundingBox = [lonlims' latlims'];

if ~isscalarnan(ClipGeometry) %#ok<*NODEF>
   if isstruct(ClipGeometry)
      % for a scalar struct, which it should be for clipping geometry, this
      % shoudl work, but for non-scalar, will need brackets
      if isscalar(ClipGeometry)
         ClipGeometry = [ClipGeometry.Lon(:) ClipGeometry.Lat(:)];
         ClipGeometry = rmnan(ClipGeometry,1);
      else
         ClipGeometry = [ [ClipGeometry.Lon] [ClipGeometry.Lat] ];
         ClipGeometry = rmnan(ClipGeometry,1);
      end
      latlims = [min(ClipGeometry(:,2)) max(ClipGeometry(:,2))];
      lonlims = [min(ClipGeometry(:,1)) max(ClipGeometry(:,1))];
   elseif ismatrix(ClipGeometry) && size(ClipGeometry,2) == 2
      poly = polyshape(ClipGeometry(:,1),ClipGeometry(:,2));
   end
end


% to get the original HydroSheds shapefile, use 'shp'. to get the cell array of
% lat/lon cells for indexing and loading the data, use 'mat'
fname = gethydroshedsfname(Region,validregions,'mat');
load(fname,'latc','lonc');

%% below works for latlims/lonlims
fnc1 = @(x,y) transpose(ingeoquad(x.',y.',latlims,lonlims));
fnc2 = @(x,y) vertcat(x(y));

keep = cellfun(fnc1,latc,lonc,'Uni',0);
latc = latc(~cellfun(@isempty,cellfun(fnc2,latc,keep,'Uni',0)));
lonc = lonc(~cellfun(@isempty,cellfun(fnc2,lonc,keep,'Uni',0)));

% if ClipGeometry is provided, apply it here
if ~isscalarnan(ClipGeometry)
   fnc1 = @(x,y) transpose(inpoly([x.',y.'],ClipGeometry));
   keep = cellfun(fnc1,lonc,latc,'Uni',0);
   latc = latc(~cellfun(@isempty,cellfun(fnc2,latc,keep,'Uni',0)));
   lonc = lonc(~cellfun(@isempty,cellfun(fnc2,lonc,keep,'Uni',0)));
end

% check it:
% [lat,lon] = polyjoin(latc,lonc);
% figure; worldmap([min(lat) max(lat)],[min(lon),max(lon)]);
% plotm(lat,lon);

% cellfun fnc1 [x.' y.'] should be doing this:
% [lonc{1}.' latc{1}.'];

% output as geostruct if requested
switch nargout
   case 1
      S = geostructinit('Line',numel(latc));
      [S(1:numel(lonc)).Lon] = lonc{:};
      [S(1:numel(latc)).Lat] = latc{:};
      S = updategeostruct(S); % get the bounding box of each element
      S = orderfields(S,{'Geometry','BoundingBox','Lon','Lat'});
      varargout{1} = S;
   case 2
      
%       [lat,lon] = polyjoin( ...
%          latc(~cellfun(@isempty, ...
%          cellfun(fnc2,latc, ...
%          cellfun(fnc1,latc,lonc,'Uni',0),'Uni',0))), ...
%          lonc(~cellfun(@isempty, ...
%          cellfun(fnc2,lonc, ...
%          cellfun(fnc1,latc,lonc,'Uni',0),'Uni',0))));

      [lat,lon] = polyjoin(latc,lonc);
      varargout{1} = lat;
      varargout{2} = lon;
end




function fname = gethydroshedsfname(Region,validregions,ftype)

suffixes = {'','_af','_ar','_as','_au','_eu','_gr','_na','_sa','_si'};
basename = 'HydroRIVERS_v10';
fname = strcat(basename,char(suffixes(ismember(validregions,Region))),'.',ftype);
fname = fullfile(getenv('USERDATAPATH'),['hydrosheds/' fname]);

% % no need for switch anymore b/c I use the same filename prefix for the latlon
% cells saved as .mat files
% switch ftype
%    case 'mat'
%       % this returns the saved lat/lon cell lists
%       basename = 'hydroriversLatLonCells';
%    case 'shp'
%       % this returns the actual hydrosheds shapefile name
%       basename = 'HydroRIVERS_v10';
% end





% %% this is a test that uses inpoly in place of ingeoquad

% % the test seemed to fail but maybe i did something wrong, moving on because I
% % think it makes more sense to first clip to the bbox then the geometry
% 
% % notice the order of lat,lon is switched
% fnc1 = @(x,y) transpose(inpoly([x.',y.'],[lonlims(:),latlims(:)]));
% fnc2 = @(x,y) vertcat(x(y));
% keep = cellfun(fnc1,lonc,latc,'Uni',0);
% latc = latc(~cellfun(@isempty,cellfun(fnc2,latc,keep,'Uni',0)));
% lonc = lonc(~cellfun(@isempty,cellfun(fnc2,lonc,keep,'Uni',0)));
% [lat,lon] = polyjoin(latc,lonc);
% figure; worldmap([min(lat) max(lat)],[min(lon),max(lon)]);
% plotm(lat,lon);








