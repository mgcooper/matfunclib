function [gridType, cellSizeX, cellSizeY, tfGeoCoords] = mapGridInfo(X, Y)
%MAPGRIDINFO Determine the structured grid type, cell size, and if it is geographic
%
% [gridType, cellSizeX, cellSizeY, tfGeo] = mapGridInfo(X, Y) returns the type
% of the grid ('uniform', 'regular', 'irregular'), the cell size in the X and Y
% direction, and a boolean flag to indicate if the coordinates are geographic.  
% 
% 'uniform': Both x and y are uniformly spaced and have the same step size.
% 'regular': Both x and y are uniformly spaced but have different step sizes.
% 'irregular': Neither x nor y is uniformly spaced.
%
% Matt Cooper, 11-Mar-2023, https://github.com/mgcooper
% 
% See also prepareMapGrid, orientMapGrid, mapGridCellSize, isGeoGrid

   % Convert input formats to grid vectors. Don't alter coordinate lists.
   if (ismatrix(X) && ~isvector(X) && size(X) == size(Y)) || ...  % grid arrays
      (isvector(X) &&  isvector(Y) && size(X) ~= size(Y))         % grid vectors
      
      X = unique(X(:),'sorted');
      Y = unique(Y(:),'sorted');
      
   elseif (isvector(X) &&  isvector(Y)) % coordinate lists (or equal sized grid vectors)
      
      % Remove duplicate coordinate pairs
      ok = unique([X(:),Y(:)],'rows');
      X = X(ok);
      Y = Y(ok);
      
   else % one must be a scalar or some other unsupported type
      % error message
   end
   
   % Determine the cell size in the X and Y direction and the grid type
   [cellSizeX, cellSizeY, gridType] = mapGridCellSize(X, Y);
   
   % Determine if the coordinates are geographic and if X,Y are Lat,Lon
   tfGeoCoords = isGeoGrid(Y, X);
   
   % Note: To determine if the coordinates are geographic and if X,Y are Lat,Lon
   % [tfGeoCoords,tfLatLonOrder] = isGeoGrid(X, Y);
   % [tfGeoCoords,~] = isGeoGrid(X, Y); % this works too

end

% % % This might not have anything worth keeping, but it was designed to do what
% % the above two do without the call to isuniform
% 
% function [gridType, isGeographic, tol] = determineGridType(X, Y)
% %DETERMINEGRIDTYPE Determine the type of grid and if it is geographic
% %
% % [gridType, isGeographic] = determineGridType(X, Y) returns the type
% % of the grid ('uniform', 'regular', 'structured', 'unstructured') and
% % a boolean flag to indicate if the coordinates are geographic. The function
% % handles the cases where X and Y are grid vectors, arrays, or coordinate pairs
% % in list format. In each case, X and Y are assumed to represent grid center
% % coordinates 
% % 
% % See also
% 
% % Default values
% gridType = 'unknown';
% isGeographic = false;
% 
% % Tolerances
% tol = 1e-6;
% lat_tol = 90;
% lon_tol = 180;
% 
% % Check if X and Y are grid vectors
% if isvector(X) && isvector(Y)
%    x_spacing = diff(X(:));
%    y_spacing = diff(Y(:));
% 
%    % Check if X and Y are regular
%    if all(abs(diff(x_spacing)) < tol) && all(abs(diff(y_spacing)) < tol)
%       gridType = 'regular';
% 
%       % Check if X and Y are uniform
%       if abs(x_spacing(1) - y_spacing(1)) < tol
%          gridType = 'uniform';
%       end
%    end
%    % Check if X and Y are arrays
% elseif ismatrix(X) && ismatrix(Y) && all(size(X) == size(Y))
%    % Compute spacing for rows and columns
%    x_spacing_col = diff(X, 1, 2);
%    x_spacing_row = diff(X, 1, 1);
%    y_spacing_col = diff(Y, 1, 2);
%    y_spacing_row = diff(Y, 1, 1);
% 
%    % Check if X and Y are structured
%    if all(abs(diff(x_spacing_col(:))) < tol) && ...
%          all(abs(diff(x_spacing_row(:))) < tol) && ...
%          all(abs(diff(y_spacing_col(:))) < tol) && ...
%          all(abs(diff(y_spacing_row(:))) < tol)
% 
%       gridType = 'structured';
%    end
%    % Check if X and Y are coordinate pairs in list format
% elseif size(X, 2) == 2 && size(Y, 2) == 2 && all(size(X) == size(Y))
%    X = reshape(X, [size(X, 1), 1, size(X, 2)]);
%    Y = reshape(Y, [size(Y, 1), 1, size(Y, 2)]);
%    x_spacing = squeeze(diff(X, 1, 3));
%    y_spacing = squeeze(diff(Y, 1, 3));
% 
%    % Check if X and Y are regular
%    if all(abs(diff(x_spacing)) < tol) && all(abs(diff(y_spacing)) < tol)
%       gridType = 'regular';
% 
%       % Check if X and Y are uniform
%       if abs(x_spacing(1) - y_spacing(1)) < tol
%          gridType = 'uniform';
%       end
%    end
% end
% 
% % Check if the coordinates are geographic
% if all( X(:) >= -lon_tol & X(:) <= lon_tol ) && ...
%    all( Y(:) >= -lat_tol & Y(:) <= lat_tol )
%    isGeographic = true;
% end
% 
% end