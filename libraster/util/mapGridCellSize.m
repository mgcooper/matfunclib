function [cellSizeX, cellSizeY, gridType] = mapGridCellSize(X, Y, varargin)
   %MAPGRIDCELLSIZE Determine cell size in the X and Y direction and grid type.
   %
   % [cellSizeX, cellSizeY, gridType] = mapGridCellSize(X, Y) returns the cell
   % size in the X and Y direction for coordinate vectors or arrays X and Y, and
   % the grid type ('uniform', 'regular', 'irregular'). If either X or Y is not
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
   % See also: mapGridInfo, prepareMapGrid, orientMapGrid

   % NOTE: X,Y can be vectors or matrices, but if vectors, no check is made for
   % grid vectors vs coordinate pairs which means structured grids need to come
   % in unique otherwise cellsize = 0 will occur, whereas irregular /
   % unstructured grids will be treated the same i.e. as pairs of coordinates.

   % UPDATE: I think the key is for the uniformity check, pass in unique(X(:)),
   % and elsewhere, do or don't depending on whether arrays, vectors, lists etc
   % are expected. For example, a coordinate pair list will have non-unique
   % values but could still be regular / uniform. And for uniformity, we don't
   % need the unique([X Y],'rows') check we would need for coordinate lists
   % elsewhere. BUT note that unique(X(:)) returns sorted order, so it wont work
   % fo unstructured grids, for that would need unique(X(:),'stable') ... need
   % to revisit

   debug = false;

   % validate X and Y
   validateGridCoordinates(X, Y, mfilename)

   % option to return for scalar grid points
   if isscalar(X) && isscalar(Y)
      cellSizeX = NaN;
      cellSizeY = NaN;
      gridType = 'point';
      return
   end

   if verLessThan('matlab', '9.13')
      [xIsUniform, cellSizeX] = customIsUniform(unique(X(:)));
      [yIsUniform, cellSizeY] = customIsUniform(unique(Y(:)));
   else
      [xIsUniform, cellSizeX] = isuniform(unique(X(:)));
      [yIsUniform, cellSizeY] = isuniform(unique(Y(:)));
   end

   % Determine grid type and cell size

   % If one is uniform but the other not, determine just how non-uniform it is
   if xIsUniform && ~yIsUniform

      % If Y is a vector of constant values, then the "grid" is a vector,
      % assume uniformity.
      if isvector(Y) && all(diff(Y)==0)
         yIsUniform = true;
         cellSizeY = cellSizeX;
      else
         % Check for other edge cases
         [yIsUniform, cellSizeY] = checkuniformity(unique(Y(:)), 0.05);
      end

   elseif ~xIsUniform && yIsUniform

      % If X is a vector of constant values, then the "grid" is a vector,
      % assume uniformity.
      if isvector(X) && all(diff(X)==0)
         xIsUniform = true;
         cellSizeX = cellSizeY;
      else
         % Check for other edge cases
         [xIsUniform, cellSizeX] = checkuniformity(unique(X(:)), 0.05);
      end
   end

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

         % if one value is non-uniform, then nnz(diff(cellSizeY,2)) will equal
         % 3*size(Y,2) because diff(...,2) will be non-zero for the jump and the
         % row above and below.
         if nnz(diff(cellSizeY,2))==0 % allcolsequal
            cellSizeY = cellSizeY(:,1);
         end

         % This was needed with full grids (MAR, which were nearly uniform) to cet
         % the pad cellSize to equal the size of X and Y
         cellSizeX = [cellSizeX cellSizeX(:, end)];
         cellSizeY = [cellSizeY(1, :); cellSizeY];
      else

         % Here and next isn't really right, to know te actual grid size I need
         % ot know the vertices or the edges of the first or last
         cellSizeX = diff(X);
         cellSizeY = diff(Y);

         % This section appends the first element because diff returns 1 fewer
         % element than the input X,Y:
         cellSizeX = [cellSizeX(1); cellSizeX];
         cellSizeY = [cellSizeY(1); cellSizeY];
      end

      % cellSizeX = NaN;
      % cellSizeY = NaN;
   end

   if debug == true

      xu = unique(X(:));
      yu = unique(Y(:));
      idx = findjumps(yu);
      [~, nu] = intersect(Y(:), yu(idx));

      figure;
      scatter(X(:), Y(:), 'filled'); hold on;
      scatter(X(nu), Y(nu), 'filled')

      % try grid vecs
      [xvec, yvec] = gridvec(X, Y);

      % this was the debugging that lead to checkuniformity
      xjumps = findjumps(unique(X(:)));
      yjumps = findjumps(unique(Y(:)));

      dx = diff(unique(X(:)));
      dy = diff(unique(Y(:)));
      xnu = sum(mode(dx) ~= dx);
      ynu = sum(mode(dy) ~= dy);
   end
end

function [tf, cellsize] = checkuniformity(x, tol)

   xjumps = findjumps(x);
   dx = diff(x);
   xnu = sum(mode(dx) ~= dx);

   tf = xnu/numel(x) < tol;

   if tf
      cellsize = mode(dx);
   else
      % March 2024 there was no "else" but hadn't ever gotten here so added nan
      % for now, not sure what is best.
      cellsize = nan;
   end
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
%     'You might need to round the X/Y or LON/LAT grids ' ...
%     'to a uniform precision']);
% assert(all(round(diff(abs(yres),2),tol)==0), ...
%    ['Input argument 2, Y, must have uniform grid spacing. ' ...
%     'You might need to round the X/Y or LON/LAT grids ' ...
%     'to a uniform precision']);
%
% % return the cell size
% cellsizeX = abs(xres(1));
% cellsizeY = abs(yres(1));
% % cellsize = [cellsizeX, cellsizeY];
