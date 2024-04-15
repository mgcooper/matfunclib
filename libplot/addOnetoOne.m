function varargout = addOnetoOne(varargin)
   %addOnetoOne adds a one:one line to an open plot
   %   Adds a solid black line of width 1, scales the x and y lims to be
   %   equal, returns the handle to the plot so the user can specify line
   %   properties on the 1:1 line. Alternatively, the line properties can be
   %   passed in i.e. "varargin"
   %
   % INPUTS:
   % optional, can be left blank, or any standard line property can be used as
   % an input to modify the 1:1 line. See examples.
   %
   % OUTPUTS:
   % handle = handle to the 1:1 line object
   %
   % AUTHOR: Matt Cooper, UCLA, guycooper@ucla.edu
   %
   % EXAMPLE 1: simplest case, just add the one to one line
   % x = 1:1:100;
   % y = x.*(rand(1,100) + .5);
   % h = scatter(x,y);
   % addOnetoOne;
   %
   % EXAMPLE 2: change the default 1:1 line to a black dashed line
   % x = 1:1:100;
   % y = x.*(rand(1,100) + .5);
   % h = scatter(x,y);
   % addOnetoOne('k--')
   %
   % EXAMPLE 3: change the default 1:1 line to very thick line;
   % x = 1:1:100;
   % y = x.*(rand(1,100) + .5);
   % h = scatter(x,y);
   % addOnetoOne('k--','linewidth',5)
   %
   % See also: scatterfit

   % TODO: reconcile with padone2one

   % Parse optional keeplims argument
   [keeplims, varargin] = parseoptarg(varargin, {'keeplims'}, 'resetlims');

   % Parse possible axes input.
   [ax, varargin, ~, isfigure] = parsegraphics(varargin{:});

   % Get handle to either the requested or a new axis.
   if isempty(ax)
      ax = gca;
   elseif isfigure
      ax = gca(ax);
   end
   washeld = get(ax, 'NextPlot');
   hold(ax, 'on');

   if strcmp(keeplims, 'keeplims')

      % If 'keeplims' is designed to keep limits that are already 1:1:
      newlims = xlim;

      % If 'keeplims' is designed to set the axes equal without modifying the
      % full extent of either existing axes:
      newlims(1) = min(min(xlim), min(ylim));
      newlims(2) = max(max(xlim), max(ylim));
   else
      axis tight;

      % Get the limits based on the current limits
      % pad = pad/100*(newlims(2)-newlims(1));
      % newlims(1) = min(min(xlim),min(ylim)) * 0.98;
      % newlims(2) = max(max(xlim),max(ylim)) * 1.02;

      % Get the limits based on the data range
      % NOTE: if this function is called from scatterfit, which plots the data
      % and linear fit or any other case where multiple data series are plotted,
      % xdata, ydata will be cell arrays holding each plotted x,y series, but
      % that's a feature not a bug, since newlims finds the extent of all data to
      % set the axes limits.
      [xdata, ydata] = getplotdata(ax);

      % If multiple data series exist on the plot, cat them to vectors
      if iscell(xdata)
         try
            xdata = Cell2Vec(xdata);
         catch
            xdata = cellflatten(xdata, 1, 'column');
         end
      end
      if iscell(ydata)
         try
            ydata = Cell2Vec(ydata);
         catch
            ydata = cellflatten(ydata, 1, 'column');
         end
      end

      newlims(1) = min(min(ydata(:)), min(xdata(:)));
      newlims(2) = max(max(ydata(:)), max(xdata(:)));
   end

   if isnumeric(newlims) && newlims(2) > newlims(1)
      set(ax, 'XLim', newlims, 'YLim', newlims);
   else
      % Something likely wrong, e.g., all data is zero
      newlims = xlim;
   end

   delta = (newlims(2) - newlims(1)) / 100;
   plotdata = newlims(1):delta:newlims(2);
   H = plot(plotdata, plotdata, varargin{:});

   axis square

   %    % Not sure if this will fix the issue below or if its ... started this then
   %    stopped, but was gonna use the min / max and then whichever has more values
   %    and/or the unique ones, but need to ensure even spacing etc ... but thats
   %    already whats done below so more likely it needs to retrieve more
   %    properties e.g. format and reset them.
   %    xmajorticks = get(gca, 'XTick');
   %    ymajorticks = get(gca, 'YTick');
   %    % Want to ensure the min / max value


   % i diabled this b/c it's the reason the exponent isn't showing up on the
   % tick labels anymore, need to come up with a solution
   % now update the ticks and labels
   xticks = get(gca,'Xtick');
   yticks = get(gca,'Ytick');
   if length(xticks) >= length(yticks)
       ticks = xticks;
       ticklabels = get(gca,'XTickLabel');
   else
       ticks = yticks;
       ticklabels = get(gca,'YTickLabel');
   end
   
   set(gca,'XTick',ticks,'XTickLabel',ticklabels,'YTick',ticks, ...
           'YTickLabel',ticks);

   % Restore hold state
   set(ax, 'NextPlot', washeld);

   if nargout == 1
      varargout{1} = H;
   end
end
