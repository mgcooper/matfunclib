function varargout = padone2one(pad, varargin )
   %addOnetoOne Add a one:one line to an open plot
   %
   %  H = padone2one(pad)
   %
   %   Adds a solid black line of width 1, scales the x and y lims to be
   %   equal, returns the handle to the plot so the user can specify line
   %   properties on the 1:1 line. Alternatively, the line properties can be
   %   passed in i.e. "varargin"
   %
   % INPUTS:
   % pad = 0 - 100%. Value to stretch the x and y axis beyond the data range,
   % for example to make room for annotation or a legend. Optional - user can
   % input an empty matrix or '0' for default axis limits. See examples below.
   %
   % OUTPUTS:
   % handle = handle to the 1:1 line object
   %
   % AUTHOR: Matthew Guy Cooper, UCLA, guycooper@ucla.edu
   %
   % EXAMPLE 1: simplest case, just add the one to one line
   % x = 1:1:100;
   % y = x.*(rand(1,100) + .5);
   % h = scatter(x,y);
   % padone2one();
   %
   % EXAMPLE 2: add some space (10%) to the axis limits to make room for visual
   % clarity, perhaps to make room for annotation or a legend
   %
   % x = 1:1:100;
   % y = x.*(rand(1,100) + .5);
   % h = scatter(x,y);
   % padone2one(10)
   %
   % EXAMPLE 3: add some space (10%) and change the default 1:1 line to a
   % black dashed line of width 5
   %
   % x = 1:1:100;
   % y = x.*(rand(1,100) + .5);
   % h = scatter(x,y);
   % padone2one(10,'k--','linewidth',5)

   if nargin<1
      pad = 2;
   end

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

   axis tight; axis square;

   xlims = xlim;
   ylims = ylim;

   newlims(1) = min(min(xlims), min(ylims));
   newlims(2) = max(max(xlims), max(ylims));

   % pad the upper end for visual clarity
   pad = pad / 100 * (newlims(2)-newlims(1));

   newlims(2) = newlims(2) + pad;
   newlims(1) = newlims(1) - pad;

   set(ax, 'XLim', newlims);
   set(ax, 'YLim', newlims);

   plotdata = linspace(newlims(1), newlims(2), 100);
   H = plot(plotdata, plotdata, varargin{:});

   % now update the ticks and labels
   xticks = get(ax, 'XTick');
   yticks = get(ax, 'YTick');
   if length(xticks) >= length(yticks)
      ticks = xticks;
      res = diff(ticks); res = res(1);
   else
      ticks = yticks;
      res = diff(ticks); res = res(1);
   end

   % reset the plot if needed
   if ticks(end)<newlims(2)
      newlims(2) = ticks(end) + res;
      ticks(end+1) = ticks(end) + res;
      set(ax, 'XLim', newlims, 'YLim', newlims, 'XTick', ticks, 'YTick', ticks);
      plotdata = linspace(newlims(1), newlims(2), 100);
      H = plot(plotdata, plotdata, varargin{:});
   end

   % axis square

   if nargout == 1
      varargout{1} = H;
   end
end

% an older version used this method to reset the ticks:
% xticks = ax.XTick;
% yticks = ax.YTick;
% if length(xticks) >= length(yticks)
%     ticks = xticks;
%     ticklabels = get(gca,'XTickLabel');
% else
%     ticks = yticks;
%     ticklabels = get(gca,'YTickLabel');
% end
% set(gca,'XTick',ticks,'XTickLabel',ticklabels,'YTick',ticks, ...
%         'YTickLabel',ticks);

% I might try to detect when the x/ylims need to be extended to an even
% tick mark
% xticks = get(gca,'Xtick');
% yticks = get(gca,'Ytick');
% xres = diff(xticks); xres = xres(1);
% yres = diff(yticks); yres = yres(1);
% if length(xticks) >= length(yticks)
%     ticks = xticks;
%     if ticks(end)<newlims(2)
%         ticks(end+1) = ticks(end) + xres;
%     elseif ticks(1)>newlims(1)
%         ticks(1) = ticks(1)-xres
%     end
%     ticklabels = get(gca,'XTickLabel');
% else
%     ticks = yticks;
%     ticklabels = get(gca,'YTickLabel');
% end
