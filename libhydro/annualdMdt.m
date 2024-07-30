function [dMdt, Mbar, M, Time] = annualdMdt(M, Time, kwargs)
   %ANNUALDMDT Compute annual differences from monthly values of stored mass.
   %
   %    [DMDT, MT] = ANNUALDMDT(M, TIME)
   %
   % Description:
   %
   %    [DMDT, MT] = ANNUALDMDT(M, TIME) Computes annual differences from
   %    monthly values of mass, e.g., gravimetric water storage, climate model
   %    snow mass, etc. Input data are assumed to be a timeseries [months x 1]
   %    of monthly averages nominally posted mid-month; bimonthly averaging
   %    creates monthly values posted at the month start. Annual differences are
   %    posted to the START month/year of each annual period, i.e., differences
   %    are in a 12-month "forward" sense, where the difference for year_i is:
   %
   %     dMdt(MMM)_year_i = M(MMM)_year_(i+1) - M(MMM)_year_(i).
   %
   %    Here, M is mass and MMM indexes months. Differences are posted monthly
   %    such that the annual calendar-year difference for year i would be
   %    obtained from the January values:
   %
   %     dMdt_calyear_i = M(Jan)_year_(i+1) - M(Jan)_year_(i).
   %
   %    Here, dMdt_calyear_i represents the change in mass during year i. See
   %    notes below about water years.
   %
   % Inputs:
   %
   %    TIME - A monthly datetime calendar, ideally with one extra month on
   %    either side to compute the first and last bi-monthly average. For
   %    instance, to obtain an accurate calendar year difference for year(i),
   %    TIME should begin Dec of year(i-1), so the bi-monthly average value for
   %    Jan of year(i) can be computed, by averaging the value for Dec of
   %    year(i-1) and the value for Jan of year(i). Similarly, to compute a
   %    calendar year difference for year(N), TIME should end Jan of year(N+1),
   %    where N is the last year. Thus TIME and M should both have length
   %    (12*N+2), where 12*N is the total number of months, and +2 accounts for
   %    one extra month on either side.
   %
   %    The function automatically accounts for the presence or absence of extra
   %    values on either side. If TIME includes only one extravalue on one side,
   %    the user should supply the "extraside" parameter to specify which side
   %    contains the extravalue. The values returned by this function will not
   %    include these extra values; values are posted beginning Jan of year(i)
   %    and ending Dec of year(N) (or beginning on whichever month marks the
   %    first month and ending on the month 12 months later).
   %
   %    M - A vector or matrix of a mass (or other conserved quantity),
   %    nominally registered to the middle of each month in Time.
   %
   %    BIMONTHLY - (optional, name-value) Logical flag to control whether
   %    bimonthly averaging of neighboring months is performed to compute
   %    month-start values.
   %
   %    EXTRASIDE - (optional, name-value) String indicating which side ("left"
   %    or "right") has an extra value for bi-monthly averaging. Use this option
   %    to resolve the ambiguity when only one side has an extra value.
   %
   % Outputs:
   %
   %    DMDT - Rate of change of M with respect to time T on an annual basis,
   %    returned as a timetable of size [years x 12]. Differences are computed
   %    considering each month as the beginning of 12-month forward periods such
   %    that annual differences can be obtained for arbitrary definitions of
   %    "years" (e.g., "water years" beginning Oct 1).
   %
   %  ** NOTE ON WATER YEARS **
   %
   %    Differences are posted to the START month/year. For instance, the rate
   %    of change between Jan 2000 and Jan 2001 will be registered to Jan 2000
   %    in the output timetable. This is consistent with a calendar-year
   %    convention where annual values are posted to Jan 1 of the calendar year.
   %    To analyze water-year differences, index into October of the calendar
   %    year in which the water year BEGINS, which is the water year minus one.
   %
   %  ** NOTE ON STORES VERSUS FLUXES **
   %
   %    This function is designed to compute annual differences of stores not
   %    fluxes. Whereas one would typically obtain annual stores by summing
   %    fluxes over Jan(year_i) to Dec(year_i), annual fluxes are obtained by
   %    differencing annual stores between months of respective years:
   %    Jan(year_i+1) - Jan(year_i). Recall the bimonthly averaging yields
   %    values on the start of each month. See the discussion that follows.
   %
   %  ** NOTE ON BIMONTHLY AVERAGING **
   %
   %    The bi-monthly averaging is based on a method from Crow et al. 2017 to
   %    estimate annual differences of Grace water storage, dS/dt:
   %
   %     dS/dt(i) = (S_dec(i) + S_jan(i+1)) / 2 - (S_dec(i-1) + S_jan(i)) / 2
   %     dS/dt(i) =        Sbar_jan(i+1)        -         Sbar_jan(i)
   %
   %    Important programming note: The indexing convention above means that
   %    bi-monthly averages must "go into" the SECOND month, i.e., the index on
   %    the LHS of the following expressions equals the second index on the RHS:
   %
   %     Sbar_jan(i+1) = ( S_dec(i)   + S_jan(i+1) ) / 2
   %     Sbar_jan(i)   = ( S_dec(i-1) + S_jan(i) )   / 2
   %     dS/dt(i)      =   S_jan(i+1) - S_jan(i)
   %
   %    If averages "go into" the first month, the bi-monthly averaging remains
   %    the same, but differences would need to be computed as:
   %
   %     dS/dt(i)      =   S_dec(i) - S_dec(i-1)
   %
   %    Bi-monthly averaging requires an extra month of data on either side of
   %    the period of record, i.e., to compute the value for January of year i,
   %    where i=1, the value from December of year i-1 is required.
   %
   %    An extra month is not strictly required to compute the bi-monthly
   %    average for the final month, since it is averaged with its left
   %    neighbor. For example, the final Dec bi-monthly average is the average
   %    of the final Nov and Dec values. However, to compute the final annual
   %    difference, it becomes necessary to have an extra month (Jan following
   %    the final Dec) to compute the annual difference for the final year.
   %
   %    To illustrate, if the period of record is 2000-2020, this function will
   %    return annual differences for annual periods beginning each month,
   %    Jan-Dec, over each year in 2000-2020, but these calculations will only
   %    be consistent if an extra month is provided on either side:
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
   %    averaging is NOT performed for the first and last monthly values, but is
   %    performed for all months in between. To turn of bimonthly averaging
   %    altogether, set the optional name-value parameter BIMONTHLY=FALSE.
   %
   % See also:


   arguments
      M (:, 1)
      Time (:, 1)
      kwargs.bimonthly (1, 1) logical = true
      kwargs.extraside (1, 1) string {mustBeMember(...
         kwargs.extraside, ["left", "right", "both", "none", "unknown"])} ...
         = "unknown"
      kwargs.astimetables (1, 1) logical = true
      kwargs.plotflag (1, 1) logical = false
   end

   % Prepare the vector for bimonthly averaging.
   if kwargs.bimonthly
      [M, Time] = prepareBimonthly(M, Time, kwargs.extraside);
   end

   N = length(M);
   Mbar = nan(N, 1);
   dMdt = nan(N, 1);

   % Compute bi-monthly averages.
   for i = 1:N-1
      Mbar(i+1) = (M(i) + M(i+1)) / 2;
   end

   % Compute annual differences of bi-monthly averages on a monthly basis.
   for i = 1:(N-12)-1
      ii = i+12;
      dMdt(i+1) = Mbar(ii+1)-Mbar(i+1);
   end

   % Remove the extra values on either side used for bi-monthly averaging.
   [Mbar, dMdt, M, Time] = deal(Mbar(2:N-1), dMdt(2:N-1), M(2:N-1), Time(2:N-1));

   % Plot the result if requested.
   if kwargs.plotflag
      figure
      hold on
      plot(Time, Mbar, '-')
      plot(Time, M, ':')
      legend('Bimonthly Averages', 'Original Data')
   end

   if kwargs.astimetables
      % Build an annual calendar.
      numyears = (N-2) / 12;
      newtimes = transpose(Time(1):calyears(1):Time(1)+calyears(numyears-1));
      months = cellstr(datestr(Time(1:12), 'mmm'));

      % Reshape to a matrix [years x months].
      Mbar = transpose(reshape(Mbar, 12, numyears));
      dMdt = transpose(reshape(dMdt, 12, numyears));

      % Create timetables
      Mbar = array2timetable(Mbar, 'RowTimes', newtimes, 'VariableNames', months);
      dMdt = array2timetable(dMdt, 'RowTimes', newtimes, 'VariableNames', months);
   end

   % To return a timetable as a single monthly column:
   % dMdt = timetable(dMdt, 'RowTimes', Time);
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

function debugcalc(Mbar, dMdt)

   % Compute bi-monthly averages. Note: The values are later registered to Time.
   for i = 1:N-1
      Mbar(i+1) = (M(i) + M(i+1)) / 2;

      % dMdt(i+1) = (M(ii)+M(ii+1))/2 - (M(i)+M(i+1))/2;
      % where ii = i+12
   end

   % Compute annual differences on a monthly basis.
   for i = 1:(N-12)-1

      ii = i+12;
      dMdt(i+1) = Mbar(ii+1)-Mbar(i+1);

      % Here ii and ii+1 represent the 12 month forward bimonthly average, and
      % i and i+1 represent the start bimonthly average.
      %  dMdt(i+1) = (M(ii)+M(ii+1))/2 - (M(i)+M(i+1))/2;
      %
      % For example, if i=1 is Dec 2000:
      %  dMdt(Jan2001) = (M(Dec2001)+M(Jan2002))/2 - (M(Dec2000)+M(Jan2001))/2;
      %
      % Or in terms of Mbar:
      %  dMdt(i+1) = Mbar(ii+1) - Mbar(i+1);
      %  dMdt(Jan2001) = Mbar(Jan2002) - Mbar(Jan2001);
      %
      % At the end of the timeseries, say Jan 2021
      %  dMdt(Jan2021) = (M(Dec2021)+M(Jan2022))/2 - (M(Dec2020)+M(Jan2021))/2;
      %  dMdt(Jan2021) = Mbar(Jan2022) - Mbar(Jan2021);
      %
      % For indexing, for N=nmonths+2, where Jan2022 is i=N, and the final
      % annual difference is one year prior, Jan2021:
      %  dMdt(N-12) = (M(N-1)+M(N))/2 - (M(N-12-1)+M(N-12))/2;
      % Or
      %  dMdt(N-12) = Mbar(N) - Mbar(N-12)
      %
      % Say i=(N-12)-1, then ii=N-1, and we want:
      %  dMdt(i+1) = Mbar(ii+1) - Mbar(i+1);
      % Plug in for i and ii in terms of N:
      %  dMdt(N-12) = Mbar(N) - Mbar(N-12);
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
