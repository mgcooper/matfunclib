function [dMdt, Mbar, M, Time] = annualdMdt(M, Time, kwargs)
   %ANNUALDMDT Compute annual differences from monthly values of stored mass.
   %
   %    [dMdt, Mbar, M, Time] = annualdMdt(M, Time)
   %    [dMdt, Mbar, M, Time] = annualdMdt(M, Time, bimonthly=false)
   %    [dMdt, Mbar, M, Time] = annualdMdt(M, Time, extraside="left")
   %    [dMdt, Mbar, M, Time] = annualdMdt(M, Time, extraside="right")
   %    [dMdt, Mbar, M, Time] = annualdMdt(M, Time, astimetable=false)
   %    [dMdt, Mbar, M, Time] = annualdMdt(M, Time, ascolumn=true)
   %
   % Description:
   %
   %    [DMDT, MT] = ANNUALDMDT(M, TIME) Computes annual differences DMDT from
   %    monthly values of mass M, e.g., gravimetric water storage, climate model
   %    snow mass, etc. Input data M are assumed to be a timeseries [months x 1]
   %    of monthly averages nominally posted mid-month; bimonthly averaging
   %    creates monthly values posted at the month start. Annual differences are
   %    posted to the START month/year of each annual period, i.e., differences
   %    are in a 12-month "forward" sense, where the 12-month forward difference
   %    for month j of year i is:
   %
   %     dMdt(i, j) = M(i+1, j) - M(i, j).
   %
   %    Forward differences are computed beginning each month such that the
   %    annual calendar-year difference for year i would be obtained from the
   %    January values:
   %
   %     dMdt_calyear_i = M(i+1, j(Jan, i+1)) - M(i, j(Jan, i)).
   %
   %    Here, dMdt_calyear_i represents the change in mass during year i, and
   %    j(Jan, i+1) and j(Jan, i) are indices for the month of January in year
   %    i+1 and year i, respectively.
   %
   %    See notes below about water years.
   %
   % Inputs:
   %
   %    TIME - A monthly datetime calendar, ideally with one extra month on
   %    either side to compute the first and last bi-monthly average. For
   %    instance, to obtain an accurate calendar-year difference for year(i),
   %    TIME should begin Dec of year(i-1), so the bi-monthly average value for
   %    Jan of year(i) can be computed, by averaging the value for Dec of
   %    year(i-1) and the value for Jan of year(i). Similarly, to compute a
   %    calendar year difference for year(N), TIME should end Jan of year(N+1),
   %    where N is the last year. Thus TIME and M should both have length
   %    (12*N+2), where 12*N is the total number of months, and +2 accounts for
   %    one extra month on either side.
   %
   %    The function automatically accounts for the presence or absence of extra
   %    months on either side. If TIME includes only one extra month on one
   %    side, the user should supply the "extraside" parameter to specify which
   %    side contains the extra value. The values returned by this function will
   %    not include these extra values; values are posted beginning Jan of
   %    year(i) and ending Dec of year(N) (or beginning on whichever month marks
   %    the first month and ending on the month 12 months later). To omit
   %    bimonthly averaging altogether, specify BIMONTHLY=FALSE.
   %
   %    M - A vector or matrix of a mass (or other conserved quantity),
   %    nominally registered to the middle of each month in Time.
   %
   %    BIMONTHLY - (optional, name-value) Logical flag to control whether
   %    bimonthly averaging of neighboring months is performed to compute
   %    month-start values. The default value is TRUE.
   %
   %    EXTRASIDE - (optional, name-value) String indicating which side ("left"
   %    or "right") has an extra value for bi-monthly averaging. Use this option
   %    to resolve the ambiguity when only one side has an extra value. The
   %    default value is BOTH.
   %
   %    ASTIMETABLE - (optional, name-value) Logical flag to control whether
   %    outputs DMDT and MBAR are returned as timetables. The default value is
   %    TRUE.
   %
   %    ASCOLUMN - (optional, name-value) Logical flag to control whether
   %    outputs DMDT and MBAR are returned as column vectors, i.e., in the same
   %    format as input M, TIME, or as 2d arrays with dimensions [year month].
   %    The default value is FALSE.
   %
   % Outputs:
   %
   %    DMDT - Rate of change of M with respect to time T on an annual basis,
   %    returned as a timetable of size [years x 12]. Differences are computed
   %    considering each month as the beginning of 12-month forward periods such
   %    that annual differences can be obtained for arbitrary definitions of
   %    "years" (e.g., "water years" beginning Oct 1).
   %
   %    MBAR - Bimonthly average M, returned as a timetable of size [years x
   %    12]. Specify ASCOLUMN=TRUE to return as [months x 1].
   %
   %    Note: If ASTIMETABLE=TRUE and ASCOLUMN=TRUE, both DMDT and MBAR will be
   %    returned as timetables with one column named, respectively, dMdt and M.
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
   %     dS/dt(i)      = Sbar_jan(i+1)  -  Sbar_jan(i)
   %     Sbar_jan(i+1) = (  S_dec(i)    +  S_jan(i+1) ) / 2
   %     Sbar_jan(i)   = (  S_dec(i-1)  +  S_jan(i)   ) / 2
   %
   %    If averages "go into" the first month, the bi-monthly averaging remains
   %    the same, but differences would need to be computed as:
   %
   %     dS/dt(i)      = Sbar_dec(i)    -  Sbar_dec(i-1)
   %
   %    Bi-monthly averaging requires an extra month of data on either side of
   %    the period of record, i.e., to compute the value for January of year i,
   %    the value from December of year i-1 is required.
   %
   %    An extra month is not strictly required to compute the bi-monthly
   %    average for the final month, since it is averaged with its left neighbor
   %    (the final Dec bi-monthly average is the average of the final Nov and
   %    Dec values). However, to compute the final annual difference, it becomes
   %    necessary to have an extra month (Jan following the final Dec) to
   %    compute the annual difference for the final year.
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
   %    Thus the algorithm requires two extra months (Sdec(1999) and Sjan(2021)
   %    in the above example), one each on either side of the first and last
   %    month in the period of record.
   %
   %    If the number of months in TIME is an even divisor of 12, then bimonthly
   %    averaging is NOT performed for the first and last monthly values, but IS
   %    performed for all months in between. To turn of bimonthly averaging
   %    altogether, set the optional name-value parameter BIMONTHLY=FALSE.
   %
   % See also:

   arguments
      M (:, 1) double
      Time (:, 1) datetime
      kwargs.bimonthly (1, 1) logical = true
      kwargs.extraside (1, 1) string {mustBeMember(...
         kwargs.extraside, ["left", "right", "both", "none", "unknown"])} ...
         = "unknown"
      kwargs.astimetable (1, 1) logical = true
      kwargs.ascolumn (1, 1) logical = false
      kwargs.withextra (1, 1) logical = false
      kwargs.plotflag (1, 1) logical = false
   end

   % Prepare the vector for bimonthly averaging (or not).
   [M, Time] = prepareBimonthly(M, Time, kwargs.extraside, kwargs.bimonthly);

   % Initialize outputs.
   N = length(M);
   Mbar = nan(N, 1);
   dMdt = nan(N, 1);

   % Compute bi-monthly averages (or not).
   if kwargs.bimonthly
      for i = 1:N-1
         Mbar(i+1) = (M(i) + M(i+1)) / 2;
      end
   else
      Mbar = M;
   end

   % Compute 12-month forward annual differences on a monthly basis.
   for i = 1:(N-12)-1
      ii = i+12;
      dMdt(i+1) = Mbar(ii+1)-Mbar(i+1);
   end

   % Remove the extra values on either side used for bi-monthly averaging.
   if kwargs.withextra
      assert(kwargs.ascolumn)
      keep = 1:N;
   else
      keep = 2:N-1;
   end

   [Mbar, dMdt, M, Time] = deal(Mbar(keep), dMdt(keep), M(keep), Time(keep));

   % Plot the result if requested.
   if kwargs.plotflag
      createfigure(Time, M, Mbar)
   end

   % Prepare the outputs
   [Mbar, dMdt] = prepareOutputs(Mbar, dMdt, M, Time, kwargs);
end

%%
function [M, T] = prepareBimonthly(M, T, extraside, bimonthly)

   nmonths = length(M);

   if not(bimonthly)

      assert(mod(nmonths, 12) == 0, ['input data must be posted monthly, ' ...
         'for an even number of annual periods.']);

      % Repeat the first and last month to ensure length(M) == nmonths+2.
      % Bimonthly averaging of these repeats will return the original values.
      M = [M(1); M; M(end)];
      T = [T(1); T; T(end)];

   else

      if mod(nmonths, 12) == 0

         % Repeat the first and last month to ensure length(M) == nmonths+2.
         % Bimonthly averaging of these repeats will return the original values.
         M = [M(1); M; M(end)];
         T = [T(1); T; T(end)];

      elseif mod(nmonths - 1, 12) == 0

         assert(ismember(extraside, {'left', 'right'}), ...
            ['If one extra month is supplied, "extraside" must be "left" ' ...
            'or "right" to resolve the ambiguity.'])

         % Repeat the missing side so averaging yields the original value.
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
         error( ...
            ['input data must be posted monthly, for an even number of ' ...
            'annual periods, with an optional extra month on either side.'])
      end
   end
end
%%
function createfigure(Time, M, Mbar)
   figure
   hold on
   plot(Time, Mbar, '-')
   plot(Time, M, ':')
   legend('Bimonthly Averages', 'Original Data')
end
%%

function [Mbar, dMdt] = prepareOutputs(Mbar, dMdt, M, Time, kwargs)

   N = length(M);

   % Keep as a column [year*month x 1] or return a matrix [year x month]
   if kwargs.ascolumn

      if kwargs.astimetable
         % Return timetables with a single monthly column:
         Mbar = timetable(Mbar, 'RowTimes', Time, 'VariableNames', {'M'});
         dMdt = timetable(dMdt, 'RowTimes', Time, 'VariableNames', {'dMdt'});
      end

   else
      % Reshape to a matrix [year x month].
      numyears = N / 12;
      Mbar = transpose(reshape(Mbar, 12, numyears));
      dMdt = transpose(reshape(dMdt, 12, numyears));

      % Build an annual calendar.
      times = transpose(Time(1):calyears(1):Time(1)+calyears(numyears-1));
      month = cellstr(datestr(Time(1:12), 'mmm'));

      % Convert to timetables unless otherwise requested.
      if kwargs.astimetable

         % Create timetables
         Mbar = array2timetable(Mbar, 'RowTimes', times, 'VariableNames', month);
         dMdt = array2timetable(dMdt, 'RowTimes', times, 'VariableNames', month);
      end
   end
end
