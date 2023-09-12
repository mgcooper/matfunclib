function [tf, cellsize] = customIsUniform(x)
   %ISUNIFORM Determine if data is uniformly spaced.
   if numel(x) < 2
      tf = false;
      cellsize = NaN;
      return;
   end

   celldiffs = diff(x);
   cellsize = mode(celldiffs); % was celldiffs(1)
   tol = max(1e-10, 4 * eps(max(abs(x(1)), abs(x(end)))));

   tf = all(abs(celldiffs - cellsize) <= tol);

   % all(abs(diff(x_spacing)) < tol) && all(abs(diff(y_spacing)) < tol)
end
