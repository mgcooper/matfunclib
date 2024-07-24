function [coord1, coord2] = cellsToCoords(cell1, cell2)
   %CELLSTOCOORDS Convert line or polygon parts from cell arrays to vectors
   %
   %   [COORD1,COORD2] = CELLSTOCOORDS(CELL1,CELL2) converts polygons from cell
   %   array format to column vector format. In cell array format, each element
   %   of the cell array is a vector that defines a separate polygon. A polygon
   %   may consist of an outer contour followed by holes separated with NaNs. In
   %   vector format, each vector may contain multiple faces separated by NaNs.
   %   There is no structural distinction between outer contours and holes in
   %   vector format.
   %
   %   This function makes no distinction between X and Y versus Lat and Lon.
   %   The coordinate cells can be provided in either order, but they are
   %   returned in the same order they are provided.
   %
   % See also: coordsToCells

   if isempty(cell1) && isempty(cell2)
      coord1 = reshape([], [0 1]);
      coord2 = coord1;
   else
      validateattributes(cell1,{'cell'},{'vector'},mfilename,'CELL1',1)
      validateattributes(cell2,{'cell'},{'vector'},mfilename,'CELL2',2)

      assert(isequal(size(cell1),size(cell2)), ...
         ['libspatial:' mfilename ':cellvectorSizeMismatch'], ...
         '%s and %s must match in size.', ...
         'CELL1', 'CELL2')

      latSizes = cellfun(@size, cell1, 'UniformOutput', false);
      lonSizes = cellfun(@size, cell2, 'UniformOutput', false);

      assert(isequal(latSizes,lonSizes), ...
         ['libspatial:' mfilename ':cellContentSizeMismatch'], ...
         'Contents of corresponding cells in %s and %s must match in size.', ...
         'CELL1', 'CELL2')

      % The conversion to vector assumes each element of the input cell arrays
      % is a vector. This checks if the inputs are cell arrays with each element
      % defining a single coordinate. The case where each element is a cell
      % array is not handled.
      if all(cellfun(@isscalar, cell2)) && all(cellfun(@isscalar, cell1))

         if isShapeMultipart([cell2{:}], [cell1{:}])
            % Convert to a cell array with one vector element
            cell1 = {[cell1{:}]};
            cell2 = {[cell2{:}]};
         else
            coord1 = [cell1{:}];
            coord2 = [cell2{:}];
            return
         end
      end

      % Check if the polygons are already nan-separated
      hassep = cellfun(@(x, y) isnan(x(end)) && isnan(y(end)), cell2, cell1);

      if sum(hassep) == numel(cell1)
         coord1 = Cell2Vec(cell1);
         coord2 = Cell2Vec(cell2);

         % Check if coordsToCells can recover the original cells. This will fail
         % if individual elements of the geostruct have multiple polygons. To
         % ensure it recovers them, coordsToCells would somehow need to know
         % which elements unpacked in here were originally in the same element.
         %
         % [latcells2, loncells2] = coordsToCells(lat, lon);
      end

      M = numel(cell1);
      N = 0;
      for k = 1:M
         N = N + numel(cell1{k});
      end

      coord1 = zeros(N + M - 1, 1);
      coord2 = zeros(N + M - 1, 1);
      p = 1;
      for k = 1:(M-1)
         q = p + numel(cell1{k});
         coord1(p:(q-1)) = cell1{k};
         coord2(p:(q-1)) = cell2{k};
         coord1(q) = NaN;
         coord2(q) = NaN;
         p = q + 1;
      end
      if M > 0
         coord1(p:end) = cell1{M};
         coord2(p:end) = cell2{M};
      end
   end
end
