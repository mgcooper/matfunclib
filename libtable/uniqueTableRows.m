function tbl = uniqueTableRows(tbl)
   % uniqueTableRows - Ensures unique rows in a table, handling non-uniform cell arrays.
   %
   % This function attempts to find unique rows in a table. If the `unique`
   % function fails due to non-uniform data types (e.g., cell arrays containing
   % mixed types or incompatible data), the function automatically handles such
   % cases by replacing non-uniform columns with temporary unique integer
   % identifiers, finding unique rows, and restoring the original data.
   %
   % Syntax:
   %   tbl = uniqueTableRows(tbl)
   %
   % Input:
   %   tbl - Input table for which unique rows are to be determined.
   %
   % Output:
   %   tbl - Table with unique rows.
   %
   % Example:
   %   % Create a table with mixed-type columns
   %   T = table({'file1'; 'file2'; 'file1'}, [1; 2; 1], ...
   %             'VariableNames', {'Files', 'Values'});
   %   % Make rows unique
   %   T_unique = uniqueTableRows(T);
   %
   % Notes:
   %   - This function assumes that each column with mixed data types
   %     (e.g., non-uniform cell arrays) can be uniquely encoded and restored.
   %   - Columns with numeric or uniform string data are unaffected.
   %
   % See also:

   try
      % Attempt to use unique on the entire table
      tbl = unique(tbl, 'rows');
   catch e
      % If unique fails, handle non-uniform columns. Note there are two general
      % cases handled here: 1) when a table column contains mixed cell and char
      % types, it replaces them with unique numeric IDs in the
      vars = tbl.Properties.VariableNames;

      % Identify problematic columns
      cols = find(cellfun(@(col) ~isUniformColumn(tbl.(col)), vars));

      % Backup and replace problematic columns (e.g., mixed cell and char)
      for n = numel(cols):-1:1
         thisvar = vars{cols(n)};
         [C{n}, ~, ic{n}] = uniqueCellVector(tbl.(thisvar));
         tbl.(thisvar) = ic{n}; % Replace with unique indices
      end

      % Before applying unique, if any columns are chars of different size,
      % unique will fail

      % Apply unique and restore original data
      tbl = unique(tbl, 'rows');
      for n = 1:numel(cols)
         thisvar = vars{cols(n)};
         tbl.(thisvar) = C{n}(tbl.(thisvar));
      end
   end
end

function tf = isUniformColumn(column)
   % Checks if a column has uniform data type
   if iscell(column)
      classes = cellfun(@class, column, 'UniformOutput', false);
      tf = isscalar(unique(classes));
   else
      tf = true;
   end
end

% Old version that only checked for mixed char/cell arrays, didn't catch columns
% with mixed char/string arrays.
% function tf = isUniformColumn(column)
%    % Checks if a column has uniform data type
%    if iscell(column)
%       tf = all(cellfun(@(x) ischar(x) || isstring(x), column));
%    else
%       tf = true;
%    end
% end
