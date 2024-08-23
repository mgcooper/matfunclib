function [tblTransposed] = transposeTable(tbl, opts)
   %TRANSPOSETABLE Transpose a table.
   %
   % [tblTransposed] = transposeTable(tbl)
   %
   % See also:
   arguments
      tbl table
      opts.RowNames string = tbl.Properties.VariableNames
      opts.VarNames string = tbl.Properties.RowNames
   end
   rowNames = opts.RowNames;
   varNames = opts.VarNames;

   if notempty(varNames) %  && (numel(rowNames) == numel(varNames))

      % Expected case, transpose data and swap rowNames for varNames
      tblTransposed = array2table(tbl{:, :}', 'RowNames', rowNames, ...
         'VariableNames', varNames);

   elseif numel(varNames) == height(tbl)

      % Special case, transpose data but keep variable names
      tblTransposed = array2table(tbl{:, :}', 'VariableNames', varNames);
   else
      if isempty(varNames)
         eid = ['custom:' mfilename ':missingVarNames'];
         msg = ['If VariableNames for the transposed table are not specified, ' ...
            'the input table RowNames are used by default. If the input table has ' ...
            'no RowNames, new VariableNames must be specified.'];
         error(eid, msg)
      end
   end
end
