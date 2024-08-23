function varargout = aggannualdata(Data, aggfunc, aggvars)
   %AGGANNUALDATA aggregate sub-annual timeseries to annual values
   %
   %    [values, indices, times] = aggannualdata(Data, aggfunc, aggvars)
   %
   % Description
   %
   %    [VALS, IDXS, TIMES] = AGGANNUALDATA(DATA, AGGFUNC, AGGVARS) aggregates
   %    columns of timetable DATA to annual values using aggregation function
   %    AGGFUNC and returns the aggregated values VALS, indices of the values
   %    IDXS, and datetimes TIMES.
   %
   %  Example
   %
   %    [vals, idxs, times] = aggannualdata(Data, 'min', 'Discharge') finds the
   %    minimum value of Data.Discharge each year and returns the minimum
   %    value, its index on the annual series, and the datetime of the annual
   %    min.
   %
   % See also:

   % NOTE: isbetween and year(datetime) are very slow, so I need a
   % faster way to index into the calendars for arbitrary timesteps

   arguments
      Data timetable
      aggfunc (1, :) char {mustBeMember(aggfunc, {'min','max'})}
      aggvars = Data.Properties.VariableNames
   end

   allyears = year(Data.(Data.Properties.DimensionNames{1}));
   uniqueyears = unique(allyears);

   vals = NaN(numel(uniqueyears), numel(aggvars));
   idxs = NaN(numel(uniqueyears), numel(aggvars));
   time = NaT(numel(uniqueyears), numel(aggvars));

   % test for speeding up the indexing
   % Dates = datenum(Data.Time);

   for n = 1:numel(uniqueyears)

      % don't do this - isbetween is very slow and inclusive of endpoints
      %idx = isbetween(Data.Time,datetime(nyear,1,1),datetime(nyear+1,1,1));

      % this fixes the endpoint inclusive issue but is even slower
      idx = allyears == uniqueyears(n);

      for m = 1:numel(aggvars)
         switch aggfunc
            case 'min'
               [idxs(n,m), vals(n,m)] = findglobalmin(Data.(aggvars{m})(idx));
            case 'max'
               [idxs(n,m), vals(n,m)] = findglobalmax(Data.(aggvars{m})(idx));
         end
         T = Data.Time(idx);
         time(n,m) = T(idxs(n,m));
      end
   end

   [varargout{1:nargout}] = dealout(vals, idxs, time);
end
%%

% for reference, here are two ways to get the annual max value and index,
% but I was not able to get the date wihtout resorting to the loops here. note
% that annualDates is actually the index of the annual max value, not the date

% % method 1) here annualDates is actually the index of the max value
% annualPeaks = retime(Q,'regular',@(x)max(x),'TimeStep',calyears(1));
% annualDates = retime(Q,'regular',@(x)find(x==max(x),1),'TimeStep',calyears(1));
% annualPeaks = annualPeaks.Q;
% annualDates = annualDates.Q;

% % method 2)
%
% imax=@(x) find(x==max(x),1); % anonymous function to find maximum in group
%
% Q.Date = Q.Time;
% Q.Year = year(Q.Time);
%
% test = varfun(imax,Q,'InputVariables',{'Q','Date'},'GroupingVariables','Year');
