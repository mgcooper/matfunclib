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

   % Original method:
   % varargout = cell(1, nargout);
   % [varargout{:}] = cellfun(fn, varargin{:}, 'UniformOutput', false);

   % Maybe this? Note - standard implementation above passes the burden to the
   % caller, who must use deal (or dealout) to handle this.
   varargout = cell(1, nargout);
   if all(cellfun(@iscell, varargin))
      [varargout{:}] = cellfun(fn, varargin{:}, 'UniformOutput', false);
   else
      varargout = cellfun(fn, varargin, 'UniformOutput', false);
   end

   % Note: I don't fully understand why, but if a cell array is passed in and
   % each element is a uniform sized array, and on the calling side the same
   % number of outputs are requested as elements of the input cell array, then
   % this syntax is required (and initialization is not technically needed):
   % varargout = cell(1, nargout);
   % varargout(1:nargout) = cellfun(fn, varargin{:}, 'UniformOutput', false);

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
