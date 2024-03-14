function S = ncStructToTable(info, ncattnames)
   %NCSTRUCTTOTABLE Convert the struct returned by ncread to a table
   %
   %  S = NCSTRUCTTOTABLE(INFO, NCATTNAMES)
   %
   % See also: ncreaddata, ncparse, ncread, ncinfo

   try
      S = struct2table(info.Variables);

      % Among the attributes parsed, only "Dimensions" requires custom
      % processing for consistency with the custom method in the catch
      if ismember("Dimensions", S.Properties.VariableNames)
         dimscolumn = {info.Variables.Dimensions}';
         S.Dimensions = cellfun(@(s) ...
            join(string({s.Name})), dimscolumn);
      end

   catch
      % Make a standard one that mimics the ncread "Variables" struct
      S = table;

      % First add the names. This should never fail.
      S.Name = (string({info.Variables.Name}))';
      nvars = length(S.Name);

      % Try to add each standard column in the struct returned by ncread,
      % except for the "attributes" which are expanded to individual columns.
      varstruct = info.Variables;
      for thisatt = ncattnames(:)'

         % Extract this attribute column.
         onecolumn = {varstruct.(thisatt)}';

         % Note: next section expands 'Attributes' to individual columns.
         switch thisatt
            case {'Attributes', 'Size', 'ChunkSize'}
               % nonscalar numerics or structs
               try
                  S.(thisatt) = onecolumn;
               catch
                  S.(thisatt)(1:nvars) = NaN;
               end

            case 'Dimensions'
               % special case: join strings e.g. ["longitude latitude"]
               try
                  S.(thisatt) = cellfun(@(s) ...
                     join(string({s.Name})), onecolumn);
               catch
                  S.(thisatt)(1:nvars) = string(missing);
               end
            case 'Datatype'
               % scalar strings
               try
                  S.(thisatt) = string(onecolumn);
               catch
                  S.(thisatt)(1:nvars) = string(missing);
               end
            otherwise
               % scalar numerics (FillValue, DeflateLevel, Shuffle)
               % Note: may need special method for FillValue, which can be a
               % char e.g., 'disable' or a numeric.
               try
                  S.(thisatt) = vertcat(onecolumn{:});
               catch
                  S.(thisatt)(1:nvars) = NaN;
               end
         end
      end
   end
end
%% Notes

% Keep this to clarify the cellfun method used for "Dimensions"
function dims = dimsStructToString(varstruct)

   % This expects the "Variables" struct returned by ncread
   dims = strings(numel(varstruct), 1);
   for n = 1:numel(varstruct)
      dims(n) = join(string({varstruct(n).Dimensions.Name}));
   end

   % This does it in one line:
   % dims = cellfun(@(s) join(string({s.Name})), {varstruct.(thisatt)}');
end
