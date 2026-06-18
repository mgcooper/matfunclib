function varargout = defaultGridData(option)
   %DEFAULTGRIDDATA Generate (or plot) default gridded test data.
   %
   %  [X, Y]       = defaultGridData()
   %  [X, Y, Z]    = defaultGridData()
   %  [X, Y, Z, R] = defaultGridData()
   %  defaultGridData('plot')
   %
   % Derives the grid coordinates from the bundled example raster
   % (example_cells.tif) on the fly, so callers and tests do not depend on a saved
   % gridded.mat. Requires the Mapping Toolbox (readgeoraster) and example_cells.tif
   % on the path.
   %
   % See also: validateGridData, plotraster, R2grid

   arguments
      option (1, :) char {mustBeMember(option, {'data', 'plot'})} = 'data'
   end

   % Read the example raster and derive the cell-center grid coordinates.
   [Z, R] = readgeoraster('example_cells.tif');
   [X, Y] = R2grid(R);

   % Optionally display it (still returns the data, as before).
   if strcmp(option, 'plot')
      plotraster(Z, X, Y)
   end

   [varargout{1:nargout}] = dealout(X, Y, Z, R);
end
