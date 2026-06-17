function [tf, cellsize] = customIsUniform(x, reltol)
   %CUSTOMISUNIFORM Determine if data is uniformly spaced (relative tolerance).
   %
   % [tf, cellsize] = customIsUniform(x) returns tf = true if the spacing of x is
   % uniform to within a RELATIVE tolerance (default 1e-3 of the cell size), and
   % returns the (signed) cell size.
   %
   % [tf, cellsize] = customIsUniform(x, reltol) sets the relative tolerance.
   %
   % A relative tolerance (fraction of the cell size) is used rather than an
   % absolute one so that real coordinate axes carrying float32 STORAGE jitter are
   % accepted while genuinely irregular axes are rejected. For example, a netCDF
   % MAR/RACMO 15 km polar-stereo axis has spacing that varies ~1e-6 of a cell
   % (float32 noise -> accept), whereas the same grid reprojected (~8e-2) or the
   % curvilinear lon/lat (~2e0) vary far more (reject). reltol ~1e-3 separates the
   % two with several orders of margin. See bug matfunclib-hfe.
   %
   % NOTE: pass a sorted axis vector (e.g. unique(X(:))). If the data is known to
   % be a 2-d grid oriented correctly, diff the appropriate dimension instead
   % (diff(X,1,2), diff(Y,1,1)).

   if nargin < 2 || isempty(reltol)
      reltol = 1e-3;
   end

   x = x(:);
   if numel(x) < 2
      tf = false;
      cellsize = NaN;
      return
   end

   celldiffs = diff(x);

   % Robust (signed) cell size: the mode of the non-zero diffs, so repeated
   % coordinates (diff == 0, e.g. when a flattened grid is passed) do not skew it.
   nz = celldiffs(celldiffs ~= 0);
   if isempty(nz)
      tf = false;       % all coordinates identical: not a usable axis
      cellsize = NaN;
      return
   end
   cellsize = mode(nz);

   % Relative tolerance, with a tiny absolute floor (4*eps of the largest
   % magnitude) so the check stays well-defined for near-zero cell sizes and for
   % pure round-off when the cell size itself is small.
   tol = max(reltol * abs(cellsize), 4 * eps(max(abs(x(1)), abs(x(end)))));

   % Ignore near-zero diffs (repeated coordinates); require the remaining spacings
   % to match the cell size within tol.
   keep = abs(celldiffs) > tol;
   tf = all(abs(celldiffs(keep) - cellsize) <= tol);
end
