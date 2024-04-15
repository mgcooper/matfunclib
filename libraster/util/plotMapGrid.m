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
   % See also: prepareMapGrid

   % Parse possible axes input.
   [H, args, nargs, isfigure] = parsegraphics(varargin{:}); %#ok<ASGLU>

   if isempty(H)
      target = gcf;
   end

   % Parse inputs
   X = args{1};
   Y = args{2};

   % Confirm X and Y are non-empty real numeric
   validateGridCoordinates(X, Y, mfilename)

   % Remove X and Y and parse remaining arguments
   args = args(3:end);
   nargs = nargin -2;

   % Remove the plotting option if provided
   iopt = cellfun(@ischar, args);
   if any(iopt)
      opt = args(iopt);
      args(iopt) = [];
   else
      opt = 'both';
   end

   % Need to pass in the cell size if x,y are scalar
   if nargs < 1
      if isscalar(X) && isscalar(Y)
         error('X and Y are scalar, cell size is required')
      else
         [gridType, cellsizex, cellsizey, tfGeoCoords] = mapGridInfo(X, Y);
      end
   elseif nargs == 1
      cellsizex = args{1};
      cellsizey = args{1};
   elseif nargs == 2
      cellsizex = args{1};
      cellsizey = args{2};
   end

   % Confirm cellsize is a scalar numeric
   validateGridCoordinates(cellsizex, cellsizey, mfilename, ...
      'cellsizex', 'cellsizey', 'point')

   % Obtain the grid edges
   [Xedges, Yedges] = gridNodesToEdges(X, Y, 'fullgrids', cellsizex, cellsizey);

   % TODO: check size of X,Y and if too big, exit. Add optional argument to force.

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
