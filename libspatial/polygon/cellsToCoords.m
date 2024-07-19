function [lat,lon] = cellsToCoords(latcells,loncells)
   %CELLSTOCOORDS Convert line or polygon parts from cell arrays to vectors
   %
   %   [LAT,LON] = CELLSTOCOORDS(LATCELLS,LONCELLS) converts polygons from cell
   %   array format to column vector format.  In cell array format, each
   %   element of the cell array is a vector that defines a separate polygon.
   %   A polygon may consist of an outer contour followed by holes separated
   %   with NaNs.  In vector format, each vector may contain multiple faces
   %   separated by NaNs.  There is no structural distinction between outer
   %   contours and holes in vector format.
   %
   % See also: coordsToCells

   if isempty(latcells) && isempty(loncells)
      lat = reshape([], [0 1]);
      lon = lat;
   else
      validateattributes(latcells,{'cell'},{'vector'},mfilename,'LATCELLS',1)
      validateattributes(loncells,{'cell'},{'vector'},mfilename,'LONCELLS',2)

      assert(isequal(size(latcells),size(loncells)), ...
         ['libspatial:' mfilename ':cellvectorSizeMismatch'], ...
         '%s and %s must match in size.', ...
         'LATCELLS', 'LONCELLS')

      latSizes = cellfun(@size, latcells, 'UniformOutput', false);
      lonSizes = cellfun(@size, loncells, 'UniformOutput', false);

      assert(isequal(latSizes,lonSizes), ...
         ['libspatial:' mfilename ':cellContentSizeMismatch'], ...
         'Contents of corresponding cells in %s and %s must match in size.', ...
         'LATCELLS', 'LONCELLS')

      % The conversion to vector assumes each element of the input cell arrays
      % is a vector. This checks if the inputs are cell arrays with each element
      % defining a single coordinate. The case where each element is a cell
      % array is not handled.
      if all(cellfun(@isscalar, loncells)) && all(cellfun(@isscalar, latcells))

         if isShapeMultipart([loncells{:}], [latcells{:}])
            % Convert to a cell array with one vector element
            latcells = {[latcells{:}]};
            loncells = {[loncells{:}]};
         else
            lat = [latcells{:}];
            lon = [loncells{:}];
            return
         end
      end

      % Check if the polygons are already nan-separated
      hassep = cellfun(@(x, y) isnan(x(end)) && isnan(y(end)), loncells, latcells);

      if sum(hassep) == numel(latcells)
         lat = Cell2Vec(latcells);
         lon = Cell2Vec(loncells);

         % Check if coordsToCells can recover the original cells. This will fail
         % if individual elements of the geostruct have multiple polygons. To
         % ensure it recovers them, coordsToCells would somehow need to know
         % which elements unpacked in here were originally in the same element.
         %
         % [latcells2, loncells2] = coordsToCells(lat, lon);
      end

      M = numel(latcells);
      N = 0;
      for k = 1:M
         N = N + numel(latcells{k});
      end

      lat = zeros(N + M - 1, 1);
      lon = zeros(N + M - 1, 1);
      p = 1;
      for k = 1:(M-1)
         q = p + numel(latcells{k});
         lat(p:(q-1)) = latcells{k};
         lon(p:(q-1)) = loncells{k};
         lat(q) = NaN;
         lon(q) = NaN;
         p = q + 1;
      end
      if M > 0
         lat(p:end) = latcells{M};
         lon(p:end) = loncells{M};
      end
   end
end
