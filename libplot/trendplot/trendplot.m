function varargout = trendplot(t, y, varargin)
   %TRENDPLOT Plot a timeseries and linear trendline fit.
   %
   % h = trendplot(t, y) plots time T and data Y and fits a trendline
   %
   % Copyright Matt Cooper, 2022-2024, github.com/mgcooper
   %
   % See also: printtrend

   % PARSE INPUTS
   [t, y, opts, vargs] = parseinputs(t, y, mfilename, varargin{:});

   % convert to anomalies etc.
   [t, y, yerrs] = prepInput(t, y, ...
      opts.yerr, opts.anomalies, opts.reference);

   % compute trends
   [ab, err, yfit, yci] = computeTrends(t, y, ...
      opts.method, opts.alpha, opts.quantile);

   % update the figure or make a new one
   [h, makeleg, legidx] = updateFigure( ...
      opts.useax, opts.showfig, opts.figpos, opts.errorbounds);

   % draw the plot
   h = plotTrend(h, t, y, yfit, yerrs, yci, ...
      opts.errorbars, opts.errorbounds, vargs);

   % draw the legend
   h = drawLegend(h, ab, err, makeleg, legidx, ...
      opts.precision, opts.legendtext, opts.units, opts.alpha);

   % format the figure
   ylabel(opts.ylabeltext);
   xlabel(opts.xlabeltext);
   title(opts.titletext);

   % PACKAGE OUTPUT
   if nargout
      h.ax = gca;
      h.ab = ab;
      h.err = err;
      h.yfit = yfit;
      h.yci = yci;
      varargout{1} = h;
   end
end

%% LOCAL FUNCTIONS
function [tt,y,yerr] = prepInput(tt,y,yerr,anomalies,reference)

   % create a regular time in years, works for both months and years
   y0 = year(tt(1)); % the first year (double) works for datetime and datenum
   if isdatetime(tt)
      t0 = datetime(y0, 1, 1); % start of the first year (datetime)
      tt = years( tt - tt(1)) + ( y0 + years( tt(1) - t0 ) );
   else
      t0 = datenum([y0, 1, 1]); %#ok<*DATNM> % start of the first year (datenum)
      tt = (tt - t0) / datenum([0, 0, 365.25]) + y0; % convert to decimal years
   end

   % see old method that checked for months at end

   % convert to anomalies if requested
   if anomalies
      if ~isnan(reference)
         y = y - mean(reference, 1, 'omitnan');
      else
         y = y - mean(y, 1, 'omitnan');
      end
   end

   % if yerr is a scalar, make it a vector of size equal to y
   if isscalar(yerr)
      yerr = yerr .* ones(size(y));
   end
end

% COMPUTE TRENDS
function [abfit, error, yfit, yconf] = computeTrends(t, y, method, alpha, qtl)

   inans = isnan(y);
   ncols = size(y, 2);
   abfit = nan(ncols, 2);
   error = nan(ncols, 1);
   confi = nan;
   yconf = nan(size(y, 1), 2); % confidence bounds for trendline

   % note, conf int's not symmetric for quantile regression, so I use the
   % mean of the lower and upper for now

   % compute trends
   for n = 1:ncols
      if isnan(qtl)
         switch method
            case 'ts'
               % need to eventually merge tsregr and ktaub, the latter
               % doesn't return the intercept and the former doesn't return
               % conf levels or much other detail.

               % only get conf levels if requested
               if isnan(alpha)
                  abfit(n, :) = tsregr(t, y(:, n));
               else
                  abfit(n, :) = tsregr(t, y(:, n));
                  try
                     outab = ktaub([t, y(:, n)], alpha, false);
                     confi = [outab.CIlower, outab.CIupper];
                     error(n) = mean([abfit(n, 2)-confi(1), confi(2)-abfit(n, 2)]);
                  catch e
                     if strcmp(e.message, '')
                        % statistics toolbox licensing error
                     end
                  end
               end

               % not sure we want the setnan
               yfit = transpose(abfit(:, 1) + abfit(:, 2)*t');
               yfit = setnan(yfit, [], inans);

            case 'ols'

               if isnan(alpha)
                  abfit(n, :) = olsfit(t, y(:, n));
               else

                  % Compute fitted line and CIs
                  if isoctave
                     [~, stats] = fitlm(t, y(:, n), "display", "off");
                     % coeff = [lmmdl{2:3, 2}]; % this might work in matlab too
                     coeff = stats.coeffs(:, 1);
                     confi = stats.coeffs(:, 3:4);
                     [yfit, yconf] = predictlm(stats, t);
                  else
                     mdl = fitlm(t, y(:,n));
                     coeff = mdl.Coefficients.Estimate;
                     confi = coefCI(mdl, alpha);
                     [yfit, yconf] = predict(mdl, t, 'alpha', alpha);
                  end

                  abfit(n,:) = coeff;
                  error(n) = confi(2, 2) - abfit(n, 2); % symmetric for ols

                  % Plot the fit
                  % figure;
                  % plot(t, y(:, n), '-o'); hold on;
                  % plot(t, yfit, '-');
                  % plot(t, yconf, '--');

                  % [B,CI] = regress(y(:,n),[ones(size(t)) t],alpha);
                  % CB(:,1)= CI(1,1)+CI(2,1)*t;
                  % CB(:,2)= CI(1,2)+CI(2,2)*t;
                  % CB = anomaly(CB); % convert to anomalies?
               end
         end
      else
         % only get conf levels if requested
         if isnan(alpha)
            abfit(n, :) = quantreg(t, y(:, n), qtl);
         else
            [abfit(n, :), S] = quantreg(t, y(:, n), qtl, 1, 1000, alpha);
            confi = S.ci_boot';
            error(n) = mean([abfit(n, 2)-confi(2, 1), confi(2, 2)-abfit(n, 2)]);
         end

         yfit = transpose(abfit(:, 1) + abfit(:, 2) * t');
         yfit = setnan(yfit, [], inans);
      end
   end

   % this plots a histogram of the bootstrapped slopes from quantreg
   % figure; histogram(S.ab_boot(:,2));
   % this plots the data, the fit, and the bootstrapped fit from quantreg
   % figure; plot(t,y,'o'); hold on;
   % plot(S.xfit,S.yfit);
   % plot(S.xfit,S.yhatci_boot(:,2))
   % plot(S.xfit,S.yhatci_boot(:,1))
   %
   % print the bootstrapped slope plus or minus 1 stderr
   % [S.ab_boot(2)+S.se_boot(2) S.ab_boot(2)-S.se_boot(2)]
   % [S.ab_boot(2)+1.96*S.se_boot(2) S.ab_boot(2)-1.96*S.se_boot(2)]


   % % this is an old note not sure
   % % prior method, delete if above is considered best
   % if isregular(t,'months')
   %    nmonths = numel(t);
   %    t = years(t-t(1));
   % elseif isdatetime(t)
   %    t = year(t);
   % end
end

% MAKE THE FIGURE
function [h,makeleg,legidx] = updateFigure(useax,showfig,figpos,errorbounds)

   % if an axis was provided, use it, otherwise make a new figure
   if ~isaxis(useax)
      if showfig
         h.figure = figure('Position', figpos);
      else
         h.figure = figure('Position', figpos, 'Visible', 'off');
      end
      h.ax = gca;
   else
      h.ax = useax;
   end

   % The legend is parented by the figure, so if the figure contains
   % subplots, i can't just use findobj(gcf, 'Type', 'Legend') to determine
   % if the current plot has a legend already, which i want because I want
   % to add the next trendplot trendline to the existing legend
   % legobj = findobj(gcf, 'Type', 'Legend');

   figchi = get(gcf, 'Children');
   axobjs = findobj(gcf, 'Type', 'Axes');
   legobj = findobj(gcf, 'Type', 'Legend');

   numleg = numel(legobj); % 1 = one legend, 2 indicates a subplot
   numaxes = numel(axobjs);

   % assume we want to append onto an existing legend
   makeleg = numaxes>numleg || numleg==0;

   % assume only trendplots exist, each one has data + trend line, so the
   % number of trendlines is numlines/2, unless errorbounds is true

   axchilds = allchild(h.ax);  % get the children to find lines
   numchild = numel(axchilds);
   % above here og don't mess

   linesobjs = findobj(axchilds, 'type', 'line');
   patchobjs = findobj(axchilds, 'type', 'patch');
   errorobjs = findobj(axchilds, 'type', 'errorbar');

   % if only the error bars have handle visibility on, this should work.
   % also this shows that i can figure out how many have handlevis on and
   % use that to determine thislineidx. note, thislineidx is used to set
   % the color order, so repeated calls to trendplot use the same color for
   % the line/patch/errorbar, but it is also used to set the new legend text
   numlines = numel(linesobjs);
   %thislineidx = numlines+1;
   numpatch = numel(patchobjs);
   numebars = numel(errorobjs);

   % if we have one timeseries plotted, there will be two lineobj's (one
   % for the timeseries, and one for the trendline), so we want thislineidx
   % to evaluate to 2, but I think if errorbar is true, it means there will
   % be one line object (the trendline)

   % when i added errorbars, it worked to just do thislineidx = numlines+1,
   % until i plotted wihtout errorbarrs, then it didn't work, so I added this:
   if numebars > 0 && numebars == numlines
      thislineidx = numlines+1;
   elseif numebars == 0 && mod(numlines, 2) == 0
      thislineidx = numlines/2 + 1; % should always be two lines per plot
   else
      thislineidx = numlines+1;
   end

   % % this is the original
   % if errorbounds && mod(numchilds,2) == 1
   %    numlines = (numchilds-1)/2;
   %    thislineidx = numlines+1;
   % else
   %    numlines = numel(axchildren)/2;
   %    thislineidx = numlines+1;
   % end

   set(h.ax, 'ColorOrderIndex', thislineidx);

   hold on

   legidx = thislineidx;

   % % this version hides the -o lines so the legend shows - lines
   % h.plot = plot(useax, t, y, '-o', 'HandleVisibility', 'off', plotargs{:});
   % h.trend = plot(useax, t, ytrend, '-', 'Color', h.plot.Color, 'LineWidth', 1);
   % formatPlotMarkers
end

% PLOT TRENDS
function h = plotTrend(h,t,y,yfit,yerr,yci,errorbars,errorbounds,varargs)

   % see formaterrorbar script, might use instead of formatplotmarkers or
   % add the errorbar functionality to that one

   % plot errorbounds first
   if errorbounds

      % c = h.ax.ColorOrder(h.ax.ColorOrderIndex, :);
      c = get(h.ax, 'ColorOrder');
      c = c(get(h.ax, 'ColorOrderIndex'), :);

      Y = [yci(:, 2)' fliplr(yci(:, 1)')];
      X = [t' fliplr(t')];

      h.bounds = patch('XData', X, 'YData', Y, 'FaceColor', c, 'FaceAlpha', ...
         0.15, 'EdgeColor', 'none', 'Parent', h.ax, 'HandleVisibility', 'off');
   end

   if errorbars

      % formatPlotMarkers handles edgecolor, facecolor, and marker size
      h.plot = errorbar(h.ax, t, y, yerr,'-o');
      set(h.plot, 'LineWidth', 1.5, 'MarkerEdgeColor', [.5 .5 .5] );

   else % trendlines
      h.plot = plot(h.ax, t, y, '-o', 'LineWidth', 2, varargs{:});
   end

   h.trend = plot(h.ax, t, yfit, '-', 'Color', get(h.plot, 'Color'), ...
      'LineWidth', 1, 'HandleVisibility', 'off');
   formatPlotMarkers('markersize', 6, 'keepEdgeColor', true);
end

%  DRAW LEGEND
function h = drawLegend(h,ab,err,makeleg,legidx,precision,legtext,units,alpha)

   % this is repeated here and in updateFigure
   legobj = findobj(gcf,'Type','Legend');

   % only draw a legend if trend units were provided
   % if not(isempty(trendunits))

   % trendtext = sprintf(['%.2f ' trendunits ], ab(2));
   % textbox(trendtext, 50, 90, 'interpreter', 'tex', 'fontsize', 10);

   if isnan(precision)
      prec = ceil(abs(log10(ab(2))))+1;
   else
      prec = precision;
   end

   % log10(ab(2)) = the number of zeros to right or left of decimal
   % ceil(log10(ab(2))) = ceil gets you to the digit e.g.:
   % ceil(abs(log10(0.003))) = 3
   % ceil(abs(log10(300))) = 3
   % +1 gets you an extra digit of precision

   if prec > 5
      bexp = floor(log10(abs(ab(2))));
      bbase = ab(2)*10^-bexp;
      if isnan(alpha)
         trendtxt = sprintf( ...
            [legtext ' (trend: %.2fe$^{%.2f}$ ' units ')'], ...
            bbase, bexp);
      else
         errstr = num2str(round(100*(1-alpha)));

         % trendtxt = sprintf([legtext ' (trend: %.2fe$^{%.2f}' ...
         %    '$\\pm$ %.2f (' errstr '$\\%%$ CI)$ ' units ')'],...
         %    bbase,bexp,err);

         % to turn off the 95% Ci part:
         trendtxt = sprintf([legtext ' (trend: %.2fe$^{%.2f}' ...
            '\\pm$ %.2f ' units ')'],bbase,bexp,err);
      end
   else
      if isnan(alpha)
         trendtxt = sprintf( ...
            [legtext ' (trend: %.' num2str(prec) 'f ' units ')'], ...
            ab(2));
      else
         errstr = num2str(round(100*(1-alpha)));

         % trendtxt = sprintf([legtext ' (trend: %.' num2str(prec)  ...
         %    'f $\\pm$ %.' num2str(prec) 'f ('      ...
         %    errstr '$\\%%$ CI) ' units ')'],ab(2),err);

         % to turn off the 95% Ci part:
         trendtxt = sprintf([legtext ' (trend: %.' num2str(prec)  ...
            'f $\\pm$ %.' num2str(prec) 'f ' units ')'],ab(2),err);
      end
   end

   if makeleg % isempty(legobj)
      % h.legend = legend(h.trend, trendtxt, 'interpreter', 'latex');
      h.legend = legend(h.plot, trendtxt, 'Interpreter', 'latex');
   else
      % the current legend will be the first one, not numleg as I expected
      legobj(1).String{legidx} = trendtxt;
   end
end

%% INPUT PARSER
function [t, y, opts, vargs] = parseinputs(t, y, mfilename, varargin)

   parser = inputParser;
   parser.FunctionName = mfilename;
   % parser.PartialMatching = true;
   parser.KeepUnmatched = true;

   dpos = [321 241 512 384]; % default figure size

   parser.addRequired('t', @isdatelike);
   parser.addRequired('y', @isnumeric);
   parser.addParameter('units',        '',   @ischar);
   parser.addParameter('ylabeltext',   '',   @ischar);
   parser.addParameter('xlabeltext',   '',   @ischar);
   parser.addParameter('titletext',    '',   @ischar);
   parser.addParameter('legendtext',   '',   @ischar);
   parser.addParameter('method',       'ols',@ischar);
   parser.addParameter('alpha',        0.05, @isnumeric);
   parser.addParameter('anomalies',    true, @islogical);
   parser.addParameter('quantile',     nan,  @isnumeric);
   parser.addParameter('figpos',       dpos, @isnumeric);
   parser.addParameter('useax',        nan,  @isaxis);
   parser.addParameter('showfig',      true, @islogical);
   parser.addParameter('errorbars',    false,@islogical);
   parser.addParameter('errorbounds',  false,@islogical);
   parser.addParameter('reference',    nan,  @isnumeric);
   parser.addParameter('yerr',         nan,  @isnumeric);
   parser.addParameter('precision',    nan,  @isnumeric);

   parser.parse(t, y, varargin{:});
   opts = parser.Results;
   vargs = struct2varargin(parser.Unmatched);
end
