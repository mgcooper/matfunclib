function [trends_tbl, ab_tbl] = timetabletrends(ttbl, varargin)
   %TIMETABLETRENDS Compute trends from data in timetable columns.
   %
   %    [trends_tbl, ab_tbl] = timetabletrends(ttbl)
   %    [trends_tbl, ab_tbl] = timetabletrends(ttbl, Time=Time)
   %    [trends_tbl, ab_tbl] = timetabletrends(ttbl, varnames=varnames)
   %    [trends_tbl, ab_tbl] = timetabletrends(ttbl, method=method)
   %    [trends_tbl, ab_tbl] = timetabletrends(ttbl, quantile=quantile)
   %    [trends_tbl, ab_tbl] = timetabletrends(ttbl, timestep=timestep)
   %
   %  Description
   %    [trends_tbl, ab_tbl] = timetabletrends(ttbl) computes linear trends in
   %    the data stored in each column of TTBL using ordinary least squares
   %    linear regression, using the Time dimension as the regressor. The
   %    evaluated trends timeseries are returned as a timetable TRENDS_TBL. The
   %    estimated parameters of the linear equation are returned in AB_TBL.
   %
   %    [trends_tbl, ab_tbl] = timetabletrends(ttbl, Time=Time) uses the
   %    provided datetime vector TIME as the regressor.
   %
   %    [trends_tbl, ab_tbl] = timetabletrends(ttbl, varnames=varnames) computes
   %    trends for VARNAMES which match values of the VariableNames property of
   %    the input TTBL.
   %
   %    [trends_tbl, ab_tbl] = timetabletrends(ttbl, method=method) computes
   %    trends using the specified METHOD. Valid methods are "ols" (ordinary
   %    least squares), "ts" (Thiel-Sen or time-series regression), and "qtl"
   %    (quantile regression). If method="qtl", the additional name-value
   %    argument quantile=quantile becomes required.
   %
   %    [trends_tbl, ab_tbl] = timetabletrends(ttbl, timestep=timestep) uses the
   %    provided TIMESTEP to set the VariableUnits property of the output
   %    TRENDS_TBL. If TIMESTEP is not provided, the timestep is inferred from
   %    the TIME datetime vector.
   %
   %
   % See also:

   % Check trenddecomp for >=R2021b, see JUST toolbox.
   % also see MTA and ChangeDetection toolboxes.

   % PARSE INPUTS
   [ttbl, time, names, method, timestep, qtl] = parseinputs( ...
      ttbl, mfilename, varargin{:});

   % NOTE: The timestep checking produces a regressor TimeX so the regression on
   % time duration, not the actual time, so if the time is year, then the
   % regression goes on 1:numyears rather than year1:1:yearFinal, which creates
   % a problem if later you want to use the ab values to predict something on
   % the original times. BUT, only the intercept should be affected, so I added
   % the regressor to the table. UPDATE UPDATE: regressing on years might be
   % best. For short-time data, force the user to regress on days, hours,
   % minutes, or seconds, no months

   % if not provided, use the Time variable in the table
   if isnat(time)
      ttbl = renametimetabletimevar(ttbl);
      time = ttbl.Time;
   end

   % if not provided, get the variable names in the table (and units)
   if string(names) == "unset"
      names = gettablevarnames(ttbl);
      units = gettableunits(ttbl);
   else
      units = gettableunits(ttbl, names);
   end

   % get the units
   if isempty(units)
      units = repmat("unset", 1, numel(names));

      % commented this out b/c it errors when varnames are passed in
      % tbl.Properties.VariableUnits = units;
   end

   ntime = height(time);
   nvars = numel(names);

   % find nan-indices inan = isnan(Data);

   %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   % work in progress

   [timestep, TimeX] = settimestep(ttbl, time, timestep);

   % FOR NOW, just use elapsedTime to make a regressor, that way the function
   % returns the trends and timeseries with same units as input

   %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   % Part 1 - compute the trends
   ab = nan(2, nvars);

   for n = 1:nvars
      thisvar = names{n};

      try
         switch method
            case 'ols'
               ab(:,n) = olsfit(TimeX, ttbl.(thisvar));
            case 'ts'
               ab(:,n) = tsregr(TimeX, ttbl.(thisvar));
            case 'qtl'
               ab(:,n) = quantreg(TimeX, ttbl.(thisvar), qtl);
         end
      catch
      end
   end

   % Create a parameter results table
   ab_tbl = array2table(ab, 'VariableNames', names, 'RowNames', {'a','b'});


   % Part 2 - evaluate the trend timeseries
   tstr = nan(ntime,nvars);
   tvars = cell(1,nvars);
   for n = 1:nvars

      thisvar = names{n};
      thisab = ab_tbl.(thisvar);
      tstr(:,n) = thisab(1) + thisab(2).*TimeX;
      tstr(:,n) = setnan(tstr(:,n), [], isnan(ttbl.(thisvar)));

      % to append 'trend' after each variable name, so Trends can be
      % synchronized with input table tbl, use this, otherwise if sending back
      % Trends without the original data, use the og varnames tvars{n}    =
      % [thisvar 'trend'];

      tvars{n} = thisvar;
   end

   % Create a timetable of predicted trend values
   trends_tbl = array2timetable(tstr, 'VariableNames', tvars, 'RowTimes', time);

   % Synchronize with the original table if they are the same size.
   % Holding off on this for now.

   % Add the ab values as a property
   trends_tbl = addprop(trends_tbl, ...
      { 'TrendIntercept', 'TrendSlope'}, ...
      { 'variable',       'variable'  } );

   % Update the properties
   trends_tbl.Properties.CustomProperties.TrendIntercept ...
      = ab(1,:);
   trends_tbl.Properties.CustomProperties.TrendSlope ...
      = ab(2,:);

   % Add the regressor.
   trends_tbl.TimeX = TimeX;

   % Update units, including TimeX. Trends has same units as the data.
   units{end+1} = timestep.Format;

   trends_tbl.Properties.VariableUnits = units;

   % Add /timestep to the ab (trend slope) units.
   for n = 1:numel(units)-1
      units{n} = [units{n} '/' timestep.Format];
   end
   ab_tbl.Properties.VariableUnits = units(1:end-1);
end

function [timestep, TimeX] = settimestep(ttbl, time, timestep)

   % NOTE: need to reconcile this with timetabletimestep.m 
   % NOTE: right now elapsedTime and dTime are not returned. elapsedTime might
   % be useful for computing the total change

   % get the time unit, duration, and timestep
   elapsedTime    =  max(time) - min(time);  % will be in hh:mm:ss
   dTime          =  diff(time);             % timestep in hh:mm:ss

   % if no timestep was provided, check if there is a timestep property
   if string(timestep) == "unset" % isnan(timestep) || isnat(timestep)

      timestep = ttbl.Properties.TimeStep; % note: this is a calendarDuration

      % because tbl.Properties.TimeStep returns a duration, I set timestep in the
      % if/switch below to durations, otherwise I would have 'years' in place of
      % years(1) in the next block, and after that, a switch that sets the
      % timestep in duration and the format, but I don't have a way to convert
      % tbl.Properties.TimeStep to 'years','days','minutes', etc.

      if iscalendarduration(timestep) && isequal(timestep, calmonths(1))
         % if the timestep is calmonth this will fail b/c its not a regular unit
         % of time.
      end

      % if not, try to infer the timestep
      if isempty(timestep)
         if round(years(median(dTime))) == 1
            timestep = years(1);
         elseif round(days(median(dTime))) == 1
            timestep = days(1);
         elseif round(hours(median(dTime))) == 1
            timestep = hours(1);
         elseif round(minutes(median(dTime))) == 1
            timestep = minutes(1);
         elseif round(seconds(median(dTime))) == 1
            timestep = seconds(1);
         end

         % we got the timestep from the timetable, so it is probably a calendar
         % duration, and we need to do this
      else

         if iscalendarduration(timestep)

            [y,m,d] = split(timestep,{'years','months','days'});

            if y == 1
               timestep = years(1);
            elseif m == 1
               % timestep = calmonths(1);
               % see timetabletimestep - need to replace this entire subfunction
               % with a call to that function
               timestep = timetabletimestep(ttbl);
            elseif d == 1
               timestep = days(1);

               % I think if the timestep is <1day, it won't be calendarDuration,
               % so I didn't add minutes/seconds
            elseif d*24 == 1
               timestep = hours(1);
            end
         end
      end
   else

      % if here, convert user-provided timestep to a duration
      switch timestep
         case 'y'
            timestep = years(1);
         case 'd'
            timestep = days(1);
         case 'h'
            timestep = hours(1);
         case 'm'
            timestep = minutes(1);
         case 'seconds'
            timestep = seconds(1);
      end

   end % timestep should be a duration if here

   % in at least one case, it got here and timestep was NaN (duration), but
   % timetabletimestep returned the correct timestep, so call that
   if isnan(timestep)
      try timestep = timetabletimestep(ttbl);
      end
   end


   % now set the format based on the timestep
   switch timestep
      case years(1)
         dTime.Format = 'y';
         elapsedTime.Format = 'y';
         TimeX = years([0; cumsum(dTime)]);
      case days(1)
         dTime.Format = 'd';
         elapsedTime.Format = 'd';
         TimeX = days([0; cumsum(dTime)]);
      case hours(1)
         dTime.Format = 'h';
         elapsedTime.Format = 'h';
         TimeX = hours([0; cumsum(dTime)]);
      case minutes(1)
         dTime.Format = 'm';
         elapsedTime.Format = 'm';
         TimeX = minutes([0; cumsum(dTime)]);
      case seconds(1)
         elapsedTime.Format = 's';
         dTime.Format = 's';
         TimeX = seconds([0; cumsum(dTime)]);
   end

   % % note, this works directly on dTime, w/o converting format
   % dTime = diff(Time);
   % Tdays = [0; days(cumsum(dTime))];
   % Tyears = [0; years(cumsum(dTime))];
end

%% INPUT PARSER
function [ttbl, time, varnames, method, timestep, qtl] = parseinputs( ...
      ttbl, mfilename, varargin)

   parser = inputParser;
   parser.FunctionName = mfilename;
   parser.PartialMatching = true;

   parser.addRequired('ttbl', @istimetable);
   parser.addParameter('Time', NaT, @isdatetime);
   parser.addParameter('timestep', 'unset', @ischarlike);
   parser.addParameter('varnames', 'unset', @ischarlike);
   parser.addParameter('method', 'ols', @ischarlike);
   parser.addParameter('anomalies', true, @islogical);
   parser.addParameter('quantile', NaN, @isnumeric);
   parser.parse(ttbl, varargin{:});

   time = parser.Results.Time;
   timestep = parser.Results.timestep;
   varnames = parser.Results.varnames;
   method = parser.Results.method;
   qtl = parser.Results.quantile;

   if string(method) == "qtl" && isnan(qtl)
      error('must provide quantile for method ''qtl''')
   end
end
