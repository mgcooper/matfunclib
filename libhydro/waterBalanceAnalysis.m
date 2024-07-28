function PER = waterBalanceAnalysis(MonthlyData, varargin)
   %waterBalanceAnalysis Compute water balance dS/dt=P-E-R and trends in each.
   %
   %    PER = waterBalanceAnalysis(MonthlyData)
   %    PER = waterBalanceAnalysis(MonthlyData, 'aswateryears', true)
   %    PER = waterBalanceAnalysis(MonthlyData, 'RemoveSnowMass', true)
   %
   %  NOTE: Basically don't use aswateryears=true. Instead just use the October
   %  column. But keep it around until fully worked out.
   %
   %  Also, if used in conjunction with annualdMdt, the values returned by that
   %  function are fully compatible with this one, e.g., if instantaneous snow
   %  mass is converted to an annual flux by passing SW into annualdMdt, the
   %  returned value dSWdt (and the calendar its registered to) represent the
   %  "same thing" (water balance quantities) expected by this function. To do
   %  that, first add dSWdt to the monthlyData column passed into this function,
   %  but note that for now, this function expects that column to be named "SW"
   %  or "SWE".
   %
   % Description
   %
   %    PER = waterBalanceAnalysis(MonthlyData) returns struct PER containing
   %    timetables of annual, monthly, and seasonal water balance components
   %    from the monthly components in MonthlyData. MonthlyData must be a
   %    timetable which contain variables P, E, and R.
   %
   %    PER = waterBalanceAnalysis(MonthlyData,'RemoveSnowMass',true) optionally
   %    applies a snow bias correction to remove the influence of above-ground
   %    snowpack storage on computed dS/dt trends. There must be a column in
   %    MonthlyData named 'SW' which represents the rate of change of
   %    aboveground snow water storage, in the same units as the other water
   %    balance components (nominally cm/yr, or any self-consistent units).
   %
   %    PER = waterBalanceAnalysis(MonthlyData,'aswateryears',true) optionally
   %    specifies that the data in MonthlyData are on a water year calendar.
   %    Assumes the first month is 10/1 of the first year in the data record,
   %    and 9/1 is the last month.
   %
   %  Inputs
   %
   %    MONTHLYDATA timetable of water balance components [cm/yr] posted
   %    monthly. MONTHLYDATA must contain the variables P, E, and R.
   %
   %    ASWATERYEARS (optional) logical name-value pair indicating if the
   %
   %    REMOVESNOWMASS (optional) logical name-value pair indicating if snow
   %    water storage is removed from the water balance. If REMOVESNOWMASS is
   %    true, MONTHLYDATA must contain a variable named SW (or SWE) which
   %    represents the rate of change of stored snow in units of cm water
   %    equivalent per year. Use this option to analyze the soil water balance,
   %    by removing the snow mass component of the total water balance. This
   %    could be done by using P,E,R, and SW from a climate model.
   %
   %  Outputs
   %
   %     PER.AVG - The average PER over all timesteps (all months). Obtain the
   %     annual average PER from the PER.annual.avg.<MMM> table, using a month
   %     of your choice to define a water-year. For instance, use
   %     PER.annual.avg.Jan to obtain the
   %
   %     PER.ANNUAL.PER - Annual P-E-R i.e. for each year, sum P,E, and R over
   %     12 months, with 12-month periods beginning on each of the 12 calendar
   %     months, then compute P-E-R for each year
   %
   %     PER.ANNUAL.AB - the linear regression intercept (a) and slope (b) of
   %     the annual P-E-R values from the step above against time in years
   %
   %     PER.MONTHLY.PER - as above, P-E-R for each month (not annual sums
   %     centered on each month, the actual monthly P-E-R)
   %
   %     PER.MONTHLY.AB - the linear regression as above on the monthly P-E-R
   %
   %     PER.seasonal ... analogous with monthly but for three-month averages
   %
   %
   % Matt Cooper, 20-Feb-2022, mgcooper@github.com
   %
   % See also annualdMdt graceSnowCorrect merraWaterBalance
   %
   % Note: the PER.annual.PER values can be confusing because they're computed
   % by defining "month years" - years which begin on each month. Think of these
   % like the start months of water years: WY 2000 goes from oct1 1999 to sep30
   % 2000, and is posted to Oct 1999 in the PER.annual.PER table.
   %
   % Although it might seem logical to post WY 2000 to Sep or Oct 2000, the same
   % protocol would post a 'water year' beginning feb1 1999 ending jan31 2000 to
   % Jan or Feb 2000, even though most of the "water year" was in 1999.
   %
   % UPDATE: May revisit the logic above and instead post annual sums to the end
   % month. Thinking in terms of "annual sums", and the end month, may be
   % clearer than "calendar year" and "water year".

   % Parse inputs.
   [MonthlyData, P, E, R, SW, AnnualTime, aswateryears] ...
      = parseinputs(MonthlyData, mfilename, varargin{:});

   % Define functions to compute annual and seasonal water balance.
   % Note that sw=0 if RemoveSnowMass==false.
   F_annualsum = @(x) sum(x, 'includenan');
   F_annualavg = @(x) mean(x, 'includenan');
   F_seasonavg = @(p,e,r,sw,t) mean( p(:,t) - e(:,t) - r(:,t) - sw(:,t), 2);

   % Make a cell array of month names.
   months = cellstr(datestr(MonthlyData.Time(1:12), 'mmm'));

   % Make a cell array of season names. Note the time adjustment.
   if aswateryears
      seasons = {...
         'ON','OND','NDJ','DJF','JFM','FMA','MAM','AMJ','MJJ','JJA','JAS','AS'};

      % Shift forward to Jan 1 of the water year.
      AnnualTime = AnnualTime+calmonths(3);
   else
      seasons = {...
         'JF','JFM','FMA','MAM','AMJ','MJJ','JJA','JAS','ASO','SON','OND','ND'};
   end

   % Compute the total number of months and years to initialize output.
   nmonths = numel(P);
   nyears = nmonths / 12;

   % Init the monthly, seasonal, and annual dS/dt arrays.
   dSdtS = nan(nyears, 12);
   dSdtA = nan(nyears, 12);

   % Init arrays to store trends in S computed on an annual basis for each
   % month, each season, and each 12-month period beginning on each month.
   abSM = nan(2, 12);
   abSS = nan(2, 12);
   abSA = nan(2, 12);

   %%% 1. Compute dSdtM: annual timeseries of MONTHLY dSdt.
   %
   % dSdtM has twelve columns, each an annual timeseries of monthly (not annual)
   % dSdt. Use these to answer questions such as: What is the August water
   % balance each year? What is the average August water balance? Is there a
   % trend in the August water balance?

   dSdtM = P-E-R-SW; % Note: SW=0 if RemoveSnowMass=false.

   %%% 2. Compute dSdtA: annual timeseries of ANNUAL dSdt.
   %
   % dSdtA has twelve columns, each an annual timeseries of annual dSdt computed
   % by using each month as the START month for a year. Use these to answer
   % questions such as: What is the annual water balance each year, considering
   % October-September as the definition of a year? Or considering any arbitrary
   % definition of "year" such as April-March or August-July.
   %
   % NOTE: "years" are currently defined in terms of their START year/month.
   % This is the OPPOSITE of a traditional water year which is designated by the
   % calendar year in which it ends. Simply shift the time column forward one
   % year to obtain the water year.

   % Note: the 12-month avg/sum for the last year can only be computed for
   % 12-month periods beginning on the first month, so we can either omit the
   % last year or include it then mask the 2:12 values before computing trends.

   % This loop creates an annual timetable for each month. Each annual timetable
   % has the annual average water balance components for a year defined as
   % beginning on that month. Thus it produces dSdtA with nyears*12 values. If
   % its decided to post "month years" on the end month, simply shift the
   % calendar forward at the end, because retime posts to the start month.
   for imonth = 1:12

      % Get the start / end of the monthly timeseries, used to retime to years.
      i1 = imonth;
      i2 = nmonths;           % use this to include all years
      % i2  = nmonths-(13-n); % use this to omit the last year

      % Create an annual timeseries of 12-month averages beginning this month
      AnnualData = retime(MonthlyData(i1:i2, :), ...
         'regular', F_annualavg, 'TimeStep', calyears(1));

      % Note: on imonth=1, these are equivalent to AnnualData:
      debug = false;
      if debug == true
         T1 = retime(MonthlyData, 'regular', F_annualavg, 'TimeStep', calyears(1));
         T2 = retime(MonthlyData, 'yearly', 'mean');
         PER1 = AnnualData.P(1) - AnnualData.E(1) - AnnualData.R(1);
      end

      % Compute annual timeseries of annual (12-month avg) dSdt for this month
      dSdtA(:, imonth) = ...
         AnnualData.P - AnnualData.E - AnnualData.R - AnnualData.SW;

      % to check the effect of snow correction on trends:
      % trendplot(year(T), dSdt, 'leg', 'dSdt', 'use', gca);
      % trendplot(year(T), SW(n,:)', 'leg', 'SW', 'use', gca)
      % trendplot(year(T), dSdt-SW(n,:)', 'leg', 'dSdt-SW', 'use', gca)

      % for reference, this accomplishes the same thing as the retime step:
      % PA = sum(reshape(Merra.P(i1:i2), 12, nyears-1));
      % EA = sum(reshape(Merra.E(i1:i2), 12, nyears-1));
      % RA = sum(reshape(Merra.R(i1:i2), 12, nyears-1));
      % SWA = sum(reshape(Merra.SW(i1:i2), 12, nyears-1));
   end


   % Mask the last values which are partial sums for all but the first month.
   % Note this is completely independent of whether annual sums are posted to
   % the first or last month - these are partial sums regardless and are nan.
   dSdtA(end, 2:12) = nan;

   %%% 3. Compute dSdtS: annual timeseries of SEASONAL dSdt.
   %
   % dSdtS has twelve columns, each an annual timeseries of SEASONAL (not
   % annual) dSdt. Use these to answer questions such as: What is the
   % August-September-October (ASO) water balance each year? What is the average
   % ASO water balance? Is there a trend in the ASO water balance?
   %
   % NOTE: These are not annual dSdt values averaged over custom "month years".
   % These are analogous to dSdtM. To obtain dSdt values on an annual basis for
   % a seasonal period such as ASO, e.g., to smooth out fluctuations in water
   % balance closure, either add a new method to this function or simply average
   % the dSdtA values over those months.

   for imonth = 1:12

      % Get the indices to average over.
      if imonth == 1
         idx = imonth:imonth+1;
      elseif imonth==12
         idx = imonth-1:imonth;
      else
         idx = imonth-1:imonth+1;
      end

      % apply the snow correction or not and compute P-E-R
      dSdtS(:, imonth) = F_seasonavg(P, E, R, SW, idx);
   end

   % 4. compute linear trends, if there are more than two points
   if size(dSdtM, 1) > 2
      for imonth = 1:12

         abSM(:,imonth) = olsfit(year(AnnualTime), dSdtM(:,imonth));
         abSS(:,imonth) = olsfit(year(AnnualTime), dSdtS(:,imonth));
         abSA(:,imonth) = olsfit(year(AnnualTime), dSdtA(:,imonth));

         % Use this to omit the last year.
         % abSA(:,n) = olsfit(year(T(1:end-1)),dSdtA(:,n));
      end
   end

   % save the period-average PER, and the calendar-year trend
   PER.avg           = mean(MonthlyData.S, 'omitnan');
   PER.annual.PER    = array2timetable(dSdtA,'VariableNames',months,'RowTimes',AnnualTime);
   PER.monthly.PER   = array2timetable(dSdtM,'VariableNames',months,'RowTimes',AnnualTime);
   PER.seasonal.PER  = array2timetable(dSdtS,'VariableNames',seasons,'RowTimes',AnnualTime);
   PER.annual.ab     = array2table(abSA,'VariableNames',months);
   PER.monthly.ab    = array2table(abSM,'VariableNames',months);
   PER.seasonal.ab   = array2table(abSS,'VariableNames',seasons);

   PER.annual.avg    = array2table(mean(dSdtA, 1, 'omitnan'),'VariableNames',months);
   PER.monthly.avg   = array2table(mean(dSdtM, 1, 'omitnan'),'VariableNames',months);
   PER.seasonal.avg  = array2table(mean(dSdtS, 1, 'omitnan'),'VariableNames',seasons);

   % PER.annual.avg = array2timetable( ...
   %    nanmean(dSdtA,2),'VariableNames',{'PER'},'RowTimes',T);

   PER.readme = ['the PER.annual.PER arrays are 12-month sums where each ' newline ...
      'column defines a 12-month year beginning on the ' newline ...
      'column month. For example, to use traditional water ' newline ...
      'years, choose the Oct column, and shift the time ' newline ...
      'calendar one year forward to get the water year.'];

   % Maybe it would be clearer to use tables:
   % test = timetable2table(PER.annual.PER);
   % test.start_year = year(test.Time);
   % test.end_year = year(test.Time) + 1;
end

%% Input parser
function [MonthlyData, P, E, R, SW, timeAnnual, aswateryears] = ...
      parseinputs(MonthlyData, mfilename, varargin)

   parser = inputParser;
   parser.FunctionName = mfilename;
   parser.addRequired('MonthlyData', @istimetable);
   parser.addParameter('RemoveSnowMass', false, @islogicalscalar);
   parser.addParameter('aswateryears', false, @islogicalscalar);
   parser.parse(MonthlyData, varargin{:});

   RemoveSnowMass = parser.Results.RemoveSnowMass;
   aswateryears = parser.Results.aswateryears;

   % Ensure there are an even number of years.
   assert(mod(height(MonthlyData), 12) == 0)

   % TODO: if aswateryears=true, confirm the calendar begins October

   % Ensure the variable names include P, E, R (and possibly SW or SWE).
   [~, found] = parseFieldNames(MonthlyData, {'P', 'E', 'R', 'SW', 'SWE'});

   foundPER = all(ismember({'P', 'E', 'R'}, found));
   foundSWE = any(ismember({'SW', 'SWE'}, found));

   assert(foundPER, 'Provide a table or struct with P, E, R fields.');

   % Ensure the variable names include SW if snow mass correction requested.
   if RemoveSnowMass
      assert(foundSWE, ...
         ['No SW (snow water) variable in provided table ' ...
         '(required if RemoveSnowMass=true)'])
   else
      % Set it to zero if it exists
      if foundSWE
         MonthlyData{:, found(ismember(found, 'SW'))} = 0;
         MonthlyData{:, found(ismember(found, 'SWE'))} = 0;
      end
   end

   % Prepare monthly timestep P-E-R column vectors.
   P = transpose(reshape(MonthlyData.P, 12, []));
   E = transpose(reshape(MonthlyData.E, 12, []));
   R = transpose(reshape(MonthlyData.R, 12, []));

   % Prepare monthly timestep SW column vector, which is either non-zero or
   % was set to zero if RemoveSnowMass==false.
   if ismember('SW', found)
      SW = transpose(reshape(MonthlyData.SW, 12, []));
   elseif ismember('SWE', found)
      SW = transpose(reshape(MonthlyData.SWE, 12, []));
   else
      SW = zeros(size(P));
   end

   % Ensure the timetable time variable is named Time.
   MonthlyData.Properties.DimensionNames{1} = 'Time';

   % Make an annual calendar.
   timeAnnual = transpose(MonthlyData.Time(1):calyears(1):MonthlyData.Time(end));
end

%% Notes on start/end definition of "month years"

% TLDR: Below lead me to decide I should use the year in which a "month year"
% ends to designate the year-name, which is consistent with water years, but
% would mean posting calendar year 2001 to Dec 2001. For now I decided against
% this, instead the key is to simply remember that month years are defined in
% terms of the START month.

% The calendar year is the 12 month period ending December 31 of that year
% The water year is the 12 month period ending September 30 of that year
% The "month year" is the 12 month period ending Jul-Dec 3X of that year
%
% Therefore if using calendar years, all full years of data are useable,
% but if using "water" or "month" years, the first year X months are
% unuseable, where X = the month number, with X=9 for a water year ending in
% September, and X=7,8,9,10,11 for additional "month" years ending July-Dec.
% Note that the actual most confusing part is how to set the date in the time
% table - is calendar year 2001 posted to Jan 2001 or Dec 2001? If Jan 2001,
% then it's confusing b/c it implies the forward 12 months, whereas WY 2001
% would need to be posted Oct 2000 to imply the forward 12 months. Note how
% only the end year is consistent among the three definitions:
%
% Month  start       end         cy    wy    my    #cy   #wy   #my
% Jan    Jan 2001    Dec 2001    2001  -     2001  12/0  9/3   12/0
% Feb    Feb 2001    Jan 2002    -     -     -     11/1  8/4
% Mar    Mar 2001    Feb 2002    -     -     -     10/2  7/5
% Apr    Apr 2001    Mar 2002    -     -     -     9/3   6/6
% May    May 2001    Apr 2002    -     -     -     8/4   5/7
% Jun    Jun 2001    May 2002    -     -     -     7/5   4/8
% Jul    Jul 2001    Jun 2002    -     -     -     6/6   3/9
% Aug    Aug 2001    Jul 2002    -     -     2002  5/7   2/10  5/7
% Sep    Sep 2001    Aug 2002    -     -     2002  4/8   1/11  4/8
% Oct    Oct 2001    Sep 2002    -     2002  2002  3/9   12    3/9
% Nov    Nov 2001    Oct 2002    -     -     2002  2/10  11/1  2/10
% Dec    Dec 2001    Nov 2002    -     -     2002  1/11  10/2  1/11
% Jan    Jan 2002    Dec 2002    2002  -     2002  12/0  9/3   12/0
%
% So if the data begins Jan 2001, we can compute the Jan 2001 - Dec 2001
% calendar year posted to Jan 2001, and then compute Oct 2001 - Sep 2002
% water year posted to Oct 2001, but the actual water year is 2002, so
% instead we post the 2001 calendar year to Dec 2001, the 200
%
% If the data begins Jan 2001, the annual sums are posted like this:
% Aug 2001 - Jul 2002 posted to Jul 2002
% Sep 2001 - Aug 2002 posted to Aug 2002
% Oct 2001 - Sep 2002 posted to Sep 2002
% Nov 2001 - Oct 2002 posted to Oct 2002
% Dec 2001 - Nov 2002 posted to Nov 2002
% Jan 2002 - Dec 2002 posted to Dec 2002
%
% So for monthly data beginning Jan 2001, the annual "month years" calendar
% "begin" 1 year + X months later, where X is the first "month year".
% Alternatively, if posted to the

% I think annual sums have to go into the end month.

%%
% the old annual:
% PER.annual.PER = mean(P(:)-E(:)-R(:));
% PER.annual.ab = olsfit(year(T),mean(P-E-R,1));

% this should be about 1 mm/day:
% mean(MA.P.*10./365.25)
%
% this should be about 1 cm/yr:
% mean(dSdtA(:,1),'omitnan')
%
% this should be 1.04 cm/yr:
% mean(dSdtA(8:end-1,1),'omitnan')

% % this shows the difference when including the last year or not
% trendplot(year(T), dSdtA(:,1), 'leg', 'all years');
% trendplot(year(T(1:end-1)), dSdtA(1:end-1,1), 'leg', 'no last year', 'use', gca)
%
% trendplot(year(T(8:end)), dSdtA((8:end),1), 'leg', 'all years');
% trendplot(year(T(8:end-1)), dSdtA(8:end-1,1), 'leg', 'no last year', 'use', gca)

% maxfig
% for n = 1:12
%    dSdt = tocolumn(P(n,:)-E(n,:)-R(n,:));
%    trendplot(MerraA.Time,dSdt,'leg',months{n},'use',gca)
%    pause; clf
% end
%
% maxfig
% for n = 1:11
%    dSdt = tocolumn(mean(P(n:n+1,:))-mean(E(n:n+1,:))-mean(R(n:n+1,:)));
%    trendplot(MerraA.Time,dSdt,'leg',months{n},'use',gca)
%    pause; clf
% end
%
%
% PASO = mean(P(8:10,:));
% EASO = mean(E(8:10,:));
% RASO = mean(R(8:10,:));
% SASO = PASO-EASO-RASO;
%
% SD = tocolumn(P(12,:)-E(12,:)-R(12,:));
% SJ = tocolumn(P(1,:)-E(1,:)-R(1,:));
%
%
% maxfig
% trendplot(MerraA.Time,MerraA.S,'leg','dS/dt','use',gca)
% trendplot(MerraA.Time,tocolumn(mean(P)-mean(E)-mean(R)),'leg','dS/dt','use',gca)
% trendplot(MerraA.Time,tocolumn(P(8,:)-E(8,:)-R(8,:)),'leg','dS/dt(A)','use',gca)
% trendplot(MerraA.Time,tocolumn(P(9,:)-E(9,:)-R(9,:)),'leg','dS/dt(S)','use',gca)
% trendplot(MerraA.Time,tocolumn(P(10,:)-E(10,:)-R(10,:)),'leg','dS/dt(O)','use',gca)
% trendplot(MerraA.Time,tocolumn(P(12,:)-E(12,:)-R(12,:)),'leg','dS/dt(D)','use',gca)
% trendplot(MerraA.Time,tocolumn(P(1,:)-E(1,:)-R(1,:)),'leg','dS/dt(J)','use',gca)
% trendplot(MerraA.Time,SASO(:),'leg','dS/dt (ASO)','use',gca)
