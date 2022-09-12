function [dMdt,Mt] = annualdMdt(Time,M)
%ANNUAL_DMDT computes annual differences of mass, e.g. grace water storage,
%climate model snow mass, etc. Input data are assumed to be monthly
%averages. If the number of months is an even divisor of 12, then the first
%and last differences are annual differences of the respective monthly
%values. If the number of months is 1 longer than an even divisor of 12,
%then for 1 extra month, the last month is a bi-monthly average
   
% based on the method to get Grace dS/dt from Crow et al. 2017 using: 
% dS/dt(i) = (Sdec(i)+Sjan(i+1))/2 - (Sdec(i-1)+Sjan(i))/2

   nmonths     =  length(M);
   
   % if one extra month is provided, the last month can be computed as
   % (M(i) + M(i+1)), consistent with other months. If not, we can either
   % use M(i) for the last month or censor it. I add an extra nan below if
   % the data does not already have an extra month, which means the last
   % bi-monthly value would be nan, except I also have an if statement that
   % instead uses the last monthly value. Can change later if desired.
   
   if mod(nmonths-1,12) == 0
      nmonths   = nmonths - 1;
   elseif mod(nmonths,12) ~= 0
      error('input data must be posted monthly, or option to provide +1 month');
   else
      M = [M;nan];
   end
   
   dMdt        =  nan(nmonths,1);
   Mt          =  nan(nmonths,1);
   
   % average bi-monthly mass from start to finish
   for n = 1:nmonths
         
      Mt(n) =  (M(n)+M(n+1))/2;
      
      % this is the case where one extra month was not provided. it also
      % works if the first two or more months are nan.
      if isnan(M(n+1))
         Mt(n) =  (M(n));
      end
      
   end
   
   for n = 1:nmonths-12
      i        =  n;
      ii       =  n+12;
      
      dMdt(ii) = Mt(ii)-Mt(i);
      
      % dMdt(ii) = (M(ii)+M(ii+1))/2 - (M(i)+M(i+1))/2;
   end
   
   % to build the new yearly time vector, if water year or anything other
   % than Jan-Dec, then datetime(years,1,1) won't work b/c we will have one
   % extra year for the last partial year, so this should work:
   numyears    =  nmonths/12;
   newtimes    =  tocol(Time(1):calyears(1):Time(1)+calyears(numyears-1));
   mvars       =  cellstr(datestr(Time(1:12),'mmm'));

   
   dMdt        =  transpose(reshape(dMdt,12,numyears));
   dMdt        =  array2timetable(dMdt,'RowTimes',newtimes);
   
   dMdt.Properties.VariableNames = mvars;
                                 
   Mt          =  transpose(reshape(Mt,12,numyears));
   Mt          =  array2timetable(Mt,'RowTimes',newtimes);
   
   Mt.Properties.VariableNames = mvars;
                                 
%    dGdt        =  array2timetable(dGdt,'RowTimes',datetime(years,1,1), ...
%                   'VariableNames',{ 'Jan','Feb','Mar','Apr','May','Jun',...
%                                     'Jul','Aug','Sep','Oct','Nov','Dec'});
   
   % this would return a timetable as a single monthly column
   %dGdt        =  timetable(dGdt,'RowTimes',G.Time);
    
%    % this is the orignal method that uses the Jan + Dec only
%    for i = 2:numel(years)-1
%       
%       iyear    =  years(i);
%       ideci    =  find(Time == datetime(iyear,12,1));
%       ijanip1  =  find(Time == datetime(iyear+1,1,1));
%       idecim1  =  find(Time == datetime(iyear-1,12,1));
%       ijani    =  find(Time == datetime(iyear,1,1));
% 
%       dGdt(i)  =  (S(ideci)+S(ijanip1))/2 - (S(idecim1)+S(ijani))/2;
%       
%    end
   
%    dGdt     =  timetable(dGdt,'RowTimes',datetime(years,1,1));


% % the ET calculation from Rodel
% % this is not right but a start
% % if we have 60 days of daily et, we compute 31 30-day running averages,
% % i.e., day 1:30, 2:31, 3:32, 4:33, ... 31:60, then average those to get 
% N=30;
% for n=1:N
%    for d=1+n:2+n
%       Sbar(n) = sum(P(1+n)-E(1+n))
%    end
% end



