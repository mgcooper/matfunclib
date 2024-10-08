function PER = waterBalanceAnalysis(MonthlyData, varargin)
   %waterBalanceAnalysis Compute water balance dS/dt=P-E-R and trends in each.
   %
   %    PER = waterBalanceAnalysis(MonthlyData)
   %    PER = waterBalanceAnalysis(MonthlyData, 'RemoveSnowMass', true)
   %    PER = waterBalanceAnalysis(MonthlyData, 'PlotSnowCorrection', true)
   %
   % Description
   %
   %    PER = WATERBALANCEANALYSIS(MONTHLYDATA) returns struct PER containing
   %    timetables of annual, monthly, and seasonal water balance estimates
   %    from the data in MONTHLYDATA, a timetable which contains variables P, E,
   %    and R, representing monthly averages of precipitation, evaporation, and
   %    runoff fluxes, respectively, all with units [length]/yr. Note that the
   %    units have "year" in the denominator - the data are monthly fluxes
   %    posted monthly, but should be in units of [length]/yr so that averaging
   %    over a 12-month period returns the total annual flux in units
   %    [length]/year, whereas summing over a 12 month period would be incorrect
   %    (it would require dividing by 12 or accounting for the number of days
   %    per month and then dividing by days per year).
   %
   %    TODO: Make the data monthly fluxes in units [length]/month. I think the
   %    [length]/year units were used b/c months have different numbers of days.
   %    But it may be more confusing this way.
   %
   %    PER = waterBalanceAnalysis(MonthlyData,'RemoveSnowMass',true) optionally
   %    applies a snow bias correction to remove the influence of above-ground
   %    snowpack storage on computed dS/dt trends. There must be a column in
   %    MonthlyData named 'dSWEdt' which represents the rate of change of
   %    aboveground snow water equivalent (SWE), in the same units as the other
   %    water balance components (nominally cm/yr, or any consistent units).
   %
   %    PER = waterBalanceAnalysis(MonthlyData,'PlotSnowCorrection',true)
   %
   %  Inputs
   %
   %    MONTHLYDATA timetable of water balance components [cm/yr] posted
   %    monthly. MONTHLYDATA must contain the variables P, E, and R.
   %
   %    REMOVESNOWMASS (optional) logical name-value pair indicating if snow
   %    water storage is removed from the water balance. If REMOVESNOWMASS is
   %    true, MONTHLYDATA must contain a variable named dSWEdt (or dSWdt) which
   %    represents the rate of change of stored snow in units of cm water
   %    equivalent per year. Use this option to analyze the soil water balance,
   %    by removing the snow mass component of the total water balance. This
   %    could be done by using P,E,R, and SWE from a climate model.
   %
   %    SWE (optional) numeric array or timetable of monthly SWE values. These
   %    are used to compute dSWE/dt on a MONTHLY basis, to adjust monthly
   %    dS/dt=P-E-R calculations.
   %
   %    dSWEdt (optional) numeric array or timetable of monthly dSWE/dt values,
   %    in units [length]/yr just like P, E, and R. These are used to remove
   %    changes in snow storage from the dS/dt=P-E-R calculations, to isolate
   %    below-ground or otherwise non-snow-related storage changes.
   %
   %  Outputs
   %
   %     PER.AVG - [1 1] The average PER over all timesteps (all months), i.e.,
   %     not the annual average PER (Obtain the annual average PER from the
   %     PER.annual.avg.<MMM> table, using a month of your choice to define a
   %     water-year. For instance, use PER.annual.avg.Jan to obtain the
   %     traditional calendar year annual average PER).
   %
   %     PER.ANNUAL.AVG - [1 12] Annual average P-E-R averaged over annual
   %     periods (years) defined as beginning on each month. The traditional
   %     "annual average" would therefore be the Jan value: PER.annual.avg.Jan.
   %
   %     PER.ANNUAL.PER - [years 12] Annual P-E-R i.e. for each year, sum P,E,
   %     and R over 12 months, with 12-month periods beginning on each of the 12
   %     calendar months, then compute P-E-R for each year [cm a-1].
   %
   %     Note that these are equivalent:
   %       [PER.annual.avg.Jan mean(PER.annual.PER.Jan) mean(PER.monthly.avg{1, :})]
   %
   %     The first is a scalar value representing the annual average P-E-R for
   %     annual periods beginning January, the second is an annual timeseries
   %     representing annual values of P-E-R for annual periods beginning
   %     January (the average is over all rows in the Jan column of the
   %     PER.annual.PER table), the third is a monthly timeseries representing
   %     the monthly average P-E-R over annual timeseries of monthly P-E-R.
   %
   %     PER.ANNUAL.AB - [2 12] the linear regression intercept (a) and slope
   %     (b) of the annual P-E-R values from the step above against time in
   %     years, i.e., d(P-E-R)/dt [cm a-2].
   %
   %     PER.MONTHLY.PER - [years 12] as above, P-E-R for each month (not annual
   %     sums centered on each month, the actual monthly P-E-R)
   %
   %     PER.MONTHLY.AB - [2 12] the linear regression as above on the monthly
   %     P-E-R values. Row 1 is the intercept (a), row 2 is the slope (b). Units
   %     are [cm a-2]. NOTE: This would be similar to how
   %
   %     PER.seasonal ... analogous with monthly but for three-month averages
   %
   %
   % Matt Cooper, 20-Feb-2022, mgcooper@github.com
   %
   % See also annualdMdt grace.snowCorrection merra.monthlyWaterBalance

   % Parse inputs.
   [MonthlyData, P, E, R, dSWEdt, AnnualTime, ...
      plotSnowCorrection] = parseinputs(MonthlyData, mfilename, varargin{:});

   % Define functions to compute annual and seasonal water balance.
   % Note that dswedt=0 if RemoveSnowMass==false.
   F_annualsum = @(x) sum(x, 'includenan');
   F_annualavg = @(x) mean(x, 'includenan');
   F_seasonavg = @(p,e,r,dswedt,t) mean( p(:,t)-e(:,t)-r(:,t)-dswedt(:,t), 2);

   % Make cell arrays of month names and season names.
   [months, seasons] = makeSeasonNames(MonthlyData, AnnualTime, false);

   % Compute the total number of months and years to initialize output.
   nmonths = numel(P);
   nyears = nmonths / 12;

   % Init the monthly, seasonal, and annual dS/dt arrays.
   [dSdtS, dSdtA] = deal(nan(nyears, 12));

   %%% 1. Compute dSdtM: annual timeseries of MONTHLY dSdt.
   %
   % dSdtM has twelve columns, each an annual timeseries of monthly (not annual)
   % dSdt. Use these to answer questions such as: What is the August water
   % balance each year? What is the average August water balance? Is there a
   % trend in the August water balance?

   dSdtM = P-E-R-dSWEdt; % Note: dSWEdt=0 if RemoveSnowMass==false.

   %%% 2. Compute dSdtA: annual timeseries of ANNUAL dSdt.
   %
   % dSdtA has twelve columns, each an annual timeseries of annual dSdt computed
   % by using each month as the START month for a year. Use these to answer
   % questions such as: What is the annual water balance each year, considering
   % October-September as the definition of a year? Or considering any arbitrary
   % definition of "year" such as April-March or August-July.

   % Create 12-month forward annual-average water balance tables beginning each
   % month. Each timetable has nmonths=nyears*12 rows.
   for imonth = 12:-1:1

      % Create an annual timeseries of 12-month averages beginning this month
      AnnualData = retime(MonthlyData(imonth:nmonths, :), ...
         'regular', F_annualavg, 'TimeStep', calyears(1));

      % Compute annual timeseries of annual (12-month avg) dSdt for this month
      dSdtA(:, imonth) = ...
         AnnualData.P - AnnualData.E - AnnualData.R - AnnualData.dSWEdt;
      % Note: AnnualData.dSWEdt=0 if RemoveSnowMass==false.

      % Check the effect of snow correction on trends
      if plotSnowCorrection
         makeSnowCorrectionPlot(AnnualTime, dSdtA(:, imonth), AnnualData.dSWEdt)
      end
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

   for imonth = 12:-1:1

      % Get the indices to average over.
      if imonth == 1
         idx = imonth:imonth+1;
      elseif imonth == 12
         idx = imonth-1:imonth;
      else
         idx = imonth-1:imonth+1;
      end

      % apply the snow correction or not and compute P-E-R
      dSdtS(:, imonth) = F_seasonavg(P, E, R, dSWEdt, idx);
   end

   % NEW - use TWS directly. Note - may need to use bimonthly averaging if SWE
   % was averaged, then dSliq/dt = dS/dt - dSWE/dt + T is apples to apples
   if isvariable('TWS', MonthlyData)
      TWS = transpose(reshape(MonthlyData.TWS, 12, []));
   else
      TWS = 0 * P;
   end
   if isvariable('SWE', MonthlyData)
      SWE = transpose(reshape(MonthlyData.SWE, 12, []));
   else
      SWE = 0 * P;
   end

   % 4. Compute linear trends in dS/dt computed on an annual basis for each
   % month, each season, and each 12-month annual period beginning each month.
   if size(dSdtM, 1) > 2
      for imonth = 12:-1:1

         abdSdtM(:,imonth) = olsfit(year(AnnualTime), dSdtM(:,imonth));
         abdSdtS(:,imonth) = olsfit(year(AnnualTime), dSdtS(:,imonth));
         abdSdtA(:,imonth) = olsfit(year(AnnualTime), dSdtA(:,imonth));

         % Use this to omit the last year.
         % abdSdtA(:,n) = olsfit(year(T(1:end-1)),dSdtA(:,n));

         % TWS
         abTWS(:,imonth) = olsfit(year(AnnualTime), TWS(:,imonth));
         abSWE(:,imonth) = olsfit(year(AnnualTime), SWE(:,imonth));
      end
   end

   % this should bring the trend closer to mean(dSdtA) if RemoveSnow == true.
   % Temp hack since RemoveSnowMass flag is not in this workspace, but if all
   % dSWE/dt values are zero it means its false
   MonthlyTime = years(MonthlyData.Time - MonthlyData.Time(1));
   if all(dSWEdt(:) == 0)

      % These trends are monthly i.e. 12 trends, each one fit to all values of
      % TWS for the i'th month.
      PER.monthly.dTWSdt = abTWS; % cm / year
      PER.monthly.dSWEdt = abSWE;

      % These are fit to a single timeseries of all months, similar to grace.
      PER.dTWSdt = olsfit(MonthlyTime, reshape(transpose(TWS), [], 1));
      PER.dSWEdt = olsfit(MonthlyTime, reshape(transpose(SWE), [], 1));
   else
      PER.monthly.dTWSdt = abTWS - abSWE;
      PER.monthly.dSWEdt = abSWE;

      PER.dTWSdt = olsfit(MonthlyTime, reshape(transpose(TWS), [], 1)) ...
         - olsfit(MonthlyTime, reshape(transpose(SWE), [], 1));
      PER.dSWEdt = olsfit(MonthlyTime, reshape(transpose(SWE), [], 1));
   end

   % save the period-average PER, and the calendar-year trend
   PER.avg           = mean(MonthlyData.PER, 'omitnan');
   PER.annual.PER    = array2timetable(dSdtA,'VariableNames',months,'RowTimes',AnnualTime);
   PER.monthly.PER   = array2timetable(dSdtM,'VariableNames',months,'RowTimes',AnnualTime);
   PER.seasonal.PER  = array2timetable(dSdtS,'VariableNames',seasons,'RowTimes',AnnualTime);
   PER.annual.ab     = array2table(abdSdtA,'VariableNames',months);
   PER.monthly.ab    = array2table(abdSdtM,'VariableNames',months);
   PER.seasonal.ab   = array2table(abdSdtS,'VariableNames',seasons);

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
function [MonthlyData, P, E, R, dSWEdt, timeAnnual, ...
      PlotSnowCorrection] = parseinputs(MonthlyData, mfilename, varargin)

   parser = inputParser;
   parser.FunctionName = mfilename;
   parser.addRequired('MonthlyData', @istimetable);
   parser.addParameter('RemoveSnowMass', false, @islogicalscalar);
   parser.addParameter('PlotSnowCorrection', false, @islogicalscalar);
   parser.addParameter('dSWEdt', [], @(x) isnumeric(x) || istabular(x))
   parser.parse(MonthlyData, varargin{:});

   RemoveSnow = parser.Results.RemoveSnowMass;
   PlotSnowCorrection = parser.Results.PlotSnowCorrection;

   % dSWE/dt in units cm/yr posted monthly, same as P,E,R.
   dSWEdt = parser.Results.dSWEdt;

   % Ensure there are an even number of years.
   assert(mod(height(MonthlyData), 12) == 0)

   % Ensure the variable names include P, E, R (and possibly dSWdt or dSWEdt).
   [~, found] = parseFieldNames(MonthlyData, {'P', 'E', 'R', 'dSWdt', 'dSWEdt'});

   foundPER = all(ismember({'P', 'E', 'R'}, found));
   foundSWE = any(ismember({'dSWdt', 'dSWEdt'}, found)); % dt=calmonth

   assert(foundPER, 'Provide a table or struct with P, E, R fields.');

   % Create a PER field whether or not one exists
   MonthlyData.PER = MonthlyData.P - MonthlyData.E - MonthlyData.R;

   % Prepare annual monthly timestep P-E-R column vectors.
   P = transpose(reshape(MonthlyData.P, 12, []));
   E = transpose(reshape(MonthlyData.E, 12, []));
   R = transpose(reshape(MonthlyData.R, 12, []));

   % Ensure the variable names include dSWEdt if snow mass correction requested.
   if RemoveSnow
      % Parse the provided dSWEdt variable
      dSWEdt = parse_dSWEdt(MonthlyData, dSWEdt, found, foundSWE, ...
         numel(P), mfilename);
   else
      % Set it to an array of zeros.
      dSWEdt = zeros(size(P));

      % Also set it to zero if it exists in the table.
      if foundSWE
         MonthlyData{:, found(ismember(found, 'dSWdt'))} = 0;
         MonthlyData{:, found(ismember(found, 'dSWEdt'))} = 0;
      else
         MonthlyData.dSWEdt = dSWEdt(:);
      end
   end

   % Set any nan values to zero.
   dSWEdt(isnan(dSWEdt)) = 0.;

   % Ensure the timetable time variable is named Time.
   MonthlyData.Properties.DimensionNames{1} = 'Time';

   % Make an annual calendar.
   timeAnnual = transpose(MonthlyData.Time(1):calyears(1):MonthlyData.Time(end));
end

function dSWEdt = parse_dSWEdt(Data, dSWEdt, found, foundSWE, N, mfilename)
   %PARSE_DSWEDT Parse the dSWEdt input to waterBalanceAnalysis
   %
   % Inputs
   %    Data - the monthly water balance components timetable.
   %    dSWEdt - the name-value argument in waterBalanceAnalysis.
   %
   % Notes
   %    - all data represent monthly fluxes in units cm/yr, posted monthly
   %
   %    - This function is only called if RemoveSnow is true.
   %
   %    - If dSWEdt is empty on input, then it was not provided as a name-value
   %      argument, and must be provided as a column in the monthly Data table.
   %
   %    - If dSWEdt was provided as a table or timetable, it must have only one
   %      variable and match P, E, R in size.
   %
   %    - In any case, dSWEdt needs to be a timeseries of monthly dSWE/dt in
   %      units cm/yr i.e., the change in SWE during the month expressed in
   %      units cm/yr, just like the other water balance components.
   %
   % See also:

   if isempty(dSWEdt)

      % Use the table variable.
      assert(foundSWE, ...
         ['dSWEdt data required if RemoveSnowMass=true. Provide dSWEdt ' ...
         'variable in table or using optional dSWEdt parameter.'])

      % Parse the two options: dSWdt or dSWEdt.
      if ismember('dSWdt', found)
         dSWEdt = Data.dSWdt;

      elseif ismember('dSWEdt', found)
         dSWEdt = Data.dSWEdt;
      end
   end

   % Below here, dSWEdt was either provided as a name-value argument or is a
   % vector obtained from the MonthlyData timetable.

   % If dSWEdt was provided as a table or timetable, it must have only one
   % variable and match P, E, R in size.
   if istabular(dSWEdt)
      dSWEdt = dSWEdt{:, :}(:);
   end

   % Validate the provided dSWEdt (ensure it has the same number of elems as P).
   validateattributes(dSWEdt, ...
      {'numeric'}, {'2d', 'numel', N}, mfilename, 'dSWEdt')

   % Ensure dSWEdt is [months x 1] or [12 x years] (where months = 12*years)
   if isrow(dSWEdt)
      dSWEdt = dSWEdt(:);

   elseif ~iscolumn(dSWEdt)
      assert(size(dSWEdt, 1) == 12 || size(dSWEdt, 2) == 12)

      if size(dSWEdt, 2) == 12
         dSWEdt = transpose(dSWEdt);
      end
   end

   % This should work if dSWEdt is [months x 1] or [months x years]
   dSWEdt = transpose(reshape(dSWEdt, 12, []));
end
%%
function [months, seasons] = makeSeasonNames(MonthlyData, AnnualTime, aswateryears)

   % Make cell arrays of month names.
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
end

%%
function makeSnowCorrectionPlot(T, dSdt, dSWEdt)
   trendplot(year(T), dSdt, 'leg', 'dSdt', 'use', gca);
   trendplot(year(T), dSWEdt, 'leg', 'dSWEdt', 'use', gca)
   trendplot(year(T), dSdt-dSWEdt, 'leg', 'dSdt-dSWEdt', 'use', gca)
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
