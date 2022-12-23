function PER = computeWaterBalance(Data,varargin)
%computeWaterBalance compute water balance dS/dt = P-E-R and trends in each.
% 
%  PER = computeWaterBalance(Data) returns struct PER containing timetables of
%  annual, monthly, and seasonal water balance components from the monthly
%  components in Data.
% 
%  PER = computeWaterBalance(Data,'snowcorrect',true) optionally applies a snow
%  bias correction to remove the influence of above-ground snowpack storage on
%  computed dS/dt trends. There must be a column in Data named 'SW'.
% 
%  PER = computeWaterBalance(Data,'wateryear',true) optionally specifies that
%  the data in Data are on a water year calendar. Assumes the first month is
%  10/1 of the first year in the data record, and 9/1 is the last month.
% 
%  Inputs
% 
%     Data : timetable of water balance components in units cm/yr posted monthly
% 
%  Outputs
% 
%     PER.annual.PER : annual P-E-R i.e. for each year, sum P,E, and R over 12
%     months, with 12-month periods beginning on each of the 12 calendar months,
%     then compute P-E-R for each year 
% 
%     PER.annual.ab : the linear regression intercept (a) and slope (b) of the
%     annual P-E-R values from the step above against time in years  
% 
%     PER.monthly.PER : as above, P-E-R for each month (not annual sums centered
%     on each month, the actual monthly P-E-R) 
% 
%     PER.monthly.ab : the linear regression as above on the monthly P-E-R
% 
%     PER.seasonal ... analogous with monthly but for three-month averages
% 
% 
% Matt Cooper, 20-Feb-2022, mgcooper@github.com
% 
% See also annualdMdt graceSnowCorrect merraWaterBalance

%-------------------------------------------------------------------------------
p=magicParser;
p.FunctionName='computeWaterBalance';
p.PartialMatching=true;
p.addRequired('Data',@(x)istimetable(x));
p.addParameter('snowcorrect',false,@(x)islogical(x));
p.addParameter('wateryear',false,@(x)islogical(x));
p.parseMagically('caller');
%-------------------------------------------------------------------------------

% the annual PER values are somewhat confusing because I compute them using
% each month as a starting month. think of these like water years starting
% on each month, so for example, water year 2000 goes from oct1 1999 to
% sep30 2000, so most of the wy is in year 2000, but the same protocol for
% a february 'water year' means the wy starts on feb 1 1999 and goes to jan
% 31 2000 so most of the water year is in 1999
   
% define functions to compute annual sums and seasonal averages
% Fsum     =  @(x) sum(x, 'includenan');
Favg     =  @(x) mean(x, 'includenan');
Favg1    =  @(x,y,z,idx)   mean( x(:,idx)-y(:,idx)-z(:,idx),2           );
Favg2    =  @(x,y,z,s,idx) mean( x(:,idx)-y(:,idx)-z(:,idx)-s(:,idx),2  );

% make an annual calendar
nmonths  =  height(Data);
nyears   =  nmonths/12;
T        =  tocol(Data.Time(1):calyears(1):Data.Time(end));

% make a cell array of months
months   =  cellstr(datestr(Data.Time(1:12),'mmm'));

if wateryear == true
   seasons  = {'ON','OND','NDJ','DJF','JFM','FMA','MAM','AMJ','MJJ','JJA','JAS','AS'};   
   T        = T+calmonths(3); % shift forward to Jan 1 of the water year
else
   seasons  = {'JF','JFM','FMA','MAM','AMJ','MJJ','JJA','JAS','ASO','SON','OND','ND'};
end

% P-E-R for each month
P        =  transpose(reshape(Data.P,12,nyears));
E        =  transpose(reshape(Data.E,12,nyears));
R        =  transpose(reshape(Data.R,12,nyears));

if snowcorrect == true
   if sum(contains(Data.Properties.VariableNames,'SW')) == 0
      error('no SW variable in provided table')
   else
      SW =  reshape(Data.SW,12,nyears);
   end
end

% init the monthly, seasonal, and annual dS/dt arrays
dSdtS    =  nan(nyears,12);
dSdtA    =  nan(nyears,12);

% init arrays to store trends computed on an annual basis for each month,
% each 3-month season, and each 12-month period beginning on each month
abSM     =  nan(2,12);
abSS     =  nan(2,12);
abSA     =  nan(2,12);

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 1. annual timeseries of monthly dSdt for each month
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if snowcorrect == true
   dSdtM = P-E-R-SW;
else
   dSdtM = P-E-R;
end

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 2. annual timeseries of annual dSdt using each month as a starting month
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% the 12-month sum for the last year can only be computed for 12-month
% periods beginning on the first month, so we can either omit the last year
% or include it then mask the 2:12 values before computing trends.

for n = 1:12
   % get the indices to sum over
   i1    = n;
   i2    = nmonths;        % use this to include all years
   % i2  = nmonths-(13-n); % use this to omit the last year
   
   % annual timeseries of 12-month sums beginning on each month
   MA    = retime(Data(i1:i2,:),'regular',Favg,'TimeStep',calyears(1));
   
   % annual timeseries of annual (12-month sum) dSdt for each month
   if snowcorrect == true
      dSdtA(:,n)  = tocol(MA.P-MA.E-MA.R-MA.SW);
   else
      dSdtA(:,n)  = tocol(MA.P-MA.E-MA.R);
   end
   
   % to check the effect of snow correction on trends:
   % macfig; trendplot(year(T),dSdt,'leg','dSdt','use',gca);
   % trendplot(year(T),tocol(SW(n,:)),'leg','SW','use',gca)
   % trendplot(year(T),dSdt-tocol(SW(n,:)),'leg','dSdt-SW','use',gca)

   % for reference, this accomplishes the same thing as the retime step:
   % PA    = sum(reshape(Merra.P(i1:i2),12,nyears-1));
   % EA    = sum(reshape(Merra.E(i1:i2),12,nyears-1));
   % RA    = sum(reshape(Merra.R(i1:i2),12,nyears-1));
   % SWA   = sum(reshape(Merra.SW(i1:i2),12,nyears-1));
   
end

% mask the last values which are partial sums for all but the first month
dSdtA(end,2:12)   = nan;

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 3. annual timeseries of seasonal dSdt
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

for n = 1:12
   
   % get the indices to average over
   if n==1
      idx = n:n+1;
   elseif n==12
      idx = n-1:n;
   else
      idx = n-1:n+1;   
   end
   
   % apply the snow correction or not and compute P-E-R
   if snowcorrect == true
      dSdtS(:,n) = Favg2(P,E,R,SW,idx);
   else
      dSdtS(:,n) = Favg1(P,E,R,idx);
   end
   
   
end

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 4. compute linear trends 
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

for n = 1:12
   
   abSM(:,n)   = olsfit(year(T),dSdtM(:,n));
   abSS(:,n)   = olsfit(year(T),dSdtS(:,n));
   abSA(:,n)   = olsfit(year(T),dSdtA(:,n));
   
   % use this to omit the last year
   % abSA(:,n) = olsfit(year(T(1:end-1)),dSdtA(:,n));
end


% save the period-average PER, and the calendar-year trend
PER.avg           = nanmean(Data.S);
PER.annual.PER    = array2timetable(dSdtA,'VariableNames',months,'RowTimes',T);
PER.monthly.PER   = array2timetable(dSdtM,'VariableNames',months,'RowTimes',T);
PER.seasonal.PER  = array2timetable(dSdtS,'VariableNames',seasons,'RowTimes',T);
PER.annual.ab     = array2table(abSA,'VariableNames',months);
PER.monthly.ab    = array2table(abSM,'VariableNames',months);
PER.seasonal.ab   = array2table(abSS,'VariableNames',seasons);

PER.annual.avg    = array2table(nanmean(dSdtA,1),'VariableNames',months);
PER.monthly.avg   = array2table(nanmean(dSdtM,1),'VariableNames',months);
PER.seasonal.avg  = array2table(nanmean(dSdtS,1),'VariableNames',seasons);

% PER.annual.avg    = array2timetable(nanmean(dSdtA,2),'VariableNames',{'PER'},'RowTimes',T);

PER.readme = ['the PER.annual.PER arrays are 12-month sums where each ' newline ...
               'column defines a 12-month year beginning on the ' newline ...
               'column month. For example, to use traditional water ' newline ...
               'years, choose the Oct column, and shift the time ' newline ...
               'calendar one year forward to get the water year.'];

% % the old annual:
% PER.annual.PER    = mean(P(:)-E(:)-R(:));
% PER.annual.ab     = olsfit(year(T),mean(P-E-R,1));

% this should be about 1 mm/day: mean(MA.P.*10./365.25)
% this should be about 1 cm/yr: mean(dSdtA(:,1),'omitnan')
% this should be 1.04 cm/yr: mean(dSdtA(8:end-1,1),'omitnan')

% % this shows the difference when including the last year or not
% trendplot(year(T),dSdtA(:,1),'leg','all years');
% trendplot(year(T(1:end-1)),dSdtA(1:end-1,1),'leg','no last year','use',gca)
% 
% trendplot(year(T(8:end)),dSdtA((8:end),1),'leg','all years');
% trendplot(year(T(8:end-1)),dSdtA(8:end-1,1),'leg','no last year','use',gca)

% macfig;
% for n = 1:12
%    dSdt = tocol(P(n,:)-E(n,:)-R(n,:));
%    trendplot(MerraA.Time,dSdt,'leg',months{n},'use',gca)
%    pause; clf
% end
% 
% macfig;
% for n = 1:11
%    dSdt = tocol(mean(P(n:n+1,:))-mean(E(n:n+1,:))-mean(R(n:n+1,:)));
%    trendplot(MerraA.Time,dSdt,'leg',months{n},'use',gca)
%    pause; clf
% end
%    
% 
% PASO     =  mean(P(8:10,:));
% EASO     =  mean(E(8:10,:));
% RASO     =  mean(R(8:10,:));
% SASO     =  PASO-EASO-RASO;
% 
% SD       =  tocol(P(12,:)-E(12,:)-R(12,:));
% SJ       =  tocol(P(1,:)-E(1,:)-R(1,:));
% 
% 
% macfig;
% trendplot(MerraA.Time,MerraA.S,'leg','dS/dt','use',gca)
% trendplot(MerraA.Time,tocol(mean(P)-mean(E)-mean(R)),'leg','dS/dt','use',gca)
% trendplot(MerraA.Time,tocol(P(8,:)-E(8,:)-R(8,:)),'leg','dS/dt (A)','use',gca)
% trendplot(MerraA.Time,tocol(P(9,:)-E(9,:)-R(9,:)),'leg','dS/dt (S)','use',gca)
% trendplot(MerraA.Time,tocol(P(10,:)-E(10,:)-R(10,:)),'leg','dS/dt (O)','use',gca)
% trendplot(MerraA.Time,tocol(P(12,:)-E(12,:)-R(12,:)),'leg','dS/dt (D)','use',gca)
% trendplot(MerraA.Time,tocol(P(1,:)-E(1,:)-R(1,:)),'leg','dS/dt (J)','use',gca)
% trendplot(MerraA.Time,SASO(:),'leg','dS/dt (ASO)','use',gca)
