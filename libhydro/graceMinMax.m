function [GL, GH, imin, imax] = graceMinMax(G, time, varargin)
   %GRACEMINMAX Compute minimum and maximum monthly GRACE values annually.
   %
   %    [GL, GH, imin, imax] = graceMinMax(G, time)
   %    [GL, GH, imin, imax] = graceMinMax(G, time, aswateryears=true)
   %    [GL, GH, imin, imax] = graceMinMax(G, time, minaftermax=true)
   %    [GL, GH, imin, imax] = graceMinMax(G, time, plotfig=true)
   %    [GL, GH, imin, imax] = graceMinMax(G, time, validmonthsmin=validmonths)
   %    [GL, GH, imin, imax] = graceMinMax(G, time, validmonthsmax=validmonths)
   %
   % Description
   %
   %    [GL, GH, imin, imax] = graceMinMax(G, time)
   %
   % See also: graceSnowCorrect graceGapFill

   % note: water year + snow correction substantially changes the GL timing

   % parse iputs
   [G, time, opts] = parseinputs(G, time, mfilename, varargin{:});

   % for min/max, use calendar year, or any method that doesn't break the year
   % around Jul-Nov (to find the min) or Apr - Jun (to find the max)

   % % use this to test the effect of using water years to find the min
   % tempM = G(2:end-1,:);
   % nyears = height(tempM.G)/12;
   % GraceMY = reshape(tempM.G,12,nyears);
   % figure;  monthplot(nanmean(GraceMY,2),'wateryear', true);

   % try adjusting to cal years

   if opts.aswateryears
      i1 = find(month(time) == 10, 1, 'first');
      i2 = find(month(time) == 9, 1, 'last');
   else
      i1 = find(month(time) == 1, 1, 'first');
      i2 = find(month(time) == 12, 1, 'last');
   end

   % Reshape G to [month x year]
   G = G(i1:i2, :);
   N = height(G) / 12;
   G = reshape(G, 12, N);

   % Compute min and max values each year
   [imin, imax, GL, GH] = deal(nan(N, 1));
   for n = 1:N

      [imin(n), GL(n)] = findglobalmin(G(opts.validmonthsmin,n), 1, 'last');
      [imax(n), GH(n)] = findglobalmax(G(opts.validmonthsmax,n), 1, 'last');

      % correct for validmonths offset
      imin(n) = imin(n) + opts.validmonthsmin(1) - 1;
      imax(n) = imax(n) + opts.validmonthsmax(1) - 1;

      if opts.plotcheck
         if n == 1
            figure
         end
         hold on

         monthplot(G(:,n), 'wateryear', opts.aswateryears)
         if ~isnan(imin(n))
            scatter(imin(n), G(imin(n), n), 'filled')
         else
            textbox('no min found', 10, 10)
         end
         if ~isnan(imax(n))
            scatter(imax(n), G(imax(n), n), 'filled')
         else
            textbox('no max found', 10, 30)
         end
         title(num2str(year(time(1))+n-1))
         pause
         clf
      end
   end

   % note: if the monthly data have been converted to anomalies, then the
   % monthly means will be ~zero,
   if opts.plotfig

      macfig('size','horizontal')

      subplot(1,3,1)
      monthplot(mean(G,2,'omitnan'),'wateryear',opts.aswateryears)
      set(gca,'XTickLabelRotation',45)
      ylabel('S, annual average')

      subplot(1,3,2)
      monthplot(imin(~isnan(imin)),'plottype','hist')
      xlabel('min month')

      subplot(1,3,3)
      monthplot(imax(~isnan(imax)),'plottype','hist')
      xlabel('max month')

      % subplot(1,3,2); histogram(imin(~isnan(imin))); xlabel('min month');
      % subplot(1,3,3); histogram(imax(~isnan(imax))); xlabel('max month')
   end
end

%% INPUT PARSER
function [G, Time, opts] = parseinputs(G, Time, mfilename, varargin)

   parser = inputParser;
   parser.FunctionName = mfilename;
   parser.addRequired('G', @isnumericvector);
   parser.addRequired('Time', @isdatelike);
   parser.addParameter('aswateryears', false, @islogicalscalar);
   parser.addParameter('minaftermax', false, @islogicalscalar);
   parser.addParameter('plotfig', false, @islogicalscalar);
   parser.addParameter('plotcheck', false, @islogicalscalar);
   parser.addParameter('validmonthsmin', 1:12, @isnumericvector);
   parser.addParameter('validmonthsmax', 1:12, @isnumericvector);
   parser.parse(G, Time, varargin{:});

   opts = parser.Results;
end
