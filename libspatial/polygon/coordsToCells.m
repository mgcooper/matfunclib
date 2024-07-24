function [cells1, cells2] = coordsToCells(coord1, coord2)
   %COORDSTOCELLS Convert nan-separated polygon parts from vectors to cells
   %
   %   [CELLS1,CELLS2] = COORDSTOCELLS(COORD1,COORD2) returns the NaN-delimited
   %   segments of the vectors COORD1 and COORD2 as N-by-1 cell arrays with one
   %   polygon segment per cell. COORD1 and COORD2 must be the same size and
   %   have identically-placed NaNs. The polygon segments are column vectors if
   %   COORD1 and COORD2 are column vectors, and row vectors otherwise.
   %
   %   This function makes no distinction between X and Y versus Lat and Lon.
   %   The coordinate cells can be provided in either order, but they are
   %   returned in the same order they are provided.
   %
   % See also: cellsToCoords

   if isempty(coord1) && isempty(coord2)
      cells1 = reshape({}, [0 1]);
      cells2 = cells1;
   else
      validateattributes(coord1,{'numeric'},{'real','vector'},mfilename,'COORD1',1)
      validateattributes(coord2,{'numeric'},{'real','vector'},mfilename,'COORD2',2)

      [coord1, coord2] = rmnansep(coord1, coord2);

      % Find NaN locations.
      I = find(isnan(coord1(:)));

      % Simulatee the trailing NaN if it's missing.
      if ~isempty(coord1) && ~isnan(coord1(end))
         I(end+1,1) = numel(coord1) + 1;
      end

      % Extract each segment into pre-allocated N-by-1 cell arrays, where N is
      % the number of polygon segments. (Add a leading zero to the indx array
      % to make indexing work for the first segment.)
      N = numel(I);
      I = [0; I];
      cells1 = arrayfun(@(n) coord1( I(n)+1:I(n+1)-1 ), 1:N, 'un', 0);
      cells2 = arrayfun(@(n) coord2( I(n)+1:I(n+1)-1 ), 1:N, 'un', 0);
   end
end

function [x,y,v] = rmnansep(x,y,v)
   n = isnan(x(:));
   extranan = n & [true; n(1:end-1)];
   x(extranan) = [];
   y(extranan) = [];
   if nargin >= 3
      v(extranan) = [];
   end
end
