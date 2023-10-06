function varargout = colfun(fn, varargin)
   %COLFUN Apply function to each column of array returning array of answers
   %
   % results = colfun(fn, A)
   %   Apply function fn to each column of A and return each answer
   %   as a column of results. Note that answers must stack side by side.
   %
   % [a, b, ...] = colfun(fn, A)
   %   Apply function fn to each column of A. Output a is an array containing
   %   all of the first outputs. Likewise b contains all of the second outputs.
   %
   % ... = colfun(fn, A, B, ...)
   %   Now fn takes multiple arguments, taking a column from each of the input
   %   arrays A, B, ...
   %
   % See also: rowfun, rowmap, colmap

   % Iain Murray, November 2007

   varargout = cell(1, max(1, nargout));
   [varargout{:}] = dimfun(fn, 1, varargin{:});
end
