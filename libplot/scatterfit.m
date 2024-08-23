function varargout = scatterfit(x, y, varargin)
   %SCATTERFIT Scatter plot x versus y with a linear fit and a one:one line
   %
   %  H = scatterfit(x,y)
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
   % AUTHOR: Matthew Guy Cooper, UCLA, guycooper@ucla.edu
   %
   % See also: addonetoone.m

   % if nargin==0
   %     posneg = pos;
   % elseif nargin>0
   %     if strcmp(posneg,'positive')
   %     end
   % end

   % TODO face colors
   % If alphadata is a vector of size equal to the data then set face alpha to flat
   % to map face alpha onto each point. So I guess shading flat means each data
   % point maps directly to it's color and shading interp interpolates

   % at least two inputs (x,y), and as many additional for call to plot.
   narginchk(2, Inf)

   % look for provided axes or figure
   [ax, args, ~, isfigure] = parsegraphics(varargin{:});
   if isempty(ax)
      ax = gca;
   elseif isfigure
      ax = gca(ax);
   end
   f = get(ax, 'Parent');
   washeld = get(ax, 'NextPlot');

   % Remove lone marker arguments e.g. 'o'.
   args = rmMarkerArgs(args);

   % Cast datetime input to datenum.
   wasdatetime = isdatetime(x);
   if wasdatetime
      x = datenum(x);
   end

   % Create the chart axes and scatter plot.
   H.figure = f;
   H.ax = ax;
   H.plot = plot(H.ax, x, y, 'Marker', 'o', 'LineStyle', 'none', args{:});
   hold on
   formatPlotMarkers('keepEdgeColor', true, 'MarkerSize', 8, ...
      'MarkerFaceColor', [.5 .5 1])

   if wasdatetime
      datetick('x')
   end

   % Compute and create the best-fit line. Plot in sorted order so linestyle's
   % such as '--' or ':' render as continuous lines.
   m = fitlm(x, y);
   H.linearfit = plot(H.ax, sort(x), predict(m, sort(x)), 'LineWidth', 2);

   % later add options to pass x/ylabel
   xylabel('x data', 'y data')
   legend('data', 'linear fit', 'Location', 'northwest')

   % Restore hold state.
   set(ax, 'NextPlot', washeld)

   if nargout == 1
      varargout{1} = H;
   end

   % This would go after plotting the linear fit, but I commented it out b/c
   % the 1:1 line isn't relevant in general.
   % H.onetoone = addOnetoOne;
   % legend('data','linear fit','1:1 line')
end

function args = rmMarkerArgs(args)

   % Remove 'Marker' and the marker value from args if they were provided.
   % Note: the original idea was to use the marker if provided. This removes it.
   args = parseparampairs(args, 'Marker');

   % Remove lone marker values e.g. 'o' from args if provided.
   args = args(~cellfun(@(arg) strcmp(arg, 'o'), args));
end
