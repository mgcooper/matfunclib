function varargout = maxfig(varargin)
   %MAXFIG Create figure in max position
   %
   %  fig = maxfig()
   %  fig = maxfig(fig)
   %
   % See also:

   [h, varargin, ~, isfigure] = parsegraphics(varargin{:});

   % Get handle to either the requested or a new figure.
   if isempty(h)
      fig = figure;
      h = gca(fig);
   elseif isfigure
      fig = h;
      h = gca(fig);
   else
      fig = get(h, 'Parent');
   end

   units = get(fig, 'units');
   set(fig,'units', 'normalized', 'outerposition', [0 0 1 1]);
   set(fig,'units', units);

   % Try to set any additional options supplied on input
   try
      set(fig, varargin{:});
   catch
   end

   if nargout == 1
      varargout{1} = fig;
   end
end
