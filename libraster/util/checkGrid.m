function isRectangle = checkGrid(coords, tol)
   %CHECKGRID Test whether four corner coordinates form a rectangle.
   %
   %  TF = checkGrid(CORNERS) returns true if the 4x2 array CORNERS (one [x y]
   %  per row) forms a RECTANGLE of ANY orientation -- not just axis-aligned.
   %  This distinguishes a regular grid CELL (a rectangle, possibly ROTATED, as
   %  produced when a lon/lat grid is reprojected to a rotated-pole or other CRS)
   %  from a curvilinear / sheared cell (not a rectangle). The mapGrid* family
   %  classifies a rotated-but-regular grid as 'irregular' because its lon/lat
   %  spacing is non-uniform; checkGrid is the geometric test that recognizes the
   %  cell is still a rectangle.
   %
   %  TF = checkGrid(CORNERS, TOL) sets the relative tolerance (default 1e-6 of
   %  the diagonal length) for the equality checks.
   %
   %  Method: a quadrilateral is a rectangle iff its diagonals are equal in
   %  length AND bisect each other (share a midpoint). The corners are first
   %  ordered cyclically (by angle about their centroid) so the test works for
   %  any input ordering, and it avoids the degenerate vertical-edge (Inf slope)
   %  and opposite-sign-diagonal pitfalls of a slope-based test.
   %
   % See also: gridCellCorners, mapGridCellSize, isxyregular
   %
   % NOTE: poorly named (it tests a single cell/quad, not a whole grid); a better
   % name would be e.g. isRectangleCell. See the libraster bead before renaming
   % (callers may live in commented-out code).

   narginchk(1, 2)
   if nargin < 2 || isempty(tol)
      tol = 1e-6;
   end
   validateattributes(coords, {'numeric'}, {'size', [4, 2], 'real', 'finite'}, ...
      mfilename, 'coords', 1)

   % Order the corners cyclically (CCW by angle about the centroid) so opposite
   % corners are (1,3) and (2,4) regardless of the input ordering.
   c = mean(coords, 1);
   [~, order] = sort(atan2(coords(:, 2) - c(2), coords(:, 1) - c(1)));
   coords = coords(order, :);

   % Diagonals connect opposite corners.
   d1 = coords(3, :) - coords(1, :);
   d2 = coords(4, :) - coords(2, :);
   mid1 = (coords(1, :) + coords(3, :)) / 2;
   mid2 = (coords(2, :) + coords(4, :)) / 2;

   scale = max([norm(d1), norm(d2), eps]);
   sameMidpoint   = norm(mid1 - mid2)         <= tol * scale;  % parallelogram
   equalDiagonals = abs(norm(d1) - norm(d2))  <= tol * scale;  % => rectangle

   isRectangle = sameMidpoint && equalDiagonals;
end
