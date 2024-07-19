function varargout = plotbbox(coords, varargin)
   %PLOTBBOX Plot a bounding box based on coordinate matrix or polygon vertices.
   %
   %  h = plotbbox(coords) h = plotbbox(coords, varargin)
   %
   % Description
   %
   %  h = plotbbox(coords) plots a bounding box based on COORDS, where COORDS is
   %  an Nx2 matrix with the first column as x and the second as y coordinates.
   %  COORDS can be a 2x2 bounding box matrix [xmin ymin; xmax ymax] or any Nx2
   %  matrix representing polygon vertices from which the bounding box will be
   %  calculated.
   %
   %  h = plotbbox(ax, coords) plots into the axes specified by AX. If no axes
   %  are specified, the current one is used or a new one is created.
   %
   %  h = plotbbox(_, varargin) passes optional arguments to the plot command.
   %  If AX is an axesm-based map, the Mapping Toolbox plotm command is used,
   %  otherwise the built-in plot command is used.
   %
   % Examples:
   %  h = plotbbox([1 3; 2 4]); % Plot a bounding box
   %  h = plotbbox([1 3; 2 4; 1 4; 2 3]); % Plot a bounding box from vertices
   %
   % See also: plot, plotm

   % TODO:
   %  - Add UseGeoCoords option?
   %  - Add R2bbox function so this can accept a raster R object?

   % Parse possible axes input.
   [h, args, nargs, isfigure] = parsegraphics(varargin{:}); %#ok<ASGLU>

   % Set default options to pass to plot (or plotm) as varargin{:}
   if isempty(args)
      args = {'Color', 'red'};
   end

   % Get handle to either the requested or a new axis.
   if isempty(h)
      ax = gca;
   elseif isfigure
      ax = gca(h);
   else
      ax = h;
   end
   washeld = get(ax, 'NextPlot');
   hold on;

   bbox = coordsToBbox(coords(:, 1), coords(:, 2));
   [xbox, ybox] = bboxToCoords(bbox);

   useplotm = true;
   try
      if ismap(ax)
         h = plotm(ybox, xbox, args{:});
      end
   catch e
      if strcmp(e.identifier, 'MATLAB:license:checkouterror')
         % The axes must not be an axesm-based map
         useplotm = false;
      end
   end

   if ~useplotm
      h = plot(ax, xbox, ybox, args{:});
   end

   % Restore hold state.
   set(ax, 'NextPlot', washeld)

   % Return the plot handle if requested.
   if nargout == 1
      varargout{1} = h;
   end
end
