function tbl = synchronizeTimeTables(tbl, kwargs)
   %SYNCHRONIZETIMETABLES
   %
   %  tbl = synchronizeTimeTables(tbl, kwargs)
   %
   % NOTE: this was written quickly to sync some daily timetables
   % For daily data it should work in general if no kwargs are supplied, it
   % will find the min/max times of all tables and retime to a common
   % full period calendar. Similarly if just dt is supplied, it should work
   % with non-daily data.
   %
   % but to generalize it, need to add / inherit all the other retime options.

   arguments(Input,Repeating)
      tbl timetable
   end

   arguments(Input)
      kwargs.dt (1, 1) = caldays(1)
      kwargs.newTimes (:, 1) datetime = NaT
      kwargs.newTimeStep (1, 1) = "daily"
      kwargs.method (1, :) string = "fillwithmissing"
   end

   % Construct a common calendar (note: defaults to dt=caldays(1))
   newTimes = kwargs.newTimes;
   if isnat(newTimes)

      % Get the timebounds across all tables
      timebounds = cellmap(@timespan, tbl);
      timebounds = cellflatten(timebounds, 1);
      timebounds = [min(timebounds(:, 1)), max(timebounds(:, 2))];

      % Create a calendar of new times spanning the full range
      newTimes = timebounds(1):kwargs.dt:timebounds(2);
   end

   % Synchronize to a common timebounds
   for n = numel(tbl):-1:1
      tbl{n} = retime(tbl{n}, newTimes, kwargs.method);

      % tbl{n} = retime(tbl{n}, kwargs.newTimeStep, kwargs.method);
      % tbl{n} = retime(tbl{n}, "daily", "fillwithmissing");
   end

   % Horizontally concatenate
   tbl = [tbl{:}];
end
