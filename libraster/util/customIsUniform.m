function [tf, cellsize] = customIsUniform(x, tol)
   %ISUNIFORM Determine if data is uniformly spaced.

   % NOTE: If this is called by passing X(:) it may fail. If the data is known
   % to be 2d spatial and oriented correctly, then diff(X,1,2) and diff(Y,1,1)
   % are better checks.

   if nargin < 2
      tol = max(1e-10, 4 * eps(max(abs(x(1)), abs(x(end)))));
   end

   if numel(x) < 2
      tf = false;
      cellsize = NaN;
      return;
   end

   celldiffs = diff(x);

   % March 2024 - use abs and >0 to eliminate diffs which equal zero when there
   % are many repeat elements, so mode is a better estimate.

   % Only consider diffs larger than tol, but index into the non-absolute valued
   % celldiffs to maintain the sign of the mode.
   cellsize = mode(celldiffs(abs(celldiffs) > tol)); % was celldiffs(1)

   tf = all( abs(celldiffs(abs(celldiffs) > tol)) - abs(cellsize) <= tol);

   % all(abs(diff(x_spacing)) < tol) && all(abs(diff(y_spacing)) < tol)

   % If this is failing on a known case, say there's a large portion of the data
   % which is essentially equal but the diffs are still >1e-8. If they're all
   % eliminated, what remains is the data which actually differs. The final tf
   % check differences them from teh cellsize. here, the tol may not be the best
   % check because the cellsize is the mode of the diffs, so it's no longer a
   % numeric precision issue. But not sure how to solve this.
   % checkdiffs = abs(celldiffs(absdiffs > tol) - abs(cellsize));
end
