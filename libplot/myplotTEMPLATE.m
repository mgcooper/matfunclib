function varargout = myplotTEMPLATE(varargin)

   % Check the number of input and output arguments.
   narginchk(1, Inf)
   nargoutchk(0, 1);

   % might be nice to have:
   [ax, washeld, wasfigure, varargin] = prepareGraphics(varargin{:}); %#ok<ASGLU>
   % And move the isempty(h) ... stuff inside that

   % Parse optional axes flag
   [dim, varargin] = parseoptarg(varargin, {'x', 'y', 'z'}, 'y');

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

   % Only use this if the desired behavior is to plot on top of existing series,
   % e.g. addOnetoOne. In functions that plot multiple series, use hold on after
   % plotting the first series, as usual.
   % hold(ax, 'on')

   % ... Parse the rest of args

   % ... Make the plot in ax

   % Restore hold state.
   set(ax, 'NextPlot', washeld)

   % Return the axes if requested.
   if nargout == 1
      varargout{1} = ax;
   end

   %% Alternative washeld pattern 1

   % For functions that inherit chart properties using ?, the following syntax:
   % (..., 'Parent', ax)
   % can be used, especially if an arguments block is used, b/c it is
   % incompatible with varargin, meaning parsegraphics isn't applicable. In that
   % case, this simple syntax is sufficient:

   washeld = ishold();
   hold on
   % ...
   % restore held state
   if ~washeld
      hold off
   end

   % However, it requires the user to use the 'Parent', ax syntax, which is not
   % very common. Alternatively, the arguments block could be used to parse the
   % axes, but I have not sorted that out yet.

   %% Alternative washeld pattern 2

   % ... parse possible input axes

   washeld = ishold(ax);

   if ~washeld
      hold(ax, 'off')
   end

   %% If the figure handle is also desired:

   if isempty(h)
      fg = figure;
      ax = gca(fg);
   elseif isfigure
      fg = h;
      ax = gca(fg);
   else
      ax = h;
      fg = get(ax, 'Parent');
   end

   % Return the axes and the figure (and plot handles etc.) if requested.
   if nargout == 1
      H.figure = fg;
      H.ax = ax;
      % ... other objects like legends, plot handles, etc.
      varargout{1} = H;
   end

   %% Alternative ways to get the figure/axes handles

   if isempty(h)

      % Two ways to create a new figure, should be identical if no figure exists
      fg = figure;
      fg = gcf;

      % Two ways to get the current axes in the new figure:
      ax = gca(fg); % Creates cartesian axes
      ax = get(fg, 'CurrentAxes'); % Does not create axes, returns empty array

      % This does not create a figure if one does not exist. Might be useful
      % when visibility is set off, not sure.
      fg = get(groot,'CurrentFigure');

   elseif isfigure

      % If the figure exists, these should be identical but I have not tested
      fg = h;
      ax = gca(fg);
      ax = get(fg, 'CurrentAxes');
   else

      % Otherwise the axes was provided,
      ax = h;
      fg = get(ax, 'Parent');

      % This should be identical:
      fg = gcf;

      isequal(gcf, get(ax, 'Parent')) % equal
   end

   % Compare these two:

   fg1 = gcf;
   isequal(get(fg1, 'CurrentAxes'), gca(fg1)) % equal

   fg2 = figure;
   isequal(get(fg2, 'CurrentAxes'), gca(fg2)) % not equal

   isequal(fg1, fg2) % not equal

   isequal(gca(fg1), gca(fg2)) % not equal

   % From Mathworks documentation:

   % To get the handle of the current figure without forcing the creation of a
   % figure if one does not exist, query the CurrentFigure property on the root
   % object.
   fg = get(groot,'CurrentFigure');

   % To access the current axes or chart without forcing the creation of
   % Cartesian axes, use dot notation to query the figure CurrentAxes property.
   % MATLAB® returns an empty array if there is no current axes.
   fg = gcf;
   ax = fg.CurrentAxes;

end

%{

   Discussion

   The "standard" way:
   
   % Parse possible axes input.
   [h, args, ~] = axescheck(varargin{:}); %#ok<ASGLU>
   
   % Get handle to either the requested or a new axis.
   if isempty(h)
      ax = gca;
   else
      ax = h;
   end
  
   The "updated" way I developed:

   % Parse possible axes input.
   [h, args, ~, isfigure] = parsegraphics(varargin{:}); %#ok<ASGLU>

   % Get handle to either the requested or a new axis.
   if isempty(h)
      ax = gca;
   elseif isfigure
      ax = gca(h);
   else
      ax = h;
   end
   washeld = get(ax, 'NextPlot');
   hold(ax, 'on');
 
   Variants on above:
   % ax = axes('Parent', fg); % this places a new axes in the figure

%}
