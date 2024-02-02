function varargout = maxfig(varargin)
   %MAXFIG Create figure in max position
   %
   %  fig = maxfig()
   %  fig = maxfig(fig)
   %
   % See also:

   % Parse possible axes / figure input.
   [h, args, nargs, isfigure] = parsegraphics(varargin{:}); %#ok<ASGLU>

   if isempty(h)
      fg = figure;
   elseif isfigure
      fg = h;
   else
      fg = get(h, 'Parent');
   end

   % Parse param pairs (not needed unless non-standard options added)
   % [args, pairs, nargs] = parseparampairs(args{:});

   units = get(fg, 'units');
   set(fg,'units', 'normalized', 'outerposition', [0 0 1 1]);
   set(fg,'units', units);

   % Try to set any additional options supplied on input
   try
      set(fg, args{:});
   catch
   end

   if nargout == 1
      varargout{1} = fg;
   end
end
