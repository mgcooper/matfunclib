function A = rowsum(A,varargin)
   %ROWSUM Compute sums across rows of array or tabular object A
   %
   % Syntax:
   %
   %  A = ROWSUM(A); returns the sum of all rows in A as a column
   %  A = ROWSUM(A,1); returns the sum of row 1 as a scalar
   %  A = ROWSUM(___,'addcolumn',true); adds the row sum as a column to A
   %
   % See also:

   % parse inputs
   parser = inputParser;
   parser.FunctionName = mfilename;
   parser.CaseSensitive = false;
   parser.KeepUnmatched = true;
   parser.addRequired( 'A', @ismatrix);
   parser.addOptional( 'rowindex', defaultrows(A), @isnumeric);
   parser.addParameter('addcolumn', false, @islogical);
   parser.parse(A, varargin{:});
   rowindex = parser.Results.rowindex;
   addcolumn = parser.Results.addcolumn;

   % main
   wastabular = istable(A) || istimetable(A);
   if wastabular
      T = A;
      A = table2array(T);
   end

   % compute the row sum
   S = sum(A(rowindex,:),2,'omitnan');

   % either add it as a new column or return
   if addcolumn == true
      if wastabular
         A = T;
         A.RowSum = S;
         if numel(unique(T.Properties.VariableUnits)) == 1
            A = settableunits(A,unique(T.Properties.VariableUnits));
         end
      else
         A = cat(2,A,S);
      end
   else
      A = S;
   end
end

%% subfunctions
function rows = defaultrows(A)

   if istable(A) || istimetable(A)
      rows = 1:height(A);
   else
      rows = 1:size(A,1);
   end
end
