function varargout = plotLinReg(x, y, DisplayOpts, LineOpts)
   %PLOTLINREG Plot linear regression.
   %
   %  [H, L, Fit] = plotLinReg(x, y)
   %  [H, L, Fit] = plotLinReg(x, y, "ConfidenceIntervals", true)
   %  [H, L, Fit] = plotLinReg(x, y, "LineOnly", true)
   %  [H, L, Fit] = plotLinReg(x, y, Name, Value)
   %
   % Description:
   %  [H, L, Fit] = plotLinReg(x, y) plots the data in x and y and a linear
   %  regression line of the form y = a*x + b. Accepts Name, Value arguments
   %  accepted by PLOT (i.e., LINE properties).
   %
   % Example:
   %    x = randi(100, 100, 1);
   %    y = 2.*x + 100.*rand(100, 1);
   %    plotLinReg(x, y)
   %
   %    % Apply line properties
   %    plotLinReg(x, y, "LineStyle", ":", "Color", 'm')
   %
   %    % Add confidence intervals
   %    plotLinReg(x, y, "ConfidenceIntervals", true)
   %
   %    % Apply line properties
   %    plotLinReg(x, y, "ConfidenceIntervals", true, "Color", 'r')
   %
   %    % Plot the data first, then add a linear regression line:
   %    figure
   %    plot(x, y, 'o'); hold on
   %    plotLinReg(x, y, "LineOnly", true)
   %
   %    % Apply line properties:
   %    plotLinReg(x, y, "LineOnly", true, "Color", 'm', "LineStyle", '-', "LineWidth", 5)
   %
   % See also: addOneToOne

   arguments
      x {mustBeNumericOrDatetime}
      y {mustBeNumeric}
      DisplayOpts.LineOnly (1,1) logical = false
      DisplayOpts.BoundedLine (1,1) logical = true
      DisplayOpts.ConfidenceIntervals (1,1) logical = false
      LineOpts.?matlab.graphics.chart.primitive.Line
   end

   % Populate LineOpts with all line properties
   %LineOpts = metaclassDefaults(LineOpts, ?matlab.graphics.chart.primitive.Line);

   % Override default BoxChart settings
   ResetFields = {'Color', 'LineWidth'};
   ResetValues = {rgb('Medium Blue'), 2};
   for n = 1:numel(ResetFields)
      if ~ismember(ResetFields{n}, fieldnames(LineOpts))
         LineOpts.(ResetFields{n}) = ResetValues{n};
      end
   end
   LineOpts = namedargs2cell(LineOpts);

   % Keep held state
   washeld = ishold();
   hold on

   % Cast datetime input to datenum.
   wasdatetime = isdatetime(x);
   if wasdatetime
      x = datenum(x);
   end

   % Remove missing data
   xnaninds = find(isnan(x));
   ynaninds = find(isnan(y));
   x(unique([xnaninds;ynaninds])) = [];
   y(unique([xnaninds;ynaninds])) = [];

   % Fit the data
   [P, S] = polyfit(x, y, 1);
   yfit = polyval(P, x);

   Fit.p = P;
   Fit.S = S;
   Fit.slope = P(1);
   Fit.intercept = P(2);

   % Square the residuals and total them obtain the residual sum of squares
   Fit.resid = y - yfit;
   Fit.SSresid = sum(Fit.resid.^2);

   % Compute the total sum of squares of y by multiplying the variance of y by
   % the number of observations minus 1
   N = numel(y);
   Fit.SStotal = (N-1) * var(y);

   % Compute R2 using the formula given in the introduction of this topic
   Fit.rsq = 1 - Fit.SSresid / Fit.SStotal;

   % Compute the standard error and p-value for the slope.
   SE = sqrt(Fit.SSresid / (N-2) / sum((x - mean(x)).^2));
   t_stat = Fit.slope / SE;

   % Use 'upper' for a better estimate of extremely small p-values.
   Fit.pval = 2 * tcdf(abs(t_stat), N-2, 'upper');

   % Determine the requisite precision to print the p value in the legend
   prec = ceil(log10(Fit.pval));

   % Extend the xfit by +/- X% of the data range
   sx = 0.05*(max(x)-min(x));

   % build x fit vector and predict y at high sampling res
   xfit = linspace(min(x)-sx, max(x)+sx, 100);
   yfit = polyval(P, xfit);

   % get confidence intervals
   [~,DELTA] = polyconf(P,xfit,S,'predopt','curve');

   % option to only plot the line
   if DisplayOpts.LineOnly
      H = line(xfit,yfit,'LineStyle','--',LineOpts{:});
   else

      % Plot the data and the linear fit
      % H(1) = scatter(x, y, 45, ...
      %    'MarkerEdgeColor', [0 .5 .5],...
      %    'MarkerFaceColor', [0 .7 .7],...
      %    'LineWidth', 1);
      H(1) = plot(x, y, ...
         'Marker', 'o', ...
         'MarkerSize', 8, ...
         'MarkerEdgeColor', [0 .5 .5],...
         'MarkerFaceColor', [0 .7 .7],...
         'LineWidth', 1);

      H(2) = line(xfit, yfit, LineOpts{:});

      % Add a dummy plot for the r2 and p value in legend
      H(3) = plot(xfit(1), yfit(1), 'color', 'none');

      % Legend text
      ltxt = {
         'Data' , ...
         ['Fit = ' printf(P(1),3) 'x + ' printf(P(2),1)] , ...
         ['(r2 = ' printf(Fit.rsq,2)  ', p<10^{' printf(prec,0) '})'], ...
         '95% Confidence Intervals' , ...
         };

      % Plot the CIs if requested
      if DisplayOpts.ConfidenceIntervals

         if DisplayOpts.BoundedLine
            H(4) = fillplot(xfit, yfit, DELTA, rgb('bright blue'), ...
               'FaceAlpha', 0.3);
            uistack(H(2), 'top') % stack the line on top of the bounded line
            uistack(H(1), 'top') % stack the data markers on top
         else
            H(4:5) = plot(xfit,yfit(:)+[DELTA(:) -DELTA(:)], '--', ...
               'Color',rgb('Medium Blue'));
         end
         ileg = 1:4;
      else
         ileg = 1:3;
      end

      % Create the legend with the r2 and p value on the last line
      L = legend(H(ileg), ltxt(ileg));

      % Put the legend in the upper left (right) if positive (negative) slope
      if Fit.slope > 0
         L.Location = 'Northwest';
      elseif Fit.slope < 0
         L.Location = 'Northeast';
      else
         L.Location = 'Best';
      end

      H(numel(H)+1) = L;
      H(3) = [];
   end

   box off
   set(gca,'TickDir','out');

   if wasdatetime
      datetick('x')
   end

   if ~washeld
      hold off
   end

   % Prepare outputs
   Fit.xfit = xfit;
   Fit.yfit = yfit;
   Fit.yupper = yfit+DELTA;
   Fit.ylower = yfit-DELTA;

   switch nargout
      case 1
         varargout{1} = H;
      case 2
         varargout{1} = H;
         varargout{2} = Fit;
   end

   % % Using fitlm for p value and CIs
   % LM = fitlm(x, y);
   % Fit.pval = LM.Coefficients.pValue(2);
   % [yfit, yci] = predict(LM, xfit(:));
   % DELTA = yci(:, 2) - yfit;
end
