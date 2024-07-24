function tbl = interptimetable(tbl, newtime, method, varargin)
   %INTERPTIMETABLE Interpolate timetable to a new timestep.
   %
   % tbl = interptimetable(tbl, newtime, method) retimes table T to new time
   % step NEWTIME using interpolation method METHOD.
   %
   % See also: synchronize, retime

   % Ensure the Time dimension is named Time
   tbl = renametimetabletimevar(tbl);

   % I was going to use oldtime and then 'withinrange' or 'isbetween' to
   % determine which new times aren't in the old times and fill the
   % non-numeric values with nan but using 'nearest' interpolation works

   % oldtime = T.Time;
   inum = cellfun(@isnumeric,table2cell(tbl(1,:)));
   data = tbl(:,inum);
   notdata = tbl(:,~inum);

   if isdatetime(newtime) && numel(newtime) == height(tbl)

      % interpolate the numeric data
      data = retime(data,newtime,method);

      % interpolate the non-numeric data
      notdata = retime(notdata,newtime,'nearest');

   elseif isduration(newtime) && isscalar(newtime)

      % interpolate the numeric data
      data = retime(data,'regular',method,'TimeStep',newtime);

      % interpolate the non-numeric data
      notdata = retime(notdata,'regular','nearest','TimeStep',newtime);

   end

   % combine them into a new table
   tbl = synchronize(data,notdata);
end
