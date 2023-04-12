function [cellSizeX, cellSizeY, gridType] = mapGridCellSize(X, Y)
%MAPGRIDCELLSIZE Determine the cell size in the X and Y direction and grid type.
%
% [cellSizeX, cellSizeY, gridType] = mapGridCellSize(X, Y) returns the cell size
% in the X and Y direction for coordinate vectors or arrays X and Y, and the
% grid type ('uniform', 'regular', 'irregular'). If either X or Y is not
% regularly spaced, the corresponding cell size value will be NaN.
%
% Grid type definitions:
% 
% 'uniform': Both x and y are uniformly spaced and have the same step size.
% 'regular': Both x and y are uniformly spaced but have different step sizes.
% 'irregular': Neither x nor y is uniformly spaced.
% 
% Matt Cooper, 11-Mar-2023, https://github.com/mgcooper
% 
% See also mapGridInfo, prepareMapGrid, orientMapGrid

   if verLessThan('matlab', '9.13')
      [xIsUniform, cellSizeX] = customIsUniform(X);
      [yIsUniform, cellSizeY] = customIsUniform(Y);
   else
      [xIsUniform, cellSizeX] = isuniform(X);
      [yIsUniform, cellSizeY] = isuniform(Y);
   end
   
   % Determine grid type and cell size
   if xIsUniform && yIsUniform
      if cellSizeX == cellSizeY
         gridType = 'uniform';
      else
         gridType = 'regular';
      end
   else
      gridType = 'irregular';
      cellSizeX = diff(X, 1, 2);
      cellSizeY = diff(Y, 1, 1);
      
      if nnz(diff(cellSizeX,1))==0 % allrowsequal
         cellSizeX = cellSizeX(1,:);
      end
      
      if nnz(diff(cellSizeY,2))==0 % allcolsequal
         cellSizeY = cellSizeY(:,1);
      end
      
      % cellSizeX = NaN;
      % cellSizeY = NaN;
   end
   
end
   
function [tf, cellsize] = customIsUniform(x)
   if numel(x) < 2
      tf = false;
      cellsize = NaN;
      return;
   end
   
   celldiffs = diff(x);
   cellsize = celldiffs(1);
   tol = 4 * eps(max(abs(x(1)), abs(x(end))));
   
   tf = all(abs(celldiffs - cellsize) <= tol);
   
   % all(abs(diff(x_spacing)) < tol) && all(abs(diff(y_spacing)) < tol)
end


% function [cellsizeX,cellsizeY,tfGeo,tol] = mapgridcellsize(X,Y)
% 
% % determine if the data are planar or geographic
% tfGeo = isGeographic(X(1,1),Y(1,1));
% 
% % get an estimate of the grid resolution (i.e. the grid cell size)
% xres = diff(X(1,:));
% yres = diff(Y(:,1));
% 
% % check that the gridding is uniform.
% if tfGeo
%    tol = 7; % approximately 1 cm in units of degrees
% else
%    % tol = 2; % nearest cm
%    tol = 0; % nearest m (changed for MAR)
% end
% 
% % round to tol and take second derivative, should == 0 everywhere
% assert(all(round(diff(abs(xres),2),tol)==0), ...
%    ['Input argument 1, X, must have uniform grid spacing. ' ...
%    'You might need to round the X/Y or LON/LAT grids ' ...
%    'to a uniform precision']);
% assert(all(round(diff(abs(yres),2),tol)==0), ...
%    ['Input argument 2, Y, must have uniform grid spacing. ' ...
%    'You might need to round the X/Y or LON/LAT grids ' ...
%    'to a uniform precision']);
% 
% % return the cell size
% cellsizeX = abs(xres(1));
% cellsizeY = abs(yres(1));
% % cellsize = [cellsizeX, cellsizeY];