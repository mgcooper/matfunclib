function [tf, tflatlon, tol] = isxyregular(x, y, varargin)
   %ISXYREGULAR Determine if the values in x and y are regularly spaced.
   %
   %  TF = isxyregular(X,Y) returns a logical scalar TF that is true if X and Y
   %  EACH have uniform spacing -- i.e. they form a uniform or regular grid, not
   %  an irregular one -- up to a relative tolerance. No check is made of the
   %  distance between X and Y values.
   %
   %  [TF,TFLATLON,TOL] = isxyregular(X,Y) also returns TFLATLON (true if X and Y
   %  are geographic coordinates) and TOL (retained for the legacy signature; see
   %  the note below).
   %
   %  isxyregular is a thin wrapper over libraster's canonical grid estimator
   %  mapGridCellSize/customIsUniform (relative-tolerance, mode-based cell size).
   %  The earlier bespoke round(diff(diff),tol) test was retired so the library
   %  has a SINGLE uniformity estimator. See matfunclib-jjo and, for the tolerance
   %  rationale, matfunclib-hfe.
   %
   % See also: mapGridCellSize, customIsUniform, mapGridInfo, isGeoGrid, isuniform

   % Delegate the uniformity decision to the canonical estimator: the grid is
   % "regular" when neither axis is irregular (GridType is 'uniform' or 'regular',
   % and 'point' for a degenerate single coordinate -- not 'irregular').
   [~, ~, gridType] = mapGridCellSize(x, y);
   tf = ~strcmp(gridType, 'irregular');

   % geographic vs planar
   tflatlon = islatlon(y, x);

   % TOL is kept only for backward compatibility with the [tf,tflatlon,tol]
   % signature. customIsUniform uses a RELATIVE tolerance internally, so this
   % absolute decimal value is nominal: an explicitly supplied tol no longer
   % affects the uniformity decision (which is now made by mapGridCellSize).
   if nargin > 2
      tol = varargin{1};
   elseif tflatlon
      tol = 7; % approximately 1 cm in units of degrees
   else
      tol = 2; % nearest cm
   end
end
