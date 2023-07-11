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
p.FunctionName    = mfilename;
p.KeepUnmatched   = true;

% if we do this, then only files returned by getgisfilelist will work, and since
% fname is required, I don't think we need to be strict like we would with
% addOptional
% validstrings      = getgisfilelist;
% validfilename     = @(x)any(validatestring(x,validstrings));
validfilename = @(x)ischarlike(x);
validreader = @(x)any(validatestring(x,{'shaperead','m_map'}));

addRequired(p,    'fname',                         validfilename     );
addOptional(p,    'reader',         'shaperead',   validreader       );
addParameter(p,   'UseGeoCoords',   true,          @(x) islogical(x)    );
addParameter(p,   'Selector',       {},            @(x) iscell(x)       );
addParameter(p,   'Attributes',     {},            @(x) iscell(x)       );
addParameter(p,   'BoundingBox',    [],            @(x) isnumeric(x)    );

% p.parse(fname,varargin{:});
p.parseMagically('caller');

% this is how matlab validates filenames:
% validateattributes(filename,{'char'},{'vector'},mfilename,'FILENAME',1);

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

% if fname is not already on the path and/or is not a full-path filename, try to
% find the file in the USERGISPATH
if ~isfile(fname)
   fname = findgisfile(fname);
end
[~,~,ext] = fileparts(fname);

switch ext
   case '.shp'
      [S,A] = tryshaperead(fname,namedargs,reader);
   case '.tif'
      try
         S = readgeoraster(fname,varargin{:});
      catch ME
      end
end



function [S,A] = tryshaperead(fname,namedargs,reader)

if reader == "m_map"
   S = m_map_shaperead(fname,namedargs);
   ok = true;
else
   ok = false;
   try
      [S,A] = shaperead(fname,namedargs{:});
      % March 2023, added merge, but it will go to the A section and I think its
      % designed only for m_map, so instead I join the attributes with S here
      % but probably won't work for all geometries
      % ok = true;
      S = mergestructs(S,A);
      
   catch ME

      if strcmp(ME.identifier,'MATLAB:license:checkouterror')
         warning('Mapping Toolbox checkout error. Using m_shaperead.')
      end
      
      if strcmp(ME.message,'Unsupported shape type PolyLineZ (type code = 13).')
         % try m_map/m_shaperead. note: m_shaperead argument UBR (User Bounding
         % Rectangle) assumes format [minX  minY  maxX maxY] whereas shaperead
         % BoundingBox is [minX  minY ; maxX maxY]. do the conversion if needed.
         warning('Requested shapefile is type PolyLineZ. Using m_shaperead.')
      end
      
      try
         S = m_map_shaperead(fname,namedargs);
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
      %       % if S is scalar (one point, line, polyline, or polygon)
      %       isscalarstruct = false;
      %       if numel(S.ncst) == 1 && numel(S.dbf) == 1
      %          lat = S.ncst{1}(:,2);
      %          lon = S.ncst{1}(:,1);
      %          isscalarstruct = true;
      %       else
      %          % non-scalar
      %          lat = cellfun(@transpose,cellfun(@(x)vertcat(x(:,2)),S.ncst,'Uni',0),'Uni',0);
      %          lon = cellfun(@transpose,cellfun(@(x)vertcat(x(:,1)),S.ncst,'Uni',0),'Uni',0);
      %       end

      lat = cellfun(@transpose,cellfun(@(x)vertcat(x(:,2)),S.ncst,'Uni',0),'Uni',0);
      lon = cellfun(@transpose,cellfun(@(x)vertcat(x(:,1)),S.ncst,'Uni',0),'Uni',0);

      % for non-scalar, above returns latlon in cell array format, suitable for
      % geostruct-type objects and plotting with geoshow. below converts to
      % nan-separated lists, suitable for axesm-based functions like plotm.

      % activate this and add it to output for axesm-based compatibility.
      % [lat,lon] = polyjoin(lat,lon);

      switch S.ctype
         case {'polylineZ','polyline'}
            T = geostructinit('Line',numel(lat),'fieldnames',S.fieldnames);
         case {'polygon'}
            T = geostructinit('Polygon',numel(lat),'fieldnames',S.fieldnames);
         case {'point'}
            T = geostructinit('Point',numel(lat),'fieldnames',S.fieldnames);
      end

      %       if isscalarstruct
      %          T.Lon = lon{:};
      %          T.Lat = lat{:};
      % %          % this is if lat/lon are converted to double arrays for the scalar case
      % %          for n = 1:numel(T)
      % %             T(n).Lon = lon(n);
      % %             T(n).Lat = lat(n);
      % %          end
      %       else
      %          [T(1:numel(lon)).Lon] = lon{:};
      %          [T(1:numel(lat)).Lat] = lat{:};
      %       end

      % this actually works for scalar and non-scalar case if the scalar case is
      % kept as a 1x1 cell, so I commented out the if-else above
      [T(1:numel(lon)).Lon] = lon{:};
      [T(1:numel(lat)).Lat] = lat{:};

      % for polygons/lines, get the bounding box of each element
      if ismember(S.ctype,{'polylineZ','polyline','polygon'})
         try
            T = updategeostruct(T);
         catch ME3
            if strcmp(ME3.identifier,'MATLAB:license:checkouterror')
               T = updateBoundingBox(T);
            end
         end
      end

      if ~isscalar(S)
         T = struct2table(T); % for movevars, also simplifies field assignment
      else
         T = struct2table(T,'AsArray',true); % for movevars, also simplifies field assignment
      end

      if Aok % we have an attribute table, join it with S
         fields = S.fieldnames;
         for n = 1:numel(fields)
            T.(fields{n}) = A.(fields{n});
         end
      end

      % might be able to remove this if updateBoundingBox is used
      if contains('BoundingBox',T.Properties.VariableNames)
         T = movevars(T,'BoundingBox','After','Geometry');
      end

      % send back the geostruct (overwrite m_shapefile S)
      S = table2struct(T);

   catch ME4

   end

end

function S = m_map_shaperead(fname,namedargs)

activate m_map

if ismember({'BoundingBox'},namedargs(1:2:end)) % elements 1:2:end are parameters
   B = namedargs{find(ismember('BoundingBox',namedargs(1:2:end)))+1};
   S = m_shaperead(strrep(fname,'.shp',''),[B(1,:),B(2,:)]);
else
   S = m_shaperead(strrep(fname,'.shp',''));
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
p.FunctionName    = mfilename;
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














