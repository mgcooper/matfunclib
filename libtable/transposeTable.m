function [tableTransposed] = transposeTable(tableIn, opts)
   %TRANSPOSETABLE Transpose a table.
   %
   % [tableTransposed] = transposeTable(tableIn)
   %
   % See also:
   arguments
      tableIn table
      opts.RowNames string = tableIn.Properties.VariableNames
      opts.VarNames string = tableIn.Properties.RowNames
   end
   rowNames = opts.RowNames;
   varNames = opts.VarNames;
      
   if notempty(varNames) %  && (numel(rowNames) == numel(varNames))

      % Expected case, transpose data and swap rowNames for varNames
      tableTransposed = array2table(tableIn{:, :}', 'RowNames', rowNames, ...
         'VariableNames', varNames);

   elseif numel(varNames) == height(tableIn)

      % Special case, transpose data but keep variable names
      tableTransposed = array2table(tableIn{:, :}', 'VariableNames', varNames);
   else
      error('Table has no rownames')
   end
end
