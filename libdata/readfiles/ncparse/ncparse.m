function S = ncparse(fname)
   %PARSENC Parse a netcdf file - variable names, attributes, dimensions
   %
   % S = NCPARSE(FNAME) Returns the variable names, attributes, dimensions,
   % into a matlab table S that is easier to access than the standard struct
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
   S = ncStructToTable(info, ncattnames);

   % If struct2table failed, and the assignment of the "Attributes" column
   % failed, then there are no attributes to expand.
   if none(cellfun(@isstruct, S.Attributes)) && all(isnan(S.Attributes))
      return
   end

   % Otherwise, expand the attributes to individual columns
   nvars = length(S.Name);

   % Add columns for variable attributes, to expand the "Attributes" structs

   for thisatt = varattnames(:)'
      S.(thisatt)(1:nvars) = string(missing);
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
            S.(thisatt)(n) = varatts(attnames == thisatt).Value;
         end
      end
   end

   % Previously I added the filename, keep for patching errors.
   S.Filename(1:nvars) = string(info.Filename);

   % Rearrange the columns in a preferred order.
   S = movevars(S, {'standard_name', 'units', 'axis', 'coordinates'}, ...
      "After", 'Name');

   % Keep the "Attributes" column to identify non-expanded ones, but
   % move it to the end.
   S = movevars(S, 'Attributes'); % default behavior moves it to the end

   % Remove any columns with all missing values.
   S = rmmissing(S, 2, 'MinNumMissing', height(S));

   % For reference, in case rmmissing method fails:
   % S = S(:, ~varfun(@(x) all(ismissing(x)), S, "Output", "uniform"));
end
