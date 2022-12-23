function Gc = graceSnowCorrect(G,SW,varargin)

%------------------------------------------------------------------------------
p = magicParser;
p.FunctionName = 'graceSnowCorrect';
p.PartialMatching = true;

% p.addRequired('T',@(x)isdatetime(x));
p.addRequired('G',@(x)istimetable(x));
p.addRequired('SW',@(x)istimetable(x));
p.addParameter('bimonthly',false,@(x)islogical(x));
p.addParameter('makeplot',false,@(x)islogical(x));

p.parseMagically('caller');
%------------------------------------------------------------------------------
   
% this corrects on a month-by-month basis meaning the snow anomalies are
% computed on a month-by-month basis and subtracted from the grace
% anomalies, e.g. all january's are collected, one for each year, and their
% linear trend subtracted to compute anomalies, then those anomalies are
% subtracted from the corresponding grace anomalies


if bimonthly == true
   
   % the data have to be organized as timetables with each column a month
   % from Jan to Dec, and each row a year. 

   if size(G,2) ~= 12
      error('for option bimonthly, data size should be numyears x 12')
   end
   
   % find the Merra SWE data that overlaps the Grace data
   tmin     =  max(G.Time(1),SW.Time(1));
   tmax     =  min(G.Time(end),SW.Time(end)); %  + calmonths(11);
   idxS     =  isbetween(SW.Time,tmin,tmax);
   idxG     =  isbetween(G.Time,tmin,tmax);
   SW       =  SW(idxS,:);
   G        =  G(idxG,:);
   
   imonth   =  month(G.Time(1));
   iyear    =  year(G.Time(1));
   nyears   =  height(G);
   nmonths  =  nyears*12;
   
   if month(G.Time(1)) == 1
      t1    =  datetime(iyear,imonth,1);
      t2    =  datetime(iyear+nyears-1,12,1);
      T     =  tocol(t1:calmonths(1):t2);
   elseif month(G.Time(1)) == 10 % assume water years
      T     =  tocol(G.Time(1):calmonths(1):G.Time(end));
   end
   
   % reshape carefully. this is done so G and SW are compatible with G and
   % SW in the else block, so identical processing works thereafter 
   G        =  reshape(transpose(table2array(G)),nmonths,1);
   SW       =  reshape(transpose(table2array(SW)),nmonths,1);

else

   if sum(contains(SW.Properties.VariableNames,'SW')) == 0
      error('no SW variable in provided table')
   end

   % I did it both ways and there's ~no dif, so prob just use this method: 
   tempM    =  synchronize(G,SW,G.Time);
   T        =  tempM.Time;
   G        =  tempM.G;
   SW       =  tempM.SW;
end

if makeplot == true % keep a copy of the original data
   OG    =  G;
end
   
% get indices that are nan in the original data
inan     =  isnan(G);

% this eliminates the need to reshape so incomplete annual calendars work
% eg if an extra january is passed in, all jan's get corrected
for n = 1:12
   idx = find(month(T) == n);
   G(idx) = G(idx) - anomaly(SW(idx));
end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% uncomment this entire block to revert to prior method preserving
% commented code and uncommented code.
% % compute anomalies on a month-by-month basis
% G        =  transpose(reshape(G,12,numel(G)/12));
% SW       =  transpose(reshape(SW,12,numel(SW)/12));
% % G        =  anomaly(G) - anomaly(SW);
% G        =  G - anomaly(SW);
% G        =  reshape(transpose(G),size(G,1)*size(G,2),1);
% 
% % compute anomalies relative to the entire period
% % G        =  (G-nanmean(G))-(SW-nanmean(SW));
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

Gc       =  timetable(G,'RowTimes',T);
Gc       =  setnan(Gc,inan);
% I confirmed there is no need to anomaly again
% do I want to return it back as a monthly table?

if makeplot == true
   % compare the og grace to snow-corrected grace
   trendplot(T,OG,'leg','no correction'); 
   trendplot(T,Gc.G,'use',gca,'leg','with correction');
end
   
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