function varargout = cellmap(fn, varargin)
   %CELLMAP apply a function to a cell-array, returning a cell array of results.
   %
   % This function is equivalent to:
   % cellmap = @(fn, varargin) cellfun(fn, varargin{:}, 'UniformOutput', false);
   %
   % CELLMAP is very much like map() in other languages, as a cell array is
   % Matlab's generic list container. This trivial wrapper prevents cluttering
   % code with "'UniformOutput', false" garbage.
   %
   % Just as with cellfun, when there are multiple cell arrays, one item from
   % each is given to the function. Also multiple outputs can be requested from
   % the function.

   % Iain Murray, November 2007

   varargout = cell(1, nargout);
   [varargout{:}] = cellfun(fn, varargin{:}, 'UniformOutput', false);

   % % This first tries the user-supplied varargin, which, if empty, is
   % % equivalent to 'UniformOutput', true,
   % try
   %    [varargout{:}] = cellfun(fn, varargin{:});
   % catch
   %    try
   %       [varargout{:}] = cellfun(varargin{:}, 'UniformOutput', false);
   %    catch e
   %       rethrow(e)
   %    end
   % end
end
