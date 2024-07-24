function [dMdt, Mt] = annualdMdt(Time, M, kwargs)
   %ANNUALDMDT Compute annual mass fluxes from monthly (water) storage.
   %
   %  [DMDT, MT] = ANNUALDMDT(TIME, M)
   %
   % Description:
   %
   %  [DMDT, MT] = ANNUALDMDT(TIME, M) Computes annual differences of mass, e.g.
   %  grace water storage, climate model snow mass, etc. Input data are assumed
   %  to be monthly averages; bi-monthly averaging is performed to obtain
   %  monthly values posted at the start of each month. Differences are in a
   %  "forward" sense meaning the difference for year_i is:
   %
   %     dMdt(MMM)_year_i = M(MMM)_year_(i+1) - M(MMM)_year_(i).
   %
   %  Here, M is mass and MMM indexes months. Differences are posted monthly
   %  such that the annual calendar-year difference for year i would typically
   %  be obtained from the January values:
   %
   %     dMdt_calyear_i = M(Jan)_year_(i+1) - M(Jan)_year_(i).
   %
   %  Here, dMdt_calyear_i represents the change in mass during year i. However,
   %  the annual water-year difference for year i requires shifting the index:
   %
   %     dMdt_wateryear_i = M(Oct)_year_(i) - M(Oct)_year_(i-1).
   %
   %  Here, dMdt_wateryear_i represents the change in mass during water year i.
   %  Although this discrepancy is potentially confusing, the alternative is to
   %  define calendar year differences as Dec_i - Dec_i-1.
   %
   %  HERE THE BIMONTHLY AVERAGES "GO INTO" THE SECOND MONTH - NOTE THIS
   %  IS NOT WHAT I IMPLEMENTED IN THE ALGORITHM - That's why I was confused, I
   %  put the (dec_i + jan_i+1)/2 into dec_i (the FIRST month)
   %
   %  The bi-monthly averaging is based on a method from Crow et al. 2017 to
   %  estimate annual differences of Grace dS/dt:
   %
   %     dS/dt(i) = (Sbar_dec(i)+Sbar_jan(i+1))/2 - (Sbar_dec(i-1)+Sbar_jan(i))/2
   %     dS/dt(i) = S_jan(i+1) - S_jan(i)
   %
   %  In contrast, for water-year differences:
   %
   %     dS/dt(i) = (Sbar_sep(i)+Sbar_oct(i))/2 - (Sbar_sep(i-1)+Sbar_oct(i-1))/2
   %     dS/dt(i) = S_oct(i) - S_oct(i-1)
   %
   %  ALTERNATIVE WHERE THE BIMONTHLY AVERAGES "GO INTO" THE FIRST MONTH - NOTE:
   %  THIS IS WHAT I IMPLEMENTED IN THE ACTUAL ALGORITHM.
   %
   %  The bi-monthly averaging is based on a method from Crow et al. 2017 to
   %  estimate annual differences of Grace dS/dt:
   %
   %     dS/dt(i) = (Sbar_dec(i)+Sbar_jan(i+1))/2 - (Sbar_dec(i-1)+Sbar_jan(i))/2
   %     dS/dt(i) = S_dec(i) - S_dec(i-1)
   %
   %  In contrast, for water-year differences:
   %
   %     dS/dt(i) = (Sbar_sep(i)+Sbar_oct(i))/2 - (Sbar_sep(i-1)+Sbar_oct(i-1))/2
   %     dS/dt(i) = S_sep(i) - S_sep(i-1)
   %
   %  Although for the calendar-year:
   %     dS/dt(i) = S_jan(i+1) - S_jan(i)
   %  is "more correct", it leads to the discrepancy where water year
   %     dS/dt(i) = S_oct(i) - S_oct(i-1)
   %
   %  Bi-monthly averaging requires an extra month of data on either side of the
   %  period of record, i.e., to compute the value for January of year i, where
   %  i=1, the value from December of year i-1 is required. Strictly, to compute
   %  bi-monthly averages, an extra month is not required on the other side of
   %  the data. However to compute annual differences, which is the purpose of
   %  this function, it becomes necessary to have an extra month to compute the
   %  annual difference for the final month of the final year. For example, if
   %  the period of record is 2000-2020, this function is designed to return
   %  annual differences for each month, Jan-Dec, and each year, 2001-2020.
   %
   %  To compute the annual difference for year 2000:
   %     dS/dt(2000) = (Sdec(2000)+Sjan(2001))/2 - (Sdec(1999)+Sjan(2000))/2
   %
   %  And to compute the annual difference for year 2020:
   %     dS/dt(2020) = (Sdec(2020)+Sjan(2021))/2 - (Sdec(2019)+Sjan(2020))/2
   %
   % Thus the algorithm requires an extra month on either side of the first and
   % last month in the period of record.
   %
   % Note that the values are posted to the first of each month. Therefore in
   % the examples above:
   %
   %     dS/dt(2000) = Sjan*(2001) - Sjan*(2000)
   %     dS/dt(2020) = Sjan*(2021) - Sjan*(2020)
   %
   % where
   %     Sjan*(2000) = (Sdec(1999)+Sjan(2000))/2
   %     Sjan*(2001) = (Sdec(2000)+Sjan(2001))/2
   %
   % and
   %     Sjan*(2020) = (Sdec(2019)+Sjan(2020))/2
   %     Sjan*(2021) = (Sdec(2020)+Sjan(2021))/2
   %
   % This could be
   %
   %
   % Similarly, to compute the value for Ja
   %
   % If the number of months is an even divisor of 12, then the first and last
   %  differences are annual differences of the
   %  respective monthly values. If the number of months is 1 longer than an
   %  even divisor of 12, then for 1 extra month, the last month is a bi-monthly
   %  average
   %
   % See also:

   arguments
      Time
      M
      kwargs.bimonthly (1, 1) logical = true
      kwargs.direction (1, 1) string = true
   end

   nmonths = length(M);

   % if one extra month is provided, the last month can be computed as
   % (M(i) + M(i+1)), consistent with other months. If not, we can either
   % use M(i) for the last month or censor it. I add an extra nan below if
   % the data does not already have an extra month, which means the last
   % bi-monthly value would be nan, except I also have an if statement that
   % instead uses the last monthly value. Can change later if desired.

   if mod(nmonths-1, 12) == 0
      nmonths = nmonths - 1;
   elseif mod(nmonths,12) ~= 0
      error('input data must be posted monthly, or option to provide +1 month');
   else
      M = [M; nan];
   end

   dMdt = nan(nmonths, 1);
   Mt = nan(nmonths, 1);

   % average bi-monthly mass from start to finish
   for n = 1:nmonths

      Mt(n) = (M(n)+M(n+1)) / 2;

      % this is the case where one extra month was not provided. it also
      % works if the first two or more months are nan.
      if isnan(M(n+1))
         Mt(n) = M(n);
      end
   end

   % annual differences on a monthly basis
   for n = 1:nmonths-12
      i = n;
      ii = n+12;

      dMdt(ii) = Mt(ii)-Mt(i);

      % dMdt(ii) = (M(ii)+M(ii+1))/2 - (M(i)+M(i+1))/2;
   end

   % reshape back to vectors of monthly data posted monthly

   % to build the new yearly time vector, if water year or anything other
   % than Jan-Dec, then datetime(years,1,1) won't work b/c we will have one
   % extra year for the last partial year, so this should work:
   numyears = nmonths / 12;
   newtimes = tocolumn(Time(1):calyears(1):Time(1)+calyears(numyears-1));
   mvars = cellstr(datestr(Time(1:12), 'mmm'));

   dMdt = transpose(reshape(dMdt, 12, numyears));
   dMdt = array2timetable(dMdt, 'RowTimes', newtimes);

   dMdt.Properties.VariableNames = mvars;

   Mt = transpose(reshape(Mt, 12, numyears));
   Mt = array2timetable(Mt, 'RowTimes', newtimes);

   Mt.Properties.VariableNames = mvars;

   % dGdt = array2timetable(dGdt,'RowTimes',datetime(years,1,1), ...
   %    'VariableNames',{ 'Jan','Feb','Mar','Apr','May','Jun',...
   %    'Jul','Aug','Sep','Oct','Nov','Dec'});

   % this would return a timetable as a single monthly column
   % dGdt = timetable(dGdt, 'RowTimes', G.Time);

   % % This is the orignal method that uses the Jan + Dec only
   % for n = 2:numel(years)-1
   %    iyear = years(n);
   %    ideci = find(Time == datetime(iyear,12,1));
   %    ijanip1 = find(Time == datetime(iyear+1,1,1));
   %    idecim1 = find(Time == datetime(iyear-1,12,1));
   %    ijani = find(Time == datetime(iyear,1,1));
   %
   %    dGdt(n) = (S(ideci)+S(ijanip1))/2 - (S(idecim1)+S(ijani))/2;
   % end
   % dGdt = timetable(dGdt,'RowTimes',datetime(years,1,1));

   % % the ET calculation from Rodel
   % % this is not right but a start
   % % if we have 60 days of daily et, we compute 31 30-day running averages,
   % % i.e., day 1:30, 2:31, 3:32, 4:33, ... 31:60, then average those to get
   % N = 30;
   % for n = 1:N
   %    for d = 1+n:2+n
   %       Sbar(n) = sum(P(1+n)-E(1+n))
   %    end
   % end
end
