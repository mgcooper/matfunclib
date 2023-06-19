function varargout = rowmap(fn, varargin)
%ROWMAP apply function to each row of array returning cell-array of answers
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
[varargout{:}] = dimmap(fn, 2, varargin{:});function varargout = dimmap(fn, dim, varargin)
% Helper function. Used by rowmap and colmap to apply functions to rows and
% columns of matrices. Maybe this is more generally useful, but I haven't
% thought through applying functions to higher dimensional arrays.

assert(nargin >= 3);

args = cellmap(@(x) my_num2cell(x, dim), varargin);

varargout = cell(1, max(1, nargout));
[varargout{:}] = cellmap(fn, args{:});

function C = my_num2cell(x, dim)
% Only needed for Octave, but no harm in general.
% Replace with num2cell when Octave gets fixed.
if dim > length(size(x))
    C = num2cell(x);
else
    C = num2cell(x, dim);
end