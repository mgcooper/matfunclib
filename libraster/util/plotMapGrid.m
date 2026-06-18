function varargout = plotMapGrid(varargin)
   %PLOTMAPGRID Plot a complete representation of a regular or uniform grid.
   %
   % H = plotMapGrid(X, Y) plots the grid centroids and grid edges for the input
   % X and Y grid vectors or coordinate arrays and returns the figure handle,
   % axes handle, and plot handles as an array H.
   %
   % H = plotMapGrid(fig, X, Y) or H = plotMapGrid(ax, X, Y) plots the grid
   % centroids and grid edges into the specified figure or axis.
   %
   % H = plotMapGrid(..., 'force') plots grids larger than 1e5 cells, which are
   % otherwise refused because plotting every centroid/edge is slow.
   %
   % See also: prepareMapGrid

   % Parse possible axes input.
   [H, args, nargs, isfigure] = parsegraphics(varargin{:}); %#ok<ASGLU>

   if isempty(H)
      target = gcf;
   else
      target = H;
   end

   % Parse inputs
   X = args{1};
   Y = args{2};

   % Confirm X and Y are non-empty real numeric
   validateGridCoordinates(X, Y, mfilename)

   % Remove X and Y and parse remaining arguments
   args = args(3:end);

   % Remove the 'force' flag if provided (overrides the large-grid guard below).
   iforce = cellfun(@(a) (ischar(a) || isstring(a)) && strcmp('force', a), args);
   force = any(iforce);
   args(iforce) = [];

   % Remove the plotting option ('centroids' | 'edges' | 'both') if provided.
   iopt = cellfun(@(a) ischar(a) || isstring(a), args);
   if any(iopt)
      opt = args(iopt);
      args(iopt) = [];
   else
      opt = 'both';
   end

   % Need to pass in the cell size if x,y are scalar
   switch numel(args)
      case 0
         if isscalar(X) && isscalar(Y)
            error('X and Y are scalar, cell size is required')
         else
            [~, cellsizex, cellsizey, ~] = mapGridInfo(X, Y);
         end
      case 1
         cellsizex = args{1};
         cellsizey = args{1};
      case 2
         cellsizex = args{1};
         cellsizey = args{2};
   end

   % Confirm cellsize is a scalar numeric
   validateGridCoordinates(cellsizex, cellsizey, mfilename, ...
      'cellsizex', 'cellsizey', 'point')

   % Guard against plotting an impractically large grid (each centroid is a
   % marker and each cell edge a mesh line). Require 'force' for large grids.
   if isvector(X) && isvector(Y)
      nCells = numel(X) * numel(Y);
   else
      nCells = numel(X);
   end
   if nCells > 1e5 && ~force
      error('matfunclib:plotMapGrid:gridTooLarge', ...
         ['Grid has %d cells (> 1e5); plotting every centroid/edge may be very ' ...
         'slow. Pass ''force'' to plot anyway.'], nCells);
   end

   % Obtain the grid edges
   [Xedges, Yedges] = gridNodesToEdges(X, Y, 'fullgrids', cellsizex, cellsizey);

   % Plot the grid centroids and edges
   H = plotGrid(target, X, Y, Xedges, Yedges, opt);

   % Prep output
   if nargout == 1
      varargout{1} = H;
   end

end

function H = plotGrid(target, X, Y, Xedges, Yedges, opt)
   % Plot the grid centroids and edges

   H = gobjects(1, 4);

   % NOTE: because I did not realize that mesh was plotting white background,
   % it is possible the first version would ahve worked.
   if isgraphics(target, 'figure')
      fig = target;
      set(fig, 'Name', 'MapGrid');

      % method 1: fails
      % ax = axes(fig);

      % method 2:
      % ax = axes(fig,'NextPlot','add');

      % method 3:
      % ax = ancestor(fig,'Axes');

      % method 4:
      ax = findobj(fig, 'Type', 'axes', 'Tag', 'MapGrid');
      if isempty(ax)
         ax = axes(fig);
      end
   else
      ax = target;
      fig = ancestor(ax, 'figure');
      set(fig, 'Name', 'MapGrid');
   end

   set(fig, 'Tag', 'MapGrid');
   set(ax, 'Tag', 'MapGrid');
   hold(ax, 'on');

   if strcmp(opt, 'edges') || strcmp(opt, 'both')
      % Plot the grid edges
      p1 = mesh(Xedges, Yedges, zeros(size(Xedges)), 'FaceAlpha', 0);
      view(2);
      H(3) = p1;
   end

   if strcmp(opt, 'centroids') || strcmp(opt, 'both')
      % Plot the grid centroids
      [x,y] = fastgrid(X,Y);
      p2 = plot(ax, x(:), y(:), 'o', 'MarkerFaceColor', 'r', ...
         'MarkerEdgeColor', 'none');
      H(4) = p2;
   end

   xlabel(ax, 'X');
   ylabel(ax, 'Y');
   title(ax, 'Grid Centroids and Edges');
   hold(ax, 'off');

   grid off
   axis tight

   H(1) = fig;
   H(2) = ax;
end
