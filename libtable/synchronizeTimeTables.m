function tbls = synchronizeTimeTables(tbls, kwargs)
   %SYNCHRONIZETIMETABLES Synchronize multiple timetables to a common time grid.
   %
   %    tbls = synchronizeTimeTables(tbls)
   %
   %  Description
   %
   %    This function synchronizes the timetables provided in `tbls` to a common
   %    time grid, specified by `kwargs.newTimes` or derived from the data.
   %    Extrapolation is avoided by ensuring retime operations only fill within
   %    the original data range.
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
   % See also: retime synchronize

   arguments(Input,Repeating)
      tbls timetable {mustBeNonempty}
   end

   arguments(Input)
      kwargs.dt (1, 1) = caldays(1)
      kwargs.newTimes (:, 1) datetime = NaT
      kwargs.newTimeStep (1, 1) string {mustBeMember(kwargs.newTimeStep, ...
         {'yearly', 'quarterly', 'monthly', 'weekly', 'daily', 'hourly', ...
         'minutely', 'secondly', 'unspecified'})} = "unspecified"
      kwargs.newTimeBasis (1, 1) string {mustBeMember(kwargs.newTimeBasis, ...
         {'union', 'intersection', 'commonrange', 'first', 'last'})} = "union"
      kwargs.method (1, :) string = "fillwithmissing"
      kwargs.referenceTableIndex {mustBeScalarOrEmpty} = []
      kwargs.jointables (1, 1) logical = true
      kwargs.stacktables (1, 1) logical = false
   end
   kwargs.jointables = kwargs.jointables && ~kwargs.stacktables;

   % Determine the new common time grid.
   newTimes = parseNewTimes(tbls, kwargs);

   % Synchronize each timetable to the new common time grid.
   for n = numel(tbls):-1:1

      % Retime within the original bounds, fill with missing outside.
      drop = newTimes < min(tbls{n}.Time) | max(tbls{n}.Time) < newTimes;
      tbls{n} = retime(tbls{n}, newTimes, kwargs.method);
      tbls{n}{drop, :} = NaN;

      % If a new time step is specified, adjust the timetable further
      if kwargs.newTimeStep ~= "unspecified"
         tbls{n} = retime(tbls{n}, kwargs.newTimeStep, kwargs.method);
      end
   end

   % Horizontally concatenate or stack the synchronized tables
   if kwargs.jointables
      tbls = [tbls{:}];
   elseif kwargs.stacktables
      tbls = stacktables(tbls{:});
   end
end

function newTimes = parseNewTimes(tbls, kwargs)

   % Ensure that either dt or newTimeStep is used, but not both
   if kwargs.newTimeStep ~= "unspecified" && kwargs.dt ~= caldays(1)
      error("Specify either 'dt' or 'newTimeStep', but not both.");
   end

   % Determine the new common time grid
   newTimes = kwargs.newTimes;
   if isnat(newTimes)
      if ~isempty(kwargs.referenceTableIndex)
         idx = kwargs.referenceTableIndex;
         newTimes = tbls{idx}.(tbls{idx}.Properties.DimensionNames{1});
      else
         % Determine the common time span across timetables
         newTimes = synchronizeCalendars(tbls{:}, 'dt', kwargs.dt, ...
            'newTimeBasis', kwargs.newTimeBasis);
      end
   end
end
