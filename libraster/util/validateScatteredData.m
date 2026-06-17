function [V, X, Y] = validateScatteredData(V, X, Y, funcname)
   %VALIDATESCATTEREDDATA Validate scattered (irregular) X, Y, V for interpolation.
   %
   % [V, X, Y] = validateScatteredData(V, X, Y)
   % [V, X, Y] = validateScatteredData(V, X, Y, funcname)
   %
   % Lightweight check for scattered/irregular coordinate data: returns X and Y
   % as column vectors and V with one row per (X, Y) point, so the values can be
   % passed straight to scatteredInterpolant. Unlike validateGridData this does
   % NOT require X, Y to form a recognized grid.
   %
   % See also: validateGridData, scatteredInterpolation, scatteredInterpolant

   % Default the function name (used in error messages) to the caller.
   if nargin < 4 || isempty(funcname); funcname = mcallername(); end

   validateattributes(X, {'numeric'}, {'real', 'nonempty'}, funcname, 'X');
   validateattributes(Y, {'numeric'}, {'real', 'nonempty'}, funcname, 'Y');
   validateattributes(V, {'numeric', 'logical'}, {'real', '2d'}, funcname, 'V');

   X = X(:);
   Y = Y(:);
   n = numel(X);

   assert(numel(Y) == n, sprintf('custom:%s:inconsistentXY', funcname), ...
      '%s expected X and Y to have the same number of points.', upper(funcname));

   % Accept V as a row matching the points (one sample per point) and reorient it
   % to a column; otherwise the first dimension must match X, Y.
   if isrow(V) && numel(V) == n
      V = V(:);
   end
   assert(size(V, 1) == n, sprintf('custom:%s:inconsistentXYV', funcname), ...
      '%s expected V to have one row per (X, Y) point.', upper(funcname));
end
