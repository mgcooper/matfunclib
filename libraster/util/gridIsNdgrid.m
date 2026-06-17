function tf = gridIsNdgrid(X, Y)
   %GRIDISNDGRID True if a full grid is in ndgrid (not meshgrid) orientation.
   %
   %  tf = gridIsNdgrid(X, Y) returns true if the 2-D coordinate arrays X, Y are
   %  laid out in NDGRID orientation -- X varies down dim 1 (rows) and Y across
   %  dim 2 (columns) -- which is the TRANSPOSE of MATLAB's meshgrid convention
   %  (X across columns, Y down rows). libraster's grid machinery assumes meshgrid
   %  orientation (gridvec/fullgrid treat size(X,2) as the X axis), so
   %  prepareMapGrid uses this to transpose ndgrid input to meshgrid first.
   %
   %  Detection is gradient-based -- which dimension each coordinate varies along
   %  -- NOT array-shape-based, so it also resolves SQUARE grids, where the shape
   %  alone is ambiguous (a 4x4 meshgrid and a 4x4 ndgrid have the same size).
   %  Robustness:
   %    * NaNs are ignored (RCM grids often carry NaN borders);
   %    * X's verdict is corroborated by Y (they must indicate opposite dominant
   %      axes), so a single noisy axis cannot flip the result;
   %    * a genuinely ambiguous grid -- e.g. a ~45-degree-rotated curvilinear grid
   %      whose row and column gradients are equal -- returns false, i.e. is left
   %      as meshgrid (the safe default that preserves existing behavior).
   %
   %  Limitation: for a truly rotated/curvilinear grid the dominant-gradient guess
   %  can be wrong, but such a grid is non-separable and is rejected downstream as
   %  'irregular' regardless of orientation, so a wrong guess here does not produce
   %  wrong values. For a rectilinear grid (the case that matters) one gradient is
   %  ~0, so the verdict is unambiguous.
   %
   % Example
   %   [Xn, Yn] = ndgrid(1:4, 1:7);   gridIsNdgrid(Xn, Yn)   % true
   %   [Xm, Ym] = meshgrid(1:4, 1:7); gridIsNdgrid(Xm, Ym)   % false
   %
   % See also: prepareMapGrid, orientMapGrid, meshgrid, ndgrid

   % Only a 2-D full grid (both dims >= 2, equal-size X and Y) has an orientation
   % to resolve; vectors, coordinate lists, and scalars do not.
   if ~ismatrix(X) || ~ismatrix(Y) || ~isequal(size(X), size(Y)) ...
         || isvector(X) || any(size(X) < 2)
      tf = false;
      return
   end

   % Mean absolute variation of each coordinate down rows (dim 1) vs across
   % columns (dim 2), ignoring NaNs.
   xDownRows   = mean(abs(diff(X, 1, 1)), 'all', 'omitnan');
   xAcrossCols = mean(abs(diff(X, 1, 2)), 'all', 'omitnan');
   yDownRows   = mean(abs(diff(Y, 1, 1)), 'all', 'omitnan');
   yAcrossCols = mean(abs(diff(Y, 1, 2)), 'all', 'omitnan');

   % ndgrid: X varies mainly down rows AND Y varies mainly across columns. Require
   % both to agree and neither axis to be an exact tie (the ~45-degree case).
   xSaysNdgrid = xDownRows > xAcrossCols;
   ySaysNdgrid = yAcrossCols > yDownRows;
   noTie = (xDownRows ~= xAcrossCols) && (yDownRows ~= yAcrossCols);

   tf = xSaysNdgrid && ySaysNdgrid && noTie;
end
