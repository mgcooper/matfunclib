function gm = parseGridMapping(GridMapping)
   %PARSEGRIDMAPPING Normalize a rotated-pole grid mapping from a struct or nc file.
   %
   % gm = parseGridMapping(GridMapping)
   %
   % Resolves the CF "rotated_latitude_longitude" grid mapping into a normalized
   % struct with the rotated-pole location used by the transforms. GRIDMAPPING may
   % be:
   %
   %   - a struct mirroring the CF grid_mapping attributes, with fields
   %     grid_north_pole_latitude / grid_north_pole_longitude (or the friendly
   %     aliases PoleLatitude / PoleLongitude); or
   %   - a char/string path to a netCDF file, in which case the rotated_pole
   %     attributes are read via NCINFO (metadata only -- the data array is never
   %     read), so a caller can pass the source file directly.
   %
   % Output struct gm has fields:
   %   gm.PoleLatitude   - grid_north_pole_latitude (deg)
   %   gm.PoleLongitude  - grid_north_pole_longitude (deg)
   %   gm.GridMappingName- the CF grid_mapping_name ('rotated_latitude_longitude')
   %
   % See also: geo2rotated, rotated2geo, ncreaddata

   % An nc file path: read the grid-mapping attributes (not the data) via ncinfo.
   if (ischar(GridMapping) || (isstring(GridMapping) && isscalar(GridMapping)))
      gm = readGridMappingFromFile(char(GridMapping));
      return
   end

   % Otherwise a struct of CF (or friendly) attributes.
   assert(isstruct(GridMapping), ...
      'parseGridMapping:badType', ...
      'GridMapping must be a struct of CF attributes or a netCDF file path.');

   gm.PoleLatitude  = getfieldalias(GridMapping, ...
      {'grid_north_pole_latitude', 'PoleLatitude'});
   gm.PoleLongitude = getfieldalias(GridMapping, ...
      {'grid_north_pole_longitude', 'PoleLongitude'});
   gm.GridMappingName = getfieldalias(GridMapping, ...
      {'grid_mapping_name', 'GridMappingName'}, 'rotated_latitude_longitude');

   validateGridMapping(gm);
end

function gm = readGridMappingFromFile(ncfile)
   %READGRIDMAPPINGFROMFILE Extract rotated_pole attributes from a netCDF file.

   assert(isfile(ncfile), 'parseGridMapping:fileNotFound', ...
      'GridMapping file not found: %s', ncfile);

   % ncinfo reads only metadata (variables + attributes), never the data arrays.
   info = ncinfo(ncfile);

   % Find the grid-mapping container variable: the one carrying a
   % grid_mapping_name attribute set to 'rotated_latitude_longitude'.
   for k = 1:numel(info.Variables)
      attrs = info.Variables(k).Attributes;
      if isempty(attrs)
         continue
      end
      names = string({attrs.Name});
      isname = strcmpi(names, 'grid_mapping_name');
      if any(isname) && contains(lower(string(attrs(isname).Value)), ...
            'rotated_latitude_longitude')

         gm.PoleLatitude = attrs(strcmpi(names, 'grid_north_pole_latitude')).Value;
         gm.PoleLongitude = attrs(strcmpi(names, 'grid_north_pole_longitude')).Value;
         gm.GridMappingName = 'rotated_latitude_longitude';
         validateGridMapping(gm);
         return
      end
   end

   error('parseGridMapping:noRotatedPole', ...
      'No rotated_latitude_longitude grid_mapping found in %s', ncfile);
end

function value = getfieldalias(s, aliases, default)
   %GETFIELDALIAS Return the first matching field (case-insensitive) or a default.

   fns = fieldnames(s);
   for a = 1:numel(aliases)
      hit = strcmpi(fns, aliases{a});
      if any(hit)
         value = s.(fns{find(hit, 1)});
         return
      end
   end
   if nargin > 2
      value = default;
   else
      error('parseGridMapping:missingField', ...
         'GridMapping is missing a required field (e.g. %s).', aliases{1});
   end
end

function validateGridMapping(gm)
   %VALIDATEGRIDMAPPING Confirm the mapping is rotated-pole with numeric poles.

   assert(contains(lower(string(gm.GridMappingName)), 'rotated_latitude_longitude'), ...
      'parseGridMapping:unsupported', ...
      'Only rotated_latitude_longitude grid mappings are supported (got "%s").', ...
      gm.GridMappingName);
   validateattributes(gm.PoleLatitude, {'numeric'}, {'scalar', 'real', 'finite'});
   validateattributes(gm.PoleLongitude, {'numeric'}, {'scalar', 'real', 'finite'});
end
