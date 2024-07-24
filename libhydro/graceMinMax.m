function [GL,GH,imin,imax] = graceMinMax(G,varargin)
   %GRACEMINMAX Compute minimum and maximum monthly GRACE values annually.
   %
   %
   %
   % See also: graceSnowCorrect graceGapFill

   % parse iputs
   [G, opts] = parseinputs(G, mfilename, varargin{:});

   % for min/max, use calendar year, or any method that doesn't break the year
   % around Jul-Nov (to find the min) or Apr - Jun (to find the max)

   % % use this to test the effect of using water years to find the min
   % tempM = G(2:end-1,:);
   % nyears = height(tempM.G)/12;
   % GraceMY = reshape(tempM.G,12,nyears);
   % figure;  monthplot(nanmean(GraceMY,2),'wateryear', true);

   % try adjusting to cal years

   if opts.wateryear == true
      i1 = find(month(G.Time) == 10, 1, 'first');
      i2 = find(month(G.Time) == 9, 1, 'last');
   else
      i1 = find(month(G.Time) == 1, 1, 'first');
      i2 = find(month(G.Time) == 12, 1, 'last');
   end

   tempM = G(i1:i2, :);
   nyears = height(tempM.G)/12;
   GraceMY = reshape(tempM.G, 12, nyears); % month-by-year

   imin = nan(nyears, 1);
   imax = nan(nyears, 1);
   GL = nan(nyears, 1);
   GH = nan(nyears, 1);

   % note: water year + snow correction substantially changes the GL timing

   for n = 1:nyears

      [imin(n),GL(n)] = findglobalmin(GraceMY(opts.validmonthsmin,n),1,'last');
      [imax(n),GH(n)] = findglobalmax(GraceMY(opts.validmonthsmax,n),1,'last');

      % correct for validmonths offset
      imin(n) = imin(n) + opts.validmonthsmin(1) - 1;
      imax(n) = imax(n) + opts.validmonthsmax(1) - 1;

      if opts.plotcheck == true
         if n == 1; figure; end

         monthplot(GraceMY(:,n), 'wateryear', opts.wateryear); hold on;
         if ~isnan(imin(n))
            scatter(imin(n), GraceMY(imin(n), n), 'filled');
         else
            textbox('no min found', 10, 10);
         end
         if ~isnan(imax(n))
            scatter(imax(n), GraceMY(imax(n), n), 'filled');
         else
            textbox('no max found', 10, 30);
         end
         title(num2str(year(G.Time(1))+n-1)); pause; clf;
      end
   end

   % note: if the monthly data have been converted to anomalies, then the
   % monthly means will be ~zero,
   if opts.plotfig == true

      macfig('size','horizontal');

      subplot(1,3,1);
      monthplot(mean(GraceMY,2,'omitnan'),'wateryear',opts.wateryear);
      set(gca,'XTickLabelRotation',45)
      ylabel('S, annual average')

      subplot(1,3,2);
      monthplot(imin(~isnan(imin)),'plottype','hist');
      xlabel('min month');

      subplot(1,3,3);
      monthplot(imax(~isnan(imax)),'plottype','hist');
      xlabel('max month')

      % subplot(1,3,2); histogram(imin(~isnan(imin))); xlabel('min month');
      % subplot(1,3,3); histogram(imax(~isnan(imax))); xlabel('max month')
   end
end

%% INPUT PARSER
function [G, opts] = parseinputs(G, mfilename, varargin)

   parser = inputParser;
   parser.FunctionName = mfilename;
   parser.PartialMatching = true;
   parser.addRequired('G', @istimetable);
   parser.addParameter('wateryear', false, @islogical);
   parser.addParameter('minaftermax', false, @islogical);
   parser.addParameter('plotfig', false, @islogical);
   parser.addParameter('plotcheck', false, @islogical);
   parser.addParameter('validmonthsmin', 1:12, @isnumeric);
   parser.addParameter('validmonthsmax', 1:12, @isnumeric);
   parser.parse(G, varargin{:});

   opts = parser.Results;
end
