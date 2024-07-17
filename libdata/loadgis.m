function [S, A] = loadgis(fname, varargin)
   %LOADGIS loads gis data saved in USERGISPATH
   %
   %  Data = LOADGIS(fname);
   %
   % Matt Cooper, 07-Jul-2020, https://github.com/mgcooper
   %
   % See also: gisfilelist, loaddata

   % NOTE: I probably need to have one function for loadshapefile and one for
   % loadraster to have [S,A] and [Z,R] outputs.

   % PARSE INPUTS
   [fname, reader, UseGeoCoords, Selector, Attributes, BoundingBox, namedargs] = ...
      parseinputs(fname, mfilename, varargin{:});

   % if fname is not already on the path and/or is not a full-path filename, try
   % to find the file in the USERGISPATH
   if ~isfile(fname)
      fname = findgisfile(fname);
   end
   [~, ~, ext] = fileparts(fname);

   switch ext
      case '.shp'
         [S, A] = tryshaperead(fname, namedargs, reader);

      case '.tif'
         try
            S = readgeoraster(fname, varargin{:});
         catch ME

         end
   end
end


function [S, A] = tryshaperead(fname, namedargs, reader)

   used_m_map = false;
   has_attrs_tbl = true;

   if reader == "m_map"
      S = m_map_shaperead(fname, namedargs);
      used_m_map = true;
   else

      try
         [S, A] = shaperead(fname, namedargs{:});
         % March 2023, added merge, but it will go to the A section and I think
         % its designed only for m_map, so instead I join the attributes with S
         % here but probably won't work for all geometries
         % ok = true;
         S = mergestructs(S, A);

         % Wanted to use this to automatically rename X,Y to Lat,Lon for
         % geostructs, but updateCoordinates is designed to add X,Y or Lat,Lon
         % coords when the other are already present, given a map projection.
         % S = updateCoordinates(S)

      catch ME

         if strcmp(ME.identifier, 'MATLAB:license:checkouterror')
            wid = 'custom:loadgis:MapCheckoutErrorUsingMMap';
            msg = 'Mapping Toolbox checkout error. Using m_shaperead.';
            warning(wid, msg)
         end

         if strcmp(ME.message,'Unsupported shape type PolyLineZ (type code = 13).')
            % try m_map/m_shaperead. note: m_shaperead argument UBR (User
            % Bounding Rectangle) assumes format [minX  minY  maxX maxY] whereas
            % shaperead BoundingBox is [minX  minY ; maxX maxY]. do the
            % conversion if needed.
            wid = 'custom:loadgis:PolyLineZUsingMMap';
            msg = 'Requested shapefile is type PolyLineZ. Using m_shaperead.';
            warning(wid, msg)
         end

         try
            S = m_map_shaperead(fname, namedargs);
            used_m_map = true;
         catch ME2
            rethrow(ME2) % throw the error (revisit)
         end

      end
   end

   if used_m_map
      % Data produced by m_shaperead may need to be wrangled to a ueseable
      % format. return to this later. For now, convert the attributes to A and
      % the lat,lon to S
      has_attrs_tbl = false;
      try
         A = struct2table(S.dbf); % attribute table
         has_attrs_tbl = true;
      catch e

      end

      % Make sure the lat,lon values that go into elements of S are row vectors
      try
         % if S is scalar (one point, line, polyline, or polygon)
         % isscalarstruct = false;
         % if numel(S.ncst) == 1 && numel(S.dbf) == 1
         %    lat = S.ncst{1}(:,2);
         %    lon = S.ncst{1}(:,1);
         %    isscalarstruct = true;
         % else
         %    % non-scalar
         %    lat = cellfun(@transpose, ...
         %       cellfun(@(x) vertcat(x(:,2)), S.ncst, 'Uniform', 0), 'Uniform', 0);
         %    lon = cellfun(@transpose, ...
         %       cellfun(@(x) vertcat(x(:,1)), S.ncst, 'Uniform', 0), 'Uniform', 0);
         % end

         lat = cellfun(@transpose, ...
            cellfun(@(x) vertcat(x(:,2)), S.ncst, 'Uniform', 0), 'Uniform', 0);
         lon = cellfun(@transpose, ...
            cellfun(@(x) vertcat(x(:,1)), S.ncst, 'Uniform', 0), 'Uniform', 0);

         % for non-scalar, above returns lat lon as cell arrays, suitable for
         % geostruct-type objects and plotting with geoshow. below converts to
         % nan-separated lists, suitable for axesm-based functions like plotm.

         % activate this and add it to output for axesm-based compatibility.
         % [lat, lon] = polyjoin(lat, lon);

         switch S.ctype
            case {'polylineZ', 'polyline'}
               GeomType = 'Line';
            case {'polygon'}
               GeomType = 'Polygon';
            case {'point'}
               GeomType = 'Point';
            otherwise
               GeomType = char.empty;
         end

         if ~isempty(GeomType)
            T = geostructinit(GeomType, numel(lat), 'fieldnames', S.fieldnames);
         end

         % if isscalarstruct
         %    T.Lon = lon{:};
         %    T.Lat = lat{:};
         % % % this is if lat/lon are converted to double arrays for the scalar case
         % % for n = 1:numel(T)
         % %    T(n).Lon = lon(n);
         % %    T(n).Lat = lat(n);
         % % end
         % else
         %    [T(1:numel(lon)).Lon] = lon{:};
         %    [T(1:numel(lat)).Lat] = lat{:};
         % end

         % this actually works for scalar and non-scalar case if the scalar case is
         % kept as a 1x1 cell, so I commented out the if-else above
         [T(1:numel(lon)).Lon] = lon{:};
         [T(1:numel(lat)).Lat] = lat{:};

         % for polygons/lines, get the bounding box of each element
         if ismember(S.ctype, {'polylineZ','polyline','polygon'})
            try
               T = updategeostruct(T);
            catch ME3
               if strcmp(ME3.identifier, 'MATLAB:license:checkouterror')
                  T = updateBoundingBox(T);
               end
            end
         end

         if ~isscalar(T) % jul 2024: was ~isscalar(S), changed to ~isscalar(T)
            T = struct2table(T); % for movevars, also simplifies field assignment
         else
            T = struct2table(T,'AsArray',true); % for movevars, also simplifies field assignment
         end

         if has_attrs_tbl % we have an attribute table, join it with S
            fields = S.fieldnames;
            for n = 1:numel(fields)
               T.(fields{n}) = A.(fields{n});
            end
         end

      catch ME4

      end

   else

      % Added this for shaperead so same checks below this can be applied
      % whether m_map or shaperead was used.

      % NOTE: If this causes trouble, Could move the

      if ~isscalar(S)
         T = struct2table(S);
      else
         T = struct2table(S, 'AsArray', true);
      end

      if all(ismember({'X', 'Y'}, T.Properties.VariableNames))
         lat = {T.Y};
         lon = {T.X};
      else
         % Easiest to use geostructCoordinates, but requires S not T. And if
         % this fails, it will cause problems in the final checks, which may not
         % even be necessary for shaperead ... but keep it for now.
         [lat, lon] = geostructCoordinates(S, "geographic", "ascell");
      end
   end

   % BELOW HERE WAS ONLY IN THE M_MAP SECTION, SO MOVE IT BACK IF IT CREATES
   % MORE PROBLEMS THAN IT SOLVES FOR SHAPEREAD.

   % might be able to remove this if updateBoundingBox is used
   if contains('BoundingBox', T.Properties.VariableNames)
      T = movevars(T, 'BoundingBox', 'After', 'Geometry');
   end

   % If the lat/lon values are actually X, Y, rename the fields
   if none(cellfun(@(x, y) isGeoGrid(y, x), lon, lat))

      % Note: This was specifically for m_map b/c I think it always uses
      % lat/lon?
      T = renamevars(T, {'Lat', 'Lon'}, {'Y', 'X'});

   elseif all(cellfun(@(x, y) isGeoGrid(y, x), lon, lat))

      % Added this for a case where shaperead (w/o UseGeoCoords) returned X,Y
      % but this requires checking if the fields are actually X,Y so I commented
      % this out and INSTEAD I NEED TO ADD AN OPTION TO UPDATECOORDINATES TO DO
      % THE RENAMING AND/OR REMEMBER TO USE USEGEOCOORDS

      if all(cellfun(@(v) isvariable(v, T), {'X', 'Y'})) ...
            && none(cellfun(@(v) isvariable(v, T), {'Lon', 'Lat'}))
         T = renamevars(T, {'X', 'Y'}, {'Lon', 'Lat'});
      end

   else
      % cannot determine if geographic or projected, revisit this later

   end

   % send back the geostruct (overwrite m_shapefile S)
   S = table2struct(T);

end

function S = m_map_shaperead(fname, namedargs)

   if ~isactive('m_map')
      activate m_map
   end

   % Elements 1:2:end of namedargs are the parameter names
   if ismember({'BoundingBox'}, namedargs(1:2:end))
      B = namedargs{find(ismember('BoundingBox', namedargs(1:2:end)))+1};
      S = m_shaperead(strrep(fname,'.shp',''), [B(1,:), B(2,:)]);
   else
      S = m_shaperead(strrep(fname, '.shp', ''));
   end
end

%% Input Parser
function [fname, reader, UseGeoCoords, Selector, Attributes, ...
      BoundingBox, namedargs] = parseinputs(fname, funcname, varargin)

   % in shaperead.m, a custom parseInputs function is used (not inputParser),
   % which first initializes these as follows, therefore these should work as
   % defualt values for this and any other function that calls shaperead.
   %
   % recordNumbers = [];
   % boundingBox = [];
   % selector = [];
   % attributes = [];
   % useGeoCoords = false;

   % Note: I had 'reader' as an optional argument. I think this was because I
   % thought if I strictly used arguments to shaperead for the name-value args I
   % could parse those out as 'namedargs' and pass them to shaperead:
   % shaperead(..., namedargs{:})
   % But

   parser = inputParser();
   parser.FunctionName = funcname;
   parser.KeepUnmatched = true;
   parser.addRequired('fname', @ischarlike);
   parser.addParameter('reader', 'shaperead', @validreader);
   parser.addParameter('UseGeoCoords', false, @islogical);
   parser.addParameter('Selector', [], @iscell);
   parser.addParameter('Attributes', [], @iscell);
   parser.addParameter('BoundingBox', [], @isnumeric);
   parser.parse(fname, varargin{:});

   reader = parser.Results.reader;
   UseGeoCoords = parser.Results.UseGeoCoords;
   Selector = parser.Results.Selector;
   Attributes = parser.Results.Attributes;
   BoundingBox = parser.Results.BoundingBox;

   % Jul 2024: This should work with refactored parser2varargin. Note the
   % purpose here is to get the optional arguments which are NOT using defaults,
   % because I don't know what the valid default values are for shaperead, so
   % this way I can pass namedargs{:} to shaperead only using the arguments
   % which are explicitly set by the user.
   requiredargs = {'fname'};
   namedargs = parser2varargin(parser, requiredargs, 'notusingdefaults');
   % namedargs = namedargs2cell(parser.Results)
end

function tf = validreader(x)
   tf = isoneof(x, {'shaperead', 'm_map'});
end
