function V = cellflatten(C, dim, shape)
   %CELLFLATTEN Flatten cell array contents along a specified dimension.
   %
   % Syntax:
   %  V = CELLFLATTEN(C)
   %  V = CELLFLATTEN(C, dim)
   %  V = CELLFLATTEN(C, dim, shape)
   % 
   %  V = CELLFLATTEN(C) concatenates the contents of cell array C along the
   %  first dimension that allows for concatenation. This is either horizontal
   %  or vertical concatenation depending on the dimensions of the cell
   %  contents.
   %
   %  V = CELLFLATTEN(C, DIM) concatenates along the dimension specified by DIM.
   %
   %  V = CELLFLATTEN(C, DIM, SHAPE) returns the concatenated output reshaped
   %  according to the value of SHAPE. Valid options for SHAPE are 'row',
   %  'column', and 'array'.
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
   validatestring(shape, {'row', 'column', 'array'}, mfilename, 'SHAPE', 3);

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
      % Below might be enough to fix it, but maybe a recursive call to this
      % function would work too? 
      % if dim == 1
      %    V = cellfun(@(x) x(:), xdata, 'UniformOutput', false);
      % elseif dim == 2
      %    V = cellfun(@(x) x(:)', xdata, 'UniformOutput', false);
      % end
      % V = cat(dim, V{:});
   end

   % Reshape output according to the 'shape' parameter
   switch shape
      case 'row'
         V = V(:).';
      case 'column'
         V = V(:);
      otherwise
         % do nothing, inclusive of 'array'
   end
end

% % Cell2Vec is faster for very large cell arrays otherwise nearly identical
% V = Cell2Vec(C);
