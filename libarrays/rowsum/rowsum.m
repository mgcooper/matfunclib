function A = rowsum(A,varargin)
%ROWSUM compute sums across rows of array or tabular object A
% 
% Syntax:
% 
%  A = ROWSUM(A); returns the sum of all rows in A as a column
%  A = ROWSUM(A,1); returns the sum of row 1 as a scalar
%  A = ROWSUM(___,'addcolumn',true); adds the row sum as a column to A
% 
% Author: Matt Cooper, DD-MMM-YYYY, https://github.com/mgcooper

%------------------------------------------------------------------------------
% input parsing
%------------------------------------------------------------------------------
p                 = magicParser;
p.FunctionName    = 'rowsum';
p.CaseSensitive   = false;
p.KeepUnmatched   = true;

p.addRequired( 'A',                             @(x)ismatrix(x)      );
p.addOptional( 'rowindex',    defaultrows(A),   @(x)isnumeric(x)     );
p.addParameter('addcolumn',   false,            @(x)islogical(x)     );

p.parseMagically('caller');

% https://www.mathworks.com/help/matlab/matlab_prog/parse-function-inputs.html
%------------------------------------------------------------------------------

wastabular = istable(A) || istimetable(A);

if wastabular
   T = A;
   A = table2array(T);
end

% compute the row sum
S = sum(A(rowindex,:),2);

% either add it as a new column or return
if addcolumn == true
   if wastabular
      A = T;
      A.RowSum = S;
   else
      A = cat(2,A,S);
   end
else
   A = S;
end

function rows = defaultrows(A)

if istable(A) || istimetable(A)
   rows = 1:height(A);
else
   rows = 1:size(A,1);
end








