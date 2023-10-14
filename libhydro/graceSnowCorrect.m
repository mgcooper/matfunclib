function correctedG = graceSnowCorrect(G, SW, varargin)
   %GRACESNOWCORRECT Correct grace storage trends for surface snow storage
   %
   % this 'bias corrects' GRACE terrestrial water storage trends on a
   % month-by-month basis for trends in snow anomalies. The snow anomalies are 
   % computed on a month-by-month basis and subtracted from the monthly grace
   % anomalies, e.g. all january's are collected, one for each year, and their
   % linear trend subtracted to compute anomalies, then those anomalies are
   % subtracted from the corresponding grace anomalies
   %
   % See also: graceMinMax

   % parse inputs
   [G, SW, bimonthly, makeplot] = parseinputs(G, SW, mfilename, varargin{:});

   if bimonthly == true

      % the data have to be organized as timetables with each column a month
      % from Jan to Dec, and each row a year.

      if size(G, 2) ~= 12
         error('for option bimonthly, data size should be numyears x 12')
      end

      % find the Merra SWE data that overlaps the Grace data
      tmin = max(G.Time(1), SW.Time(1));
      tmax = min(G.Time(end), SW.Time(end)); %  + calmonths(11);
      idxS = isbetween(SW.Time, tmin, tmax);
      idxG = isbetween(G.Time, tmin, tmax);

      % Subset the merra snow water storage data that overlaps the grace storage
      SW = SW(idxS, :);
      G = G(idxG, :);

      % Determine if the data is posted on water years or calendar years and
      % build a calendar for the monthly timeseries
      imo = G.Time(1).Month;
      iyr = G.Time(1).Year;
      nyr = height(G);
      nmo = nyr*12;

      if G.Time(1).Month == 1
         T = tocolumn(datetime(iyr,imo,1):calmonths(1):datetime(iyr+nyr-1,12,1));
      elseif G.Time(1).Month == 10 % assume water years
         T = tocolumn(G.Time(1):calmonths(1):G.Time(end));
      end

      % reshape carefully. this is done so G and SW are compatible with G and
      % SW in the else block, so identical processing works thereafter
      G = reshape(transpose(table2array(G)),nmo,1);
      SW = reshape(transpose(table2array(SW)),nmo,1);

   else

      if sum(contains(SW.Properties.VariableNames,'SW')) == 0
         error('no SW variable in provided table')
      end

      % I did it both ways and there's ~no dif, so prob just use this method:
      tmpM = synchronize(G,SW,G.Time);
      SW = tmpM.SW;
      T = tmpM.Time;
      G = tmpM.G;
   end

   if makeplot == true % keep a copy of the original data
      Gcopy = G;
   end

   % get indices that are nan in the original data
   inan = isnan(G);

   % this eliminates the need to reshape so incomplete annual calendars work
   % eg if an extra january is passed in, all jan's get corrected
   for imonth = 1:12
      monthIndices = find(T.Month == imonth);
      G(monthIndices) = G(monthIndices) - anomaly(SW(monthIndices));
   end

   % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
   % uncomment this entire block to revert to prior method preserving
   % commented code and uncommented code.
   % % compute anomalies on a month-by-month basis
   % G = transpose(reshape(G,12,numel(G)/12));
   % SW = transpose(reshape(SW,12,numel(SW)/12));
   % % G = anomaly(G) - anomaly(SW);
   % G = G - anomaly(SW);
   % G = reshape(transpose(G),size(G,1)*size(G,2),1);
   %
   % % compute anomalies relative to the entire period
   % % G = (G-nanmean(G))-(SW-nanmean(SW));
   % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

   correctedG = timetable(G,'RowTimes',T);
   correctedG = setnan(correctedG, [], inan);
   % I confirmed there is no need to anomaly again
   % do I want to return it back as a monthly table?

   if makeplot == true
      % compare the og grace to snow-corrected grace
      trendplot(T,Gcopy,'leg','no correction');
      trendplot(T,correctedG.G,'use',gca,'leg','with correction');
   end

   % % TEST - seems like the trend in each month should be removed ...
   % G = transpose(reshape(G,12,numel(G)/12));
   % SW = transpose(reshape(SW,12,numel(SW)/12));
   % % Gc = anomaly(G) - anomaly(SW);
   % Gc = G - anomaly(SW);
   % Tannual = datetime(unique(year(T)),1,1);
   % macfig;
   % for n = 1:12
   %    trendplot(Tannual,G(:,n),'leg','G','use',gca);
   %    trendplot(Tannual,SW(:,n),'leg','SW','use',gca);
   %    trendplot(Tannual,G(:,n)-SW(:,n),'leg','G-SW','use',gca);
   %    trendplot(Tannual,Gc(:,n),'leg','Gc','use',gca);
   %    title(num2str(n)); pause; clf
   % end
   % % END TEST


   % the problem with the snow correction is that the snow anomaly can be
   % larger than Grace ... which may be fine ... but for now ignore snow so i
   % can move on, and check in with kurt or the group abou tit
   % si = 13;
   % ei = 24;
   % figure;
   % plot(GraceM.Time(si:ei),SW(si:ei)); hold on;
   % plot(GraceM.Time(si:ei),G(si:ei));
   % plot(GraceM.Time(si:ei),Gc(si:ei)); legend('SWE','S','S-SWE');
end

%%
function [G, SW, bimonthly, makeplot] = parseinputs(G, SW, funcname, varargin)

   parser = inputParser;
   parser.FunctionName = funcname;
   parser.PartialMatching = true;

   % parser.addRequired('T',@(x)isdatetime(x));
   parser.addRequired('G', @istimetable);
   parser.addRequired('SW', @istimetable);
   parser.addParameter('bimonthly', false, @islogical);
   parser.addParameter('makeplot', false, @islogical);
   parser.parse(G, SW, varargin{:});

   bimonthly = parser.Results.bimonthly;
   makeplot = parser.Results.makeplot;
end
