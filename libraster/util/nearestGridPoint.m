function [row, col, dist] = nearestGridPoint(X, Y, XQ, YQ)
   % Function to find the nearest grid point to a specified latitude and longitude
   %
   % Inputs:
   %   latGrid: Matrix of latitude values
   %   lonGrid: Matrix of longitude values
   %   latVal: Target latitude
   %   lonVal: Target longitude
   %
   % Outputs:
   %   rowIndex: The row index of the closest grid point
   %   colIndex: The column index of the closest grid point
   %
   % See also: findnearby

   % Convert vectors to a grid if necessary
   [X, Y] = fullgrid(X, Y);

   % Calculate the Euclidean distance from each grid point to the target point
   distances = sqrt((Y - YQ).^2 + (X - XQ).^2);

   % Find the index of the minimum distance
   [dist, indx] = min(distances(:));

   % Convert linear index to subscript indices
   [row, col] = ind2sub(size(Y), indx);
end
