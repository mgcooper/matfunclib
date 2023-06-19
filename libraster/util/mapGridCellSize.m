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

% NOTE: X,Y can be vectors or matrices, but if vectors, no check is made for
% grid vectors vs coordinate pairs which means structured grids need to come in
% unique otherwise cellsize = 0 will occur, whereas irregular / unstructured
% grids will be treated the same i.e. as pairs of coordinates.

% UPDATE: I think the key is for the uniformity check, pass in unique(X(:)), and
% elsewhere, do or don't depending on whether arrays, vectors, lists etc are
% expected. For example, a coordinate pair list will have non-unique values but
% could still be regular / uniform. And for uniformity, we don't need the
% unique([X Y],'rows') check we would need for coordinate lists elsewhere.
% BUT note that unique(X(:)) returns sorted order, so it wont work fo
% unstructured grids, for that would need unique(X(:),'stable') ... need to
% revisit

   if verLessThan('matlab', '9.13')
      [xIsUniform, cellSizeX] = customIsUniform(unique(X(:)));
      [yIsUniform, cellSizeY] = customIsUniform(unique(Y(:)));
   else
      [xIsUniform, cellSizeX] = isuniform(unique(X(:)));
      [yIsUniform, cellSizeY] = isuniform(unique(Y(:)));
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
      
      % Moved the simple case here to ismatrix to support irregular
      if ~isvector(X) && ~isvector(Y)
         
         % Might simplify this by converting to grid vectors
         cellSizeX = diff(X, 1, 2);
         cellSizeY = diff(Y, 1, 1);
         
         if nnz(diff(cellSizeX,1))==0 % allrowsequal
            cellSizeX = cellSizeX(1,:);
         end
         
         if nnz(diff(cellSizeY,2))==0 % allcolsequal
            cellSizeY = cellSizeY(:,1);
         end
         
      else
         
         % Here and next isn't really right, to know te actual grid size I need
         % ot know the vertices or the edges of the first or last
         cellSizeX = diff(X);
         cellSizeY = diff(Y);
      end
         
      cellSizeX = [cellSizeX(1); cellSizeX];
      cellSizeY = [cellSizeY(1); cellSizeY];

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