function varargout = dimmap(fn, dim, varargin)
   % Helper function. Used by rowmap and colmap to apply functions to rows and
   % columns of matrices. Maybe this is more generally useful, but I haven't
   % thought through applying functions to higher dimensional arrays.

   assert(nargin >= 3);

   args = cellmap(@(x) my_num2cell(x, dim), varargin);

   varargout = cell(1, max(1, nargout));
   [varargout{:}] = cellmap(fn, args{:});
end

function C = my_num2cell(x, dim)
   % Only needed for Octave, but no harm in general.
   % Replace with num2cell when Octave gets fixed.
   if dim > length(size(x))
      C = num2cell(x);
   else
      C = num2cell(x, dim);
   end
end
