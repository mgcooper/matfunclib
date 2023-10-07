function H = scatterfit(varargin)
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
   [h, args, ~, isfigure] = parsegraphics(varargin{:});

   if isempty(h)
      f = figure;
      ax = gca(f);
   elseif isfigure % h is a figure
      f = h;
      ax = gca(f);
   else % h is an axes object
      ax = h;
      f = get(ax, 'Parent');
   end

   % pull out x and y and remove them
   x = args{1};
   y = args{2};
   args = args(3:end);

   % Call to rmMarkerArgs would have gone here, but calling syntax below works.
   args = rmMarkerArgs(args);

   % Create the chart axes and scatter plot.
   H.figure = f;
   H.ax = ax;
   H.plot = plot(H.ax,x,y, 'Marker', 'o', args{:});
   hold on;
   formatPlotMarkers;

   % Compute and create the best-fit line.
   m = fitlm(x, y);
   H.linearfit = plot(H.ax,x,m.Fitted,'LineWidth',2);
   H.onetoone = addOnetoOne;

   % later add options to pass x/ylabel
   xylabel('x data','ydata')
   legend('data','linear fit','1:1 line')
end

function args = rmMarkerArgs(args)

   args = args(~cellfun(@(arg) strcmp(arg, 'o'), args));

   % % Update: If 'Marker' is provided, then use it. But need to check for an
   % additional argument specifying the type

   % % Remove marker types from args in case they are provided
   % rmargs = cellfun(@(arg) strcmp(arg, 'Marker'), args);
   % if any(rmargs) % works if rmargs is empty or logical
   %    % need to complete this, the idea is if "marker" is found, remove the enxt
   %    % entry too
   % end
   % args = args(~rmargs);
   % args = args(~cellfun(@(arg) strcmp(arg, 'o'), args));
end
