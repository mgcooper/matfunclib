function varargout = plotbbox(xlims, ylims, varargin)

   % Parse possible axes input.
   [h, args, nargs, isfigure] = parsegraphics(varargin{:}); %#ok<ASGLU>

   % Get handle to either the requested or a new axis.
   if isempty(h)
      ax = gca;
   elseif isfigure
      ax = gca(h);
   else
      ax = h;
   end
   washeld = get(ax, 'NextPlot');

   bbox = [xlims(:), ylims(:)];
   xbox = [bbox(1), bbox(2), bbox(2), bbox(1), bbox(1)];
   ybox = [bbox(3), bbox(3), bbox(4), bbox(4), bbox(3)];

   if ismap(ax)
      h = plotm(ybox, xbox, varargin{:});
   else
      h = plot(xbox, ybox, varargin{:});
   end

   % Restore hold state.
   set(ax, 'NextPlot', washeld)

   % Return the axes if requested.
   if nargout == 1
      varargout{1} = h;
   end
end
