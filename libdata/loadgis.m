function [S,A] = loadgis(fname,varargin)
%LOADGIS loads gis data saved in USERGISPATH
% 
%  Data = LOADGIS(fname);
% 
% Matt Cooper, 07-Jul-2020, https://github.com/mgcooper
% 
% See also: gisfilelist, loaddata

% NOTE: I probably need to have one function for loadshapefile and one for
% loadraster to have [S,A] and [Z,R] outputs.

%------------------------------------------------------------------------------
% input parsing
%------------------------------------------------------------------------------
p                 = magicParser;
p.FunctionName    = 'loadgis';
p.KeepUnmatched   = true;

validstrings      = getgisfilelist;
validfilename     = @(x)any(validatestring(x,validstrings));

addRequired(p,    'fname',                   validfilename        );
addParameter(p,   'UseGeoCoords',   true,    @(x) islogical(x)    ); 
addParameter(p,   'Selector',       {},      @(x) iscell(x)       ); 
addParameter(p,   'Attributes',     {},      @(x) iscell(x)       ); 
addParameter(p,   'BoundingBox',    [],      @(x) isnumeric(x)    ); 

p.parseMagically('caller');

% this is how matlab validates filenames:
% validateattributes(filename, {'char'},{'vector'},mfilename,'FILENAME',1);

% UPDATE: I think namedargs2cell is what I need
% I thought I could pass arbitrary name-value pairs and use this to get them,
% but only the values are stored, not the names, so e.g. in this call:
% loadgis(fname,'UseGeoCoords',true)
% opts is a cell with one value 'true', not 'UseGeoCoords',true
% opts  = struct2cell(p.Unmatched);
% So for now, I use varargin

% https://www.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html
%------------------------------------------------------------------------------

namedargs = parser2varargin(p,'notusingdefaults',{'fname'});

addpath(genpath(getenv('USERGISPATH')));
fname = which(fname);
[~,~,ext] = fileparts(fname);

switch ext
   case '.shp'
      [S,A] = tryshaperead(fname,namedargs);
   case '.tif'
      try
         S = readgeoraster(fname,varargin{:});
      catch ME
      end
end

function [S,A] = tryshaperead(fname,namedargs);

ok = false;
try
   [S,A] = shaperead(fname,namedargs{:});
catch ME
   
   if strcmp(ME.message,'Unsupported shape type PolyLineZ (type code = 13).')
      
      % try m_map/m_shaperead. note: m_shaperead argument UBR (User Bounding
      % Rectangle) assumes format [minX  minY  maxX maxY] whereas shaperead
      % BoundingBox is [minX  minY ; maxX maxY]. do the conversion if needed.
      warning('Requested shapefile is type PolyLineZ. Using m_shaperead.')
      try
         if ismember({'BoundingBox'},namedargs(1:2:end)) % elements 1:2:end are parameters
            B = namedargs{find(ismember('BoundingBox',namedargs(1:2:end)))+1};
            S = m_shaperead(strrep(fname,'.shp',''),[B(1,:),B(2,:)]);
         else
            S = m_shaperead(strrep(fname,'.shp',''));
         end
         ok = true;
      catch ME2
         rethrow(ME2) % throw the error (revisit)
      end
   end
end

if ok
   % the Data produced by m_shaperead may need to be wrangled to a ueseable
   % format. return to this later. for now, convert the attributes to A and the
   % lat,lon to S
   Aok = false;
   try
      A = struct2table(S.dbf); % attribute table
      Aok = true;
   catch
   end
   
   % note: make sure the lat,lon values that go into elements of S are row vectors
   try
      lat = cellfun(@transpose,cellfun(@(x)vertcat(x(:,2)),S.ncst,'Uni',0),'Uni',0);
      lon = cellfun(@transpose,cellfun(@(x)vertcat(x(:,1)),S.ncst,'Uni',0),'Uni',0);
      
      % above returns latlon in cell array format, suitable for geostruct-type
      % objects and plotting with geoshow. below converts to nan-separated
      % lists, suitable for axesm-based functions like plotm.
      
      % activate this and add it to output for axesm-based compatibility.
      % [lat,lon] = polyjoin(lat,lon);
      
      switch S.ctype
         case 'polylineZ'
            T = geostructinit('Line',numel(lat),'fieldnames',S.fieldnames);
            [T(1:numel(lon)).Lon] = lon{:};
            [T(1:numel(lat)).Lat] = lat{:};
            T = updategeostruct(T); % get the bounding box of each element
            T = struct2table(T); % for movevars

            if Aok % we have an attribute table, join it with S
               fields = S.fieldnames;
               for n = 1:numel(fields)
                  T.(fields{n}) = A.(fields{n});
               end
            end
            
            % back to geostruct
            T = table2struct(movevars(T,'BoundingBox','After','Geometry'));
      end
      S = T; % send back the geostruct (overwrite m_shapefile S)
   catch
   end
   
end

% copied this here for matlab answers and changed mip to ip so keeping for now
function S = geostructinit(geometry,numfeatures,varargin);
%geostructinit initializes a geostructure S of size 1xnumfeatures
% 
%  Syntax
% 
%  S = geostructinit(geometry,numfeatures); 
%  Creates a geostruct S of size(1,numfeatures) and specified geometry
%  'line','point', or 'polygon'.
% 
%  S = geostructinit(geometry,numfeatures,'fieldnames',fieldnames);
%  Creates a geostruct S of size(1,numfeatures) and specified geometry
%  'line','point', or 'polygon' and fields specified by 'fieldnames'
%  name-value input.
% 
%  Author: Matt Cooper, Sep-23-2022, https://github.com/mgcooper
%--------------------------------------------------------------------------
p                 = inputParser;
p.FunctionName    = 'geostructinit';
p.addRequired(   'geometry',              @(x)ischar(x)           );
p.addRequired(   'numfeatures',           @(x)isnumeric(x)        );
p.addParameter(  'fieldnames',   '',      @(x)ischar(x)|iscell(x) );

p.parse(geometry,numfeatures,varargin{:});

geometry    = p.Results.geometry;
numfeatures = p.Results.numfeatures;
fieldnames  = p.Results.fieldnames;
%--------------------------------------------------------------------------

% make sure the geometry is capitalized
geometry(1) = upper(geometry(1));

% init a geo struct
[S(1:numfeatures).Geometry]  = deal(geometry);
[S(1:numfeatures).Lon]       = deal(nan);
[S(1:numfeatures).Lat]       = deal(nan);

for n = 1:numel(fieldnames)
   [S(1:numfeatures).(fieldnames{n})] = deal(nan);
end


% I want a method to figure out which name-values are using defaults and then
% NOT pass those to the nested function. 


% in shaperead.m, a custom parseInputs function is used (not inputParser), which
% first initializes these as follows, therefore I should be able to use these as
% defualt values for this and any other function that calls shaperead.
% recordNumbers = [];
% boundingBox = [];
% selector = [];
% attributes = [];
% useGeoCoords = false;


% % this was the previous method which assumed all files were in the top-level
% USERGISPATH. To find full paths to subfolders, I added the addpath statement
% above and use which.

% % this is the root path of all gis files
% datapath = getenv('USERGISPATH');
% 
% [~,~,ext] = fileparts(fname);
% 
% switch ext
%    case '.shp'
%       try 
%          Data = shaperead(fullfile(datapath,fname),varargin{:});
%       catch ME
%       end
%    case '.tif'
%       Data = readgeoraster(fullfile(datapath,fname),varargin{:});
% end














