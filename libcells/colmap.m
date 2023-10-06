function varargout = colmap(fn, varargin)
   %COLMAP Apply function to array columns and return cell array of results
   %
   % colmap(fn, A)
   %   Apply function fn to each column of A and return all the
   %   results in a cell array.
   %
   % [a, b, ...] = colmap(fn, A)
   %   Apply function fn to each column of A. Output a is a cell array containing
   %   all of the first outputs. Likewise b contains all of the second outputs.
   %
   % ... = colmap(fn, A, B, ...)
   %   Now fn takes multiple arguments, taking a column from each of the input
   %   arrays A, B, ...
   %
   % The returned cell array(s) are row-vectors in shape. If the outputs are column
   % vectors and if fn only has one output, then cell2mat(colmap(fn, A)) gives the
   % same result as colfun(fn, A).
   %
   % See also: rowmap, rowfun, colfun

   % Iain Murray, November 2007

   varargout = cell(1, max(1, nargout));
   [varargout{:}] = dimmap(fn, 1, varargin{:});
end
