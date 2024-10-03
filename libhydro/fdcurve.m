function varargout = fdcurve(varargin)
   %FDCURVE Flow duration curve
   %
   %    fdc = fdcurve(flow)
   %    fdc = fdcurve(flow, axscale=axscale)
   %    fdc = fdcurve(flow, units=units)
   %    fdc = fdcurve(flow, refpoints=refpoints)
   %    fdc = fdcurve(flow, plotcurve=plotcurve)
   %
   % See also

   % Parse possible axes input.
   [ax, args, nargs, isfigure] = parsegraphics(varargin{:}); %#ok<ASGLU>

   % Get handle to either the requested or a new axis.
   if isempty(ax)
      ax = gca;
   elseif isfigure
      ax = gca(ax);
   end
   washeld = get(ax, 'NextPlot');

   % Retrieve the flow data from varargin
   flow = args{1};
   args = args(2:end);

   % Parse inputs
   parser = inputParser;
   parser.FunctionName = mfilename;
   parser.addRequired('flow', @isnumeric);
   parser.addParameter('axscale', 'semilogy', @isscalartext);
   parser.addParameter('units', '', @isscalartext);
   parser.addParameter('refpoints', nan, @isnumeric);
   parser.addParameter('plotcurve', true, @islogicalscalar);
   parser.parse(flow, args{:});
   kwargs = parser.Results;
   [axscale, units, refpoints, plotcurve] = deal(kwargs.axscale, ...
      kwargs.units, kwargs.refpoints, kwargs.plotcurve);

   % Remove nan
   flow = flow(~isnan(flow));

   % Main algorithm
   N = length(flow);
   M = 1:N;
   x = sort(flow,'descend');
   f = M./(N+1);

   % If requested, compute reference point values
   xref = nan(numel(refpoints,1));
   fref = nan(numel(refpoints,1));
   if ~isnan(refpoints)
      for n = 1:numel(refpoints)
         iref = find(x >= refpoints(n),1,'last');
         xref(n) = x(iref);
         fref(n) = f(iref);
      end
   end

   % Plot the curve if requested
   if plotcurve

      switch axscale
         case 'loglog'
            h.fdc = loglog(ax, 100*f, x);
         case 'semilogy'
            h.fdc = semilogy(ax, 100*f, x);
         case 'semilogx'
            h.fdc = semilogx(ax, 100*f, x);
         case 'linear'
            h.fdc = plot(ax, 100*f, x);
      end

      % if requested, add a refpoint line
      if ~isnan(refpoints)
         hold on
         for n = 1:numel(refpoints)
            xplot = [min(xlim) 100*fref(n) 100*fref(n) 100*fref(n)];
            yplot = [xref(n) xref(n) min(ylim) xref(n)];
            h.ref(n) = plot(ax, xplot,yplot,'Color',[0.85 0.325 0.098],'LineWidth',1);
         end
      end

      ylabel(['$x$ [' units ']']);
      xlabel 'flow exceedence probability, $P(Q\ge x)$'

      ax.YAxis.TickLabels = compose('%g', ax.YAxis.TickValues);
      ax.XAxis.TickLabels = compose('$%g\\%%$', ax.XAxis.TickValues);

      % since i manually set the ticklabels, i think this is necessary
      % otherwise if the figure is resized, matlab will make new ticks
      set(ax, 'XTickMode', 'manual', 'YTickMode', 'manual');

      % figformat('suppliedline', h.fdc, 'linelinewidth', 3);
      ax.YLabel.Interpreter = 'latex';
      ax.XLabel.Interpreter = 'latex';
      ax.TickLabelInterpreter = 'latex';

      fdc.h = h;
   end

   set(ax, 'NextPlot', washeld)

   axis padded

   % package output
   if nargout
      fdc.f = f;
      fdc.x = x;
      fdc.xref = xref;
      fdc.fref = fref;

      varargout{1} = fdc;
   end

   % % this would also work, adapted from num2ltext
   % ax.XAxis.TickLabels = cellstr(num2str(ax.XAxis.TickValues','$%g\\%%$'))
   %
   % % thought I could let matlab compose them and then get the ticklabels:
   % ax.XAxis.TickLabelInterpreter = 'latex';
   % xtickformat 'percentage'
   % % but they disappear when latex is set
end

% function [F,x] = ecdfpot(x,xmin,alpha,sigma)
%
%    % not implemented
%
%    % http://sfb649.wiwi.hu-berlin.de/fedc_homepage/xplore/tutorials/sfehtmlnode91.html
%
%    % peaks over threshold exceedance probability:
%    % F(x) = N(u)/n(1+gamma(x-u)/beta)^(-1/gamm),
%    % N(u) is the number of obs>u
%    % n is totla number, i think
%    % x would be tau
%    % u would be taumin
%    % gamma/beta would be b-1/tau0 i think
%    % so 1/gamm would be 1/b-1
%
%
%    N = numel(x(x>xmin));
%    n = numel(x);
%    gamma = b-1; % might be 1-b;
%    beta = tau0;
%    F = N/n.*(1+gamma.*(x-x0)/beta)^(-1/gamm);
% end
