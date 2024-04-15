function T = ncparse(fname)
   %PARSENC Parse a netcdf file - variable names, attributes, dimensions
   %
   % T = NCPARSE(FNAME) Returns the variable names, attributes, dimensions,
   % into a matlab table T that is easier to access than the standard struct
   % output of ncinfo. In particular, the attributes of each variable are
   % expanded into individual columns, with missing inserted if a variable does
   % not have a value for the attribute. This provides a "flat" view of the
   % entire file, rather than a nested view provided by ncinfo.
   %
   % See also: ncvars, ncreaddata

   info = ncinfo(fname);

   % Retrieve the standard fields to expand each info.Variables.Attributes
   % struct into individual columns.
   varattnames = ncdefaults("attributes");

   % These are the other standard variable attributes which are already columns
   % in the struct returned by ncread.
   ncattnames = ["Attributes", "Dimensions", "Size", "Datatype", ...
      "ChunkSize", "FillValue", "DeflateLevel", "Shuffle"];

   % Convert the ncread "Variables" struct to a table
   T = ncStructToTable(info, ncattnames);

   % If struct2table failed, and the assignment of the "Attributes" column
   % failed, then there are no attributes to expand.
   if none(cellfun(@isstruct, T.Attributes)) && all(isnan(T.Attributes))
      return
   end

   % Otherwise, expand the attributes to individual columns
   nvars = length(T.Name);

   % Add columns for variable attributes, to expand the "Attributes" structs

   for thisatt = varattnames(:)'
      T.(thisatt)(1:nvars) = string(missing);
   end

   % Fill in the attributes for each variable
   for n = 1:nvars

      varatts = info.Variables(n).Attributes;

      % Get the names of the attributes
      if isempty(varatts)
         continue
      else
         attnames = string({varatts.Name}');
      end

      % Match this variable's attributes with the list of possible varatts
      for thisatt = varattnames(:)'
         if any(attnames == thisatt)
            T.(thisatt)(n) = varatts(attnames == thisatt).Value;
         end
      end
   end

   % Previously I added the filename, keep for patching errors.
   T.Filename(1:nvars) = string(info.Filename);

   % Rearrange the columns in a preferred order.
   T = movevars(T, {'standard_name', 'units', 'axis', 'coordinates'}, ...
      "After", 'Name');

   % Keep the "Attributes" column to identify non-expanded ones, but
   % move it to the end.
   T = movevars(T, 'Attributes','After', width(T));

   % Remove any columns with all missing values.
   T = rmmissing(T, 2, 'MinNumMissing', height(T));

   % For reference, in case rmmissing method fails:
   % T = T(:, ~varfun(@(x) all(ismissing(x)), T, "Output", "uniform"));
end
