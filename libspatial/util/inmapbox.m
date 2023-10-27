function [in, x, y] = inmapbox(x, y, xlims, ylims)
   %INMAPBOX Find points inside a bounding box in planar coordinates.
   %
   % [IN, X, Y] = INMAPBOX(X, Y, XLIMS, YLIMS) returns a logical array IN that
   % indicates which points in the arrays X and Y are inside the bounding box
   % defined by XLIMS and YLIMS. The output arrays X and Y are subsets of the
   % input arrays that contain only the points within the bounding box.
   %
   %   Parameters:
   %   - X: array of x-coordinates
   %   - Y: array of y-coordinates
   %   - XLIMS: [xmin, xmax], limits in the x-dimension
   %   - YLIMS: [ymin, ymax], limits in the y-dimension
   %
   %   Outputs:
   %   - IN: logical array, true for points within the bounding box
   %   - X: array of x-coordinates within the bounding box
   %   - Y: array of y-coordinates within the bounding box
   %
   %   Example:
   %       x = [1, 2, 3, 4, 5];
   %       y = [1, 2, 3, 4, 5];
   %       xlims = [2, 4];
   %       ylims = [2, 4];
   %       [in, x, y] = inmapbox(x, y, xlims, ylims)
   %       % in = [0 1 1 1 0]
   %       % x = [2, 3, 4]
   %       % y = [2, 3, 4]
   %
   % See also: ingeobox

   in = ...
      x >= min (xlims) & ...
      x <= max (xlims) & ...
      y >= min (ylims) & ...
      y <= max (ylims) ;

   x = x(in) ;
   y = y(in) ;
end
