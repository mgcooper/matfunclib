function [C, ia, ic] = uniqueCellVector(A)
   % uniqueCellVector - Handle unique operations for cell arrays with mixed types.
   %
   % Written by Benjamin Kraus, June 17, 2014
   % MathWorks Technical Support Department
   %
   % This function finds unique values in a cell array by comparing elements
   % with `isequal`, supporting nested structures and mixed data types.
   %
   % Syntax:
   %   [C, ia, ic] = uniqueCellVector(A)
   %
   % Inputs:
   %   A - Cell array (may contain mixed types or nested data).
   %
   % Outputs:
   %   C  - Unique values in the input cell array.
   %   ia - Indices of the first occurrence of each unique value.
   %   ic - Indices mapping input values to unique values.
   %
   n = numel(A);
   ic = (1:n)';

   for cur = 2:n
      % Compare current item with all previous items.
      for prev = 1:(cur-1)
         % If we find a match, then we are done, update the list of
         % unique items to show that current item = previous item.
         if isequal(A(cur), A(prev))
            ic(cur) = prev;
            break
         end
      end
   end

   % Now that we have numerical vectors, use 'unique' to make the unique
   % integers continuous (instead of skipping over numbers). This will
   % also generate 'ia' and regenerate 'ic' automatically.
   [~, ia, ic] = unique(ic);

   % Use 'ia' to resample the original matrix and return the unique
   % elements of the original matrix.
   C = A(ia);
end
