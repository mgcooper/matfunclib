function V = cellflatten(C, dim, shape)
   %CELLFLATTEN Flatten cell array contents along a specified dimension.
   %
   % Syntax:
   %  V = CELLFLATTEN(C)
   %  V = CELLFLATTEN(C, dim)
   %  V = CELLFLATTEN(C, dim, shape)
   %
   % Description:
   %  CELLFLATTEN could rightly be called 'cells2array' or 'cell2num'. It's
   %  quite similar to Cell2Vec but additionally supports 2d arrays. Say you've
   %  got a cell array comprised of N elements, each of which have a compatible
   %  dimension along which concatenation could occur. Maybe each element is an
   %  Mx1 vector. Use CELLFLATTEN to produce an MxN (or NxM, 1x(N*M), or
   %  (N*M)x1) array. Typical conctanation of cell array elements often involves
   %  multiple steps which cannot (or should not) be chained together, e.g., a
   %  call to cellfun or arrayfun produces a cell array but you want a numeric
   %  array comprised of the cell array elements. Often this can be achieved in
   %  one line but requires tedious attention to the orientation of each
   %  element, both as they're input to cellfun and how they're returned. This
   %  is especially true when arrayfun is used to pass array indices to the
   %  function handle(s). Wrap a call to CELLFLATTEN around your *fun calls to
   %  immediately obtain the numeric array you've been hoping for.
   %
   %  For example, say S is a struct of N tables, each table has a Variable
   %  named 'var', and each table has the same number of M rows. The following
   %  code produces an Nx1 cell array, where each element is an Mx1 vector:
   %
   %    C = struct2cell(...
   %       structfun(@(tbl) tbl.var, S, 'UniformOutput', false));
   %
   %    % This concatenates the Mx1 vectors into an MxN array:
   %    SWE = [SWE{:}];
   %
   %    % Use cellflatten to do it in one step (note dim=2 is specified):
   %    C = cellflatten(struct2cell(...
   %       structfun(@(tbl) tbl.var, S, 'UniformOutput', false)), 2);
   %
   %  V = CELLFLATTEN(C) concatenates each element of cell array C along the
   %  first dimension that allows for concatenation. This is either horizontal
   %  or vertical concatenation depending on the dimensions of the cell
   %  elements, but priority is given to horizontal concatenation. Specify DIM
   %  to control the dimension along which the concatenation occurs.
   %
   %  TODO: Prioritize vertical concatenation instead? This would be consistent
   %  with standard matlab behavior i.e. dim=1. To do so, switch the default
   %  order to be vertcat then horzcat.
   %
   %  V = CELLFLATTEN(C, DIM) concatenates along the dimension specified by DIM.
   %
   %  V = CELLFLATTEN(C, DIM, SHAPE) returns the concatenated output reshaped
   %  according to the value of SHAPE. Valid options for SHAPE are 'row',
   %  'column', 'array', and 'transpose'. Use 'transpose' when the elements are
   %  concatenated along a dimension but the output array would require
   %  transpose. This can sometimes eliminate the need to first transpose each
   %  individual element prior to calling this function.
   %
   % Input:
   %   - C: cell array containing arrays that can be concatenated.
   %   - DIM (optional): integer specifying the dimension along which to
   %   concatenate.
   %   - SHAPE (optional): string specifying the shape of the output array.
   %   Default preserves the shape of the inputs.
   %
   % Output:
   %   - V: concatenated array.
   %
   % See also: CAT, CELL2MAT, HORZCAT, VERTCAT

   % NOTE: this will fail if the elements of C are oriented inconsistently i.e.
   % if some are rows and others are columns.

   % Validate 'shape' input or set default
   if nargin < 3
      shape = 'array';
   end
   validatestring(shape, {'row', 'column', 'array', 'transpose'}, ...
      mfilename, 'SHAPE', 3);

   % Concatenate cell array along specified dimension or choose adaptively
   if nargin < 2 || isempty(dim)
      try
         V = horzcat(C{:});
      catch
         V = vertcat(C{:});
      end
   else
      validateattributes(dim, {'numeric'}, {'scalar', 'positive', 'integer'}, ...
         mfilename, 'DIM', 2);
      V = cat(dim, C{:});

      % Note: Above will fail if the elements of C are oriented differently.
      % Below would fix the case where elements of C are arrays of different
      % size and the desired behavior is to create a 1xN or Nx1 list, where
      % N=sum(cellfun(@numel, C)). It would also work to produce an NxM or MxN
      % array from M cell elements each with N elements but different shapes.
      % if dim == 1
      %    V = cellfun(@(c) c(:), C, 'UniformOutput', false);
      % elseif dim == 2
      %    V = cellfun(@(c) c(:)', C, 'UniformOutput', false);
      % end
      % V = cat(dim, V{:});
   end

   % Reshape output according to the 'shape' parameter
   switch shape
      case 'row'
         V = V(:).';
      case 'column'
         V = V(:);
      case 'transpose'
         V = V.';
      otherwise
         % do nothing, inclusive of 'array'
   end
end

% % Cell2Vec is faster for very large cell arrays otherwise nearly identical
% V = Cell2Vec(C);
