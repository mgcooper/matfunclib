function varargout = idfcurveplot(durations, curves, periods, varargin)

   [ax, args, nargs, isfigure] = parsegraphics(varargin{:}); %#ok<ASGLU>

   % Get handle to either the requested or a new axis.
   if isempty(ax)
      ax = gca;
   elseif isfigure
      ax = gca(ax);
   end
   washeld = get(ax, 'NextPlot');


   % Create the graph
   plot(durations, curves', 'LineWidth', 1.5);
   xlabel('Duration (hours)');
   ylabel('Intensity (rate per hour)');
   % title('Intensity-Duration-Frequency Curves');
   legend(arrayfun(@(x) sprintf('T = %d years', x), periods, 'Uniform', false));
   grid on

   % Restore hold state.
   set(ax, 'NextPlot', washeld)

   % Return the axes if requested.
   if nargout == 1
      varargout{1} = ax;
   end
end
