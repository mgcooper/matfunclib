function Mc = merraSnowCorrection(M,SW,varargin)
%MERRASNOWCORRECTION bias-correct merra2 mass fields for snow water equivalent
%anomalies.
%
%  Mc = merraSnowCorrection(M,SW) corrects M using anomalies in SW.
%
%  Mc = merraSnowCorrection(M,SW,'bimonthly',true) corrects M using anomalies
%  in SW using bimonthly averages.
%
% Matt Cooper, 20-Feb-2022, mgcooper@github.com
% 
% See also merraWaterBalance

%------------------------------------------------------------------------------
p = magicParser;
p.FunctionName=mfilename;
p.PartialMatching=true;
% p.addRequired('T',@(x)isdatetime(x));
p.addRequired('M',@(x)istimetable(x));
p.addRequired('SW',@(x)istimetable(x));
p.addParameter('bimonthly',false,@(x)islogical(x));
p.parseMagically('caller');
%------------------------------------------------------------------------------

% right now, this subtracts the long-term snow trend from all months, but I
% think we want to correct on a month-by-month basis


if bimonthly == true

   % the data have to be organized as timetables with each column a month
   % from Jan to Dec, and each row a year

   if size(M,2) ~= 12
      error('for option bimonthly, data size should be numyears x 12')
   end

   % find the Merra SWE data that overlaps the Grace data
   tmin     =  max(M.Time(1),SW.Time(1));
   tmax     =  min(M.Time(end),SW.Time(end));
   idxS     =  isbetween(SW.Time,tmin,tmax);
   idxG     =  isbetween(M.Time,tmin,tmax);
   SW       =  SW(idxS,:);
   M        =  M(idxG,:);

   imonth   =  month(M.Time(1));
   iyear    =  year(M.Time(1));
   nyears   =  height(M);
   nmonths  =  nyears*12;

   if month(M.Time(1)) == 1
      t1    =  datetime(iyear,imonth,1);
      t2    =  datetime(iyear+nyears-1,12,1);
      T     =  tocolumn(t1:calmonths(1):t2);
   elseif month(M.Time(1)) == 10 % assume water years
      T     =  tocolumn(M.Time(1):calmonths(1):M.Time(end));
   end

   % need to reshape carefully
   M        =  reshape(transpose(table2array(M)),nmonths,1);
   SW       =  reshape(transpose(table2array(SW)),nmonths,1);

   % compare the og grace to snow-corrected grace
   % trendplot(T,G); trendplot(T,Gc.Gc,'use',gca)

   % compare the bi-monthly average values to the monthly values
   % figure; plot(G); hold on; plot(GraceM.G(2:218))
   % figure; plot(SW); hold on; plot(MerraM.SW(242:457))

   % to do this, comment out the two lines above that replace G with Gc
   % trendplot(GraceM.Time,GraceM.G);
   % trendplot(GraceM.Time,GraceM.Gc,'use',gca)

else

   if sum(contains(SW.Properties.VariableNames,'SW')) == 0
      error('no SW variable in provided table')
   end

   % I did it both ways and there's ~no dif, so prob just use this method:
   tempM    =  synchronize(M,SW,M.Time);
   T        =  tempM.Time;
   P        =  tempM.P;
   E        =  tempM.E;
   R        =  tempM.R;
   SW       =  tempM.SW;
end

% get indices that are nan in the original data
inan     =  isnan(M);

% compute anomalies on a month-by-month basis
M        =  transpose(reshape(M,12,numel(M)/12));
SW       =  transpose(reshape(SW,12,numel(SW)/12));
% G        =  anomaly(G) - anomaly(SW);
M        =  M - anomaly(SW);
M        =  reshape(transpose(M),size(M,1)*size(M,2),1);

% compute anomalies relative to the entire period
% G        =  (G-nanmean(G))-(SW-nanmean(SW));

Mc       =  timetable(M,'RowTimes',T);
Mc       =  setnan(Mc,inan);
% I confirmed there is no need to anomaly again
% do I want to return it back as a monthly table?



% % TEST - seems like the trend in each month should be removed ...
% G        =  transpose(reshape(G,12,numel(G)/12));
% SW       =  transpose(reshape(SW,12,numel(SW)/12));
% % Gc       =  anomaly(G) - anomaly(SW);
% Gc       =  G - anomaly(SW);
% Tannual  =  datetime(unique(year(T)),1,1);
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
% si    = 13;
% ei    = 24;
% figure;
% plot(GraceM.Time(si:ei),SW(si:ei)); hold on;
% plot(GraceM.Time(si:ei),G(si:ei));
% plot(GraceM.Time(si:ei),Gc(si:ei)); legend('SWE','S','S-SWE');