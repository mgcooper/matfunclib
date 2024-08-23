function Time = synchronizeCalendars(tbls, kwargs)
   %SYNCHRONIZECALENDARS Create a synchronized calendar from multiple timetables
   %
   %    Time = synchronizeCalendars(tbls)
   %    Time = synchronizeCalendars(tbls, dt=dt)
   %
   %  Description
   %    Time = synchronizeCalendars(tbls, kwargs) constructs a datetime vector
   %    (calendar) spanning the common times of all input timetables in TBLS.
   %
   %  Inputs
   %    tbls - timetables
   %    dt - The new timestep. The default value is dt=caldays(1)).
   %    newTimeBasis - Determines how the common time range is calculated.
   %    Valid values are:
   %        * 'union'        - Returns the union of the row times.
   %        * 'intersection' - Returns the intersection of the row times.
   %        * 'commonrange'  - Union of the row times, but over the
   %        *                  intersection of the time ranges.
   %        * 'first'        - Row times from the first input timetable.
   %        * 'last'         - Row times from the last input timetable.
   %
   %  Outputs
   %    Time - A datetime vector spanning the common time range
   %
   % See also: synchronize synchronizeTimeTables

   arguments(Input,Repeating)
      tbls timetable
   end
   arguments(Input)
      kwargs.dt (1, 1) = caldays(1)
      kwargs.newTimeBasis (1, 1) string {mustBeMember(kwargs.newTimeBasis, ...
         {'union', 'intersection', 'commonrange', 'first', 'last'})} = "union"
      kwargs.newTimeStep (1, 1) string {mustBeMember(kwargs.newTimeStep, ...
         {'yearly', 'quarterly', 'monthly', 'weekly', 'daily', 'hourly', ...
         'minutely', 'secondly', 'unspecified'})} = "unspecified"
   end

   % Ensure that either dt or newTimeStep is used, but not both
   if kwargs.newTimeStep ~= "unspecified" && kwargs.dt ~= caldays(1)
      error("Specify either 'dt' or 'newTimeStep', but not both.");
   end

   % Get the time bounds and row times across all tables
   timebounds = cellmap(@timespan, tbls);
   timebounds = cellflatten(timebounds, 1);

   switch kwargs.newTimeBasis
      case 'union'
         % Return the union (full time span from earliest start to latest end time)
         timerange = [min(timebounds(:, 1)), max(timebounds(:, 2))];
         Time = (timerange(1):kwargs.dt:timerange(2))';

      case 'intersection'
         % Return only the intersection (minimum overlapping time range)
         timerange = [max(timebounds(:, 1)), min(timebounds(:, 2))];
         Time = (timerange(1):kwargs.dt:timerange(2))';

      case 'commonrange'
         % Union of the row times, but over the intersection of the time ranges
         timerange = [max(timebounds(:, 1)), min(timebounds(:, 2))];
         Time = unique(cellflatten(cellmap(@(tbl) tbl.Time, tbls), 1));
         Time = Time(isbetween(Time, timerange(1), timerange(2)));

      case 'first'
         % Use row times from the first input timetable
         Time = tbls{1}.Time;

      case 'last'
         % Use row times from the last input timetable
         Time = tbls{end}.Time;

      otherwise
         error("Invalid value for 'newTimeBasis'. Supported values are " + ...
            "'union', 'intersection', 'commonrange', 'first', or 'last'.");
   end

   % % This may work but if the input tables have a timestep which is
   % % significantly different than the default dt=caldays(1), then it seems
   % % problematic.
   %
   % % If newTimeStep is specified, create a reference timetable with the desired
   % % time span and then retime to the desired newTimeStep.
   % if kwargs.newTimeStep ~= "unspecified"
   %    refTimeTable = timetable(Time);
   %    refTimeTable = retime(refTimeTable, kwargs.newTimeStep, 'fillwithmissing');
   %    Time = refTimeTable.Time;
   % end
end
