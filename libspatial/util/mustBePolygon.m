function mustBePolygon(P)
   % mustBePolygon validates input as a polygon representation
   %
   % Input can be a polyshape, Nx2 numeric matrix, or cell array containing
   % one or more valid polygon representations.
   %
   % Example use in argument block validation:
   %
   % arguments
   %     P { mustBePolygon(P) };
   % end
   %
   % See also:

   % Flag for validation success
   tf = true;

   % Check for cell arrays first
   if iscell(P)
      % Check if cell contains polyshapes
      if all(cellfun(@(x) isa(x, 'polyshape'), P))
         % P is a cell array of polyshapes
         return;

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

   % Throw an error if the validation failed
   if ~tf
      eid = 'custom:validators:mustBePolygon';
      msg = 'Value must be a polyshape, Nx2 numeric matrix, or valid cell array.';
      throwAsCaller(MException(eid, msg));
   end
end
