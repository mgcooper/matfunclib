function varargout = dimfun(fn, dim, varargin)
   %DIMFUN Helper function for map functions
   %
   % varargout = dimfun(fn, dim, varargin)
   %
   % Helper function. Used by rowfun and colfun to apply functions to rows and
   % columns of matrices. I'm also using it in my slow m-file version of histc for
   % use in Octave. However, the nd-array stuff is a bit too hacky, and I'm still
   % getting my head around it. That's why this is private.

   varargout = cell(1, max(1, nargout));
   [varargout{:}] = dimmap(fn, dim, varargin{:});
   varargout = cellmap(@cell2mat, varargout);
end
