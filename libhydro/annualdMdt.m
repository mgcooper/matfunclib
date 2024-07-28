function [dMdt, Mt, M, Time] = annualdMdt(M, Time, kwargs)
   %ANNUALDMDT Compute annual mass differences from monthly stores.
   %
   %    [DMDT, MT] = ANNUALDMDT(M, TIME)
   %
   % Inputs:
   %
   %    TIME - A monthly datetime calendar, ideally with one extra month at both
   %    ends of the period to compute the first and last bi-monthly average. For
   %    instance, to obtain a calendar year difference for year(i), TIME should
   %    begin Dec of year(i-1). To compute a calendar year difference for
   %    year(N), TIME should end Jan of year(N+1). The function automatically
   %    accounts for the presence or absence of these extra values. If TIME
   %    includes only one extravalue on one side, the user should supply the
   %    "extraside" parameter to specify which side contains the extravalue. The
   %    values returned by this function will be posted beginning Jan of year(i)
   %    and ending Dec of year(N) (or beginning on whichever month marks the
   %    first month and ending on the month 12 months later).
   %
   %    M - A vector or matrix of a mass (or other conserved quantity),
   %    nominally registered to the middle of each month in Time.
   %
   % Outputs:
   %
   %    DMDT - Rate of change of M with respect to time T on an annual basis.
   %    Differences are posted on a monthly timestep such that annual
   %    differences can be obtained for arbitrary definitions of "years".
   %    However, note that differences are posted to the START month/year. This
   %    is consistent with a calendar-year conventions where annual values are
   %    posted to Jan 1 of the calendar year, but could lead to confusion if
   %    water-year values are analyzed. In this case, simply obtain the water
   %    year difference by indexing into October of the calendar year in which
   %    the water year BEGINS, which is the water year minus one.
   %
   % Description:
   %
   %    [DMDT, MT] = ANNUALDMDT(M, TIME) Computes annual differences of mass,
   %    e.g. gravimetric water storage, climate model snow mass, etc. Input data
   %    are assumed to be monthly averages nominally posted mid-month; bimonthly
   %    averaging creates monthly values posted at the month start. Annual
   %    differences are posted to the START month/year of each annual period,
   %    i.e., differences are in a "forward" sense, where the difference for
   %    year_i is:
   %
   %     dMdt(MMM)_year_i = M(MMM)_year_(i+1) - M(MMM)_year_(i).
   %
   %    Here, M is mass and MMM indexes months. Differences are posted monthly
   %    such that the annual calendar-year difference for year i would typically
   %    be obtained from the January values:
   %
   %     dMdt_calyear_i = M(Jan)_year_(i+1) - M(Jan)_year_(i).
   %
   %    Here, dMdt_calyear_i represents the change in mass during year i.
   %
   %  ** NOTE ON WATER YEARS **
   %
   %    The indexing example above leads to a potentially confusing discrepancy
   %    for water years. The annual water-year difference for year i requires
   %    shifting the index:
   %
   %     dMdt_wateryear_i = M(Oct)_year_(i) - M(Oct)_year_(i-1).
   %
   %    Here, dMdt_wateryear_i represents the change in mass during wateryear_i.
   %
   %    As an alternative to thinking in terms of "shifting the index", simply
   %    obtain the water year value dMdt_wateryear_i by indexing into the
   %    calendar returned by this function using the START month of a given
   %    water year (which occurs in the PREVIOUS calendar year), then add 1 to
   %    the year to obtain the water year:
   %
   %     dMdt_wateryear_i_minus_1 = M(Oct)_year_(i+1) - M(Oct)_year_(i).
   %
   %    Notice that the indexing now matches the calendar year example. Simply
   %    add +1 to the year obtained from index i or obtain it from index i+1.
   %
   %    The important thing is that this function performs the averaging and
   %    differencing and posts them to the START month (differences are in a
   %    "forward" sense).
   %
   %  ** NOTE ON STORES VERSUS FLUXES **
   %
   %    Recall these calculations apply to STORES not FLUXES (they yield
   %    fluxes). Whereas one would typically obtain annual stores by summing
   %    fluxes over Jan(year_i) to Dec(year_i), annual fluxes are obtained by
   %    differencing annual stores between months of respective years:
   %    Jan(year_i+1) - Jan(year_i). Recall the bimonthly averaging yields
   %    values on the start of each month.
   %
   %    IMPORTANT PROGRAMMING NOTE: THIS MEANS THE BIMONTHLY AVERAGES MUST
   %    "GO INTO" THE SECOND MONTH (index on LHS equals second index on RHS):
   %        Sbar_jan(i)   = ( Sbar_dec(i-1) + Sbar_jan(i) )   / 2
   %        Sbar_jan(i+1) = ( Sbar_dec(i)   + Sbar_jan(i+1) ) / 2
   %        dS/dt(i)      =   Sbar_jan(i+1) - Sbar_jan(i)
   %    See the discussion that follows.
   %
   %  ** NOTES ON BIMONTHLY AVERAGING **
   %
   %    The bi-monthly averaging is based on a method from Crow et al. 2017 to
   %    estimate annual differences of Grace dS/dt:
   %
   %    dS/dt(i) = (Sbar_dec(i)+Sbar_jan(i+1))/2 - (Sbar_dec(i-1)+Sbar_jan(i))/2
   %    dS/dt(i) = S_jan(i+1) - S_jan(i)
   %
   %    Note, if averages "go into" the first month, the differencing becomes:
   %    dS/dt(i) = S_dec(i) - S_dec(i-1)
   %
   %    In contrast, for water-year differences:
   %
   %    dS/dt(i) = (Sbar_sep(i)+Sbar_oct(i))/2 - (Sbar_sep(i-1)+Sbar_oct(i-1))/2
   %    dS/dt(i) = S_oct(i) - S_oct(i-1)
   %
   %    Note, if averages "go into" the first month, the differencing becomes:
   %    dS/dt(i) = S_sep(i) - S_sep(i-1)
   %
   %    Thus for the calendar-year:
   %    dS/dt(i) = S_jan(i+1) - S_jan(i)
   %
   %    Whereas for the water-year:
   %    dS/dt(i) = S_oct(i) - S_oct(i-1)
   %
   %    Although this indexing discrepancy is potentially confusing, IT IS
   %    RESOLVED BY THE CONVENTION THAT DIFFERENCES ARE POSTED TO THE START
   %    MONTH/YEAR OF EACH ANNUAL PERIOD. See the two examples above which show
   %    how to think about it in terms of EITHER adding +1 to the index OR +1 to
   %    the year.
   %
   %    Bi-monthly averaging requires an extra month of data on either side of
   %    the period of record, i.e., to compute the value for January of year i,
   %    where i=1, the value from December of year i-1 is required.
   %
   %    Strictly, to compute bi-monthly averages, an extra month is not required
   %    on the other side of the data. However to compute annual differences for
   %    all years of record, it becomes necessary to have an extra month to
   %    compute the annual difference for the final year.
   %
   %    For example, if the period of record is 2000-2020, this function will
   %    return annual differences for annual periods beginning each month,
   %    Jan-Dec, over each year in 2000-2020, but these calculations will only
   %    be consistent if an extra month is provided:
   %
   %    To compute the annual difference for year 2000:
   %     dS/dt(2000) = (Sdec(2000)+Sjan(2001))/2 - (Sdec(1999)+Sjan(2000))/2
   %
   %    And to compute the annual difference for year 2020:
   %     dS/dt(2020) = (Sdec(2020)+Sjan(2021))/2 - (Sdec(2019)+Sjan(2020))/2
   %
   %    Thus the algorithm requires an extra month on either side of the first
   %    and last month in the period of record (Sdec(1999) and Sjan(2021) in the
   %    example above).
   %
   %    If the number of months in TIME is an even divisor of 12, then bimonthly
   %    averaging is NOT performed, the first and last monthly values are used
   %    as-is, and therefore the first  and last differences are annual
   %    differences of the respective monthly values. If the number of months is
   %    1 longer than an even divisor of 12, then for 1 extra month, the last
   %    month is a bi-monthly average
   %
   % See also:

   arguments
      M (:, 1)
      Time (:, 1)
      kwargs.bimonthly (1, 1) logical = true
      kwargs.extraside (1, 1) string {mustBeMember(...
         kwargs.extraside, ["left", "right", "both", "none", "unknown"])} ...
         = "unknown"
      kwargs.plotflag (1, 1) logical = false
   end

   % Prepare the vector for bimonthly averaging.
   if kwargs.bimonthly
      [M, Time] = prepareBimonthly(M, Time, kwargs.extraside);
   end

   N = length(M);
   Mt = nan(N, 1);
   dMdt = nan(N, 1);

   % Compute bi-monthly averages.
   for i = 1:N-1
      Mt(i+1) = (M(i) + M(i+1)) / 2;
   end

   % Compute annual differences of bi-monthly averages on a monthly basis.
   for i = 1:(N-12)-1
      ii = i+12;
      dMdt(i+1) = Mt(ii+1)-Mt(i+1);
   end

   % See notes in "debugcalc" subfunction if any confusion arises.

   % After the two loops above, Mt (and dMdt) has an extra first month used to
   % compute the first bimonthly average, which is nan, and an extra last month,
   % which is not nan but was only needed to compute the final annual
   % difference, which is in dMdt(N-12). Remove these extra values.
   [Mt, dMdt, M, Time] = deal(Mt(2:N-1), dMdt(2:N-1), M(2:N-1), Time(2:N-1));

   % Plot the result if requested.
   if kwargs.plotflag
      figure
      hold on
      plot(Time, Mt, '-')
      plot(Time, M, ':')
      legend('Bimonthly Averages', 'Original Data')
   end

   % Build an annual calendar.
   numyears = (N-2) / 12;
   newtimes = transpose(Time(1):calyears(1):Time(1)+calyears(numyears-1));
   months = cellstr(datestr(Time(1:12), 'mmm'));

   % Reshape to a matrix [years x months].
   Mt = transpose(reshape(Mt, 12, numyears));
   dMdt = transpose(reshape(dMdt, 12, numyears));

   Mt = array2timetable(Mt, 'RowTimes', newtimes, 'VariableNames', months);
   dMdt = array2timetable(dMdt, 'RowTimes', newtimes, 'VariableNames', months);

   % This would return a timetable as a single monthly column:
   % dMdt = timetable(dMdt, 'RowTimes', Time);

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

function [M, T] = prepareBimonthly(M, T, extraside)

   nmonths = length(M);
   if mod(nmonths, 12) == 0

      % Repeat the first and last month to ensure length(M) == nmonths+2.
      % Bi-monthly averaging of these repeats will return the original values.
      M = [M(1); M; M(end)];
      T = [T(1); T; T(end)];

   elseif mod(nmonths - 1, 12) == 0

      assert(strcmp(extraside, {'left', 'right'}))

      % Repeat the missing side so averaging yields the same value.
      switch extraside
         case "left"
            M = [M; M(end)];
            T = [T; T(end)];
         case "right"
            M = [M(1); M];
            T = [T(1); T];
      end

   elseif mod(nmonths-2, 12) == 0
      % allow extraside to be unknown, assume it is "both".

   elseif mod(nmonths,12) ~= 0
      error(['input data must be posted monthly, for an even number of ' ...
         'annual periods, optionally with +1 extra month on one or both sides']);
   end
end

function debugcalc(Mt, dMdt)

   % Compute bi-monthly averages. Note: The values are later registered to Time.
   for i = 1:N-1
      Mt(i+1) = (M(i) + M(i+1)) / 2;

      % dMdt(i+1) = (M(ii)+M(ii+1))/2 - (M(i)+M(i+1))/2;
      % where ii = i+12
   end

   % Compute annual differences on a monthly basis.
   for i = 1:(N-12)-1

      ii = i+12;
      dMdt(i+1) = Mt(ii+1)-Mt(i+1);

      % Here ii and ii+1 represent the 12 month forward bimonthly average, and
      % i and i+1 represent the start bimonthly average.
      %  dMdt(i+1) = (M(ii)+M(ii+1))/2 - (M(i)+M(i+1))/2;
      %
      % For example, if i=1 is Dec 2000:
      %  dMdt(Jan2001) = (M(Dec2001)+M(Jan2002))/2 - (M(Dec2000)+M(Jan2001))/2;
      %
      % Or in terms of Mt:
      %  dMdt(i+1) = Mt(ii+1) - Mt(i+1);
      %  dMdt(Jan2001) = Mt(Jan2002) - Mt(Jan2001);
      %
      % At the end of the timeseries, say Jan 2021
      %  dMdt(Jan2021) = (M(Dec2021)+M(Jan2022))/2 - (M(Dec2020)+M(Jan2021))/2;
      %  dMdt(Jan2021) = Mt(Jan2022) - Mt(Jan2021);
      %
      % For indexing, for N=nmonths+2, where Jan2022 is i=N, and the final
      % annual difference is one year prior, Jan2021:
      %  dMdt(N-12) = (M(N-1)+M(N))/2 - (M(N-12-1)+M(N-12))/2;
      % Or
      %  dMdt(N-12) = Mt(N) - Mt(N-12)
      %
      % Say i=(N-12)-1, then ii=N-1, and we want:
      %  dMdt(i+1) = Mt(ii+1) - Mt(i+1);
      % Plug in for i and ii in terms of N:
      %  dMdt(N-12) = Mt(N) - Mt(N-12);
      % Which is the correct result.
   end

   % % This is the orignal method that uses the Jan + Dec only
   % for n = 2:numel(years)-1
   %    iyear = years(n);
   %    ideci = find(Time == datetime(iyear,12,1));
   %    ijanip1 = find(Time == datetime(iyear+1,1,1));
   %    idecim1 = find(Time == datetime(iyear-1,12,1));
   %    ijani = find(Time == datetime(iyear,1,1));
   %
   %    dMdt(n) = (S(ideci)+S(ijanip1))/2 - (S(idecim1)+S(ijani))/2;
   % end
   % dMdt = timetable(dMdt, 'RowTimes', datetime(years,1,1));
end
