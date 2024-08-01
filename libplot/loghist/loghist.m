function [h, edges, centers, hfit] = loghist(data, varargin)
   %LOGHIST Plot a histogram in log space.
   %
   %  [h,edges,centers,hfit] = loghist(data,varargin)
   %
   % See also: setlogticks

   arguments(Output)
      h
      edges
      centers
      hfit
   end

   % Parse inputs
   [data, normalization, logmodel, edges, centers, dist, theta, varargs] = ...
      parseinputs(data, mfilename, varargin{:});

   % remove negative values
   data = data(data>0);

   if normalization == "ccdf"
      normalization = "survivor";
   end

   if normalization == "survivor"

      % this is sufficient to make the plot
      [f, x] = ecdf(data, 'Function', 'survivor');
      h = stairs(x, f, 'LineWidth', 1.5);

      % % To finish this, need to map the 'centers' onto 'x', then pass
      % % those to ecdfhist, whihc should be possible using f,x recall that
      % % 'f' is the ecdf at each 'x', so i should be able to go from 'x' to
      % % 'centers', then get 'f' at the centers, and get n from that
      %
      % % this tries to coax the f,x into bins for histogram
      % % this doesn't work b/c centers aren't the centers of 'x'
      % n = ecdfhist(f,x,numel(edges)-1); % counts per bin
      % h = histogram('BinEdges',edges,'BinCounts',n);
      %
      % figure; ecdfhist(f,x,centers); % ,normalization,varargs{:});

   else
      h = histogram(data, edges, 'Normalization', normalization, varargs{:});
   end

   % fit a dist if requested
   if dist ~= "none"
      if dist == "GeneralizedPareto"
         % if gp distfit is requested, truncate the data for fitting
         dfit = fitdist(data(data>theta), 'GeneralizedPareto', 'Theta', theta);
      else
         dfit = fitdist(data, dist); % see distfit for options I could add
      end

      % truncate the bins to the data range, so the plot is compact
      imax = find(edges >= max(data), 1, 'first');
      imin = find(edges>theta, 1, 'first');
      edges = [max(theta, min(data)) edges(imin:imax)];
      centers = edges(1:end-1) + diff(edges) ./ 2;

      % % if gp is requested, make sure the bin centers/edges are >theta
      % if dist == "GeneralizedPareto"
      %    edges = [theta edges(edges>theta)];
      %    centers = edges(1:end-1)+diff(edges)./2;
      % end

      hold on
      switch normalization
         case 'pdf'
            pfit = dfit.pdf(centers);
            % refv = dfit.pdf(data(find(data >= theta,1,'first')));
            % pfit = refv.*pfit;
            hfit = plot(centers, pfit, 'LineWidth', 2.5, 'LineStyle', '-');
         case 'cdf'
            pfit = dfit.cdf(centers);
            refv = dfit.cdf(data(find(data >= theta, 1, 'first')));
            pfit = refv .* pfit;
            hfit = plot(centers, pfit, 'LineWidth', 1.5, 'LineStyle', '-');
         case 'survivor'
            hfit = plot(centers, dfit.cdf(centers,'upper'), ...
               'LineWidth', 1.5, 'LineStyle', '--');
         otherwise
            error('no option to plot distfit using requested normalization');
      end
   end

   axis tight
   hold off
   switch logmodel

      case 'loglog'
         set(gca, 'XScale', 'log', 'YScale', 'log');

      case 'semilogy'
         set(gca, 'XScale', 'linear', 'YScale', 'log');

      case 'semilogx'
         set(gca, 'XScale', 'log', 'YScale', 'linear');
   end

   if ~nargout
      clearvars
   end
end

%%
function edges = logbinedges(data)
   data = data(data>0);
   edges = logspace(fix(log10(min(data))),ceil(log10(max(data))));
end

function centers = logbincenters(data)
   data = data(data>0);
   edges = logbinedges(data);
   centers = edges(1:end-1)+diff(edges)./2;
end

function [data, normalization, logmodel, edges, centers, dist, theta, varargs] = ...
      parseinputs(data, mfilename, varargin)

   parser = inputParser;
   parser.FunctionName = mfilename;
   parser.CaseSensitive = false;
   parser.KeepUnmatched = true;
   parser.addRequired('data', @isnumeric);
   parser.addParameter('normalization', 'pdf', @ischarlike);
   parser.addParameter('logmodel', 'loglog', @ischarlike);
   parser.addParameter('edges', logbinedges(data), @isnumeric);
   parser.addParameter('centers', logbincenters(data), @isnumeric);
   parser.addParameter('dist', 'none', @ischarlike);
   parser.addParameter('theta', 0, @isnumeric);
   parser.parse(data,varargin{:});

   normalization = string(parser.Results.normalization);
   logmodel = parser.Results.logmodel;
   centers = parser.Results.centers;
   edges = parser.Results.edges;
   theta = parser.Results.theta;
   dist = string(parser.Results.dist);
   varargs = struct2varargin(parser.Unmatched);
end
