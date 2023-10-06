function varargout = rowmap(fn, varargin)
   %ROWMAP Apply function to each row of array returning cell-array of results
   %
   % rowmap(fn, A)
   %   Apply function fn to each row of A and return all the
   %   results in a cell array.
   %
   % [a, b, ...] = rowmap(fn, A)
   %   Apply function fn to each row of A. Output a is a cell array containing
   %   all of the first outputs. Likewise b contains all of the second outputs.
   %
   % ... = rowmap(fn, A, B, ...)
   %   Now fn takes multiple arguments, taking a row from each of the input
   %   arrays A, B, ...
   %
   % The returned cell array(s) are column-vectors in shape. If the outputs are row
   % vectors and if fn only has one output, then cell2mat(rowmap(fn, A)) gives the
   % same result as rowfun(fn, A).
   %
   % See also: colmap, rowfun, colfun

   % Iain Murray, November 2007

   varargout = cell(1, max(1, nargout));
   [varargout{:}] = dimmap(fn, 2, varargin{:});
end
