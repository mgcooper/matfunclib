function tf = ispolygon(P)
   %ISPOLYGON Determine if input is polygon-like.
   %
   %  tf = ispolygon(P)
   %
   % See also:

   tf = true;

   % Check for cell arrays first
   if iscell(P)
      % Check if cell contains polyshapes
      if all(cellfun(@(x) isa(x, 'polyshape'), P))
         % P is a cell array of polyshapes
         return

      elseif size(P, 2) == 2
         % P is a 2D cell array with Nx2 structure
         validateattributes(P, {'cell'}, {'2d'}, 'mustBePolygon', 'P', 4);

         % Further checks to ensure elements are valid polygon structures
         tf = all(cellfun(@(x, y) isnumeric(x) && isnumeric(y) && ...
            length(x) == length(y), ...
            P(:, 1), P(:, 2)));

      else
         % P is an Nx1 cell array where each element is an Nx2 numeric matrix
         tf = all(cellfun(@(c) isnumeric(c) && size(c, 2) == 2 && ...
            all(c(:, 1) == c(:, 2)), P));
      end

   elseif ismatrix(P)
      % Check if P is a polyshape or Nx2 numeric matrix
      tf = isa(P, 'polyshape') || (size(P, 2) == 2 && isnumeric(P) && ...
         all(size(P(:, 1)) == size(P(:, 2))));
   end
end
