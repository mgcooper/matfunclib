function T = interptimetable(T,newtime,method,varargin)

   % make sure the Time dimension in named Time
   T           = renametimetabletimevar(T);
   
   % I was going to use oldtime and then 'withinrange' or 'isbetween' to
   % determine which new times aren't in the old times and fill the
   % non-numeric values with nan but using 'nearest' interpolation works
   
 % oldtime     =  T.Time;
   inumeric    =  cellfun(@isnumeric,table2cell(T(1,:)));
   data        =  T(:,inumeric);
   notdata     =  T(:,~inumeric);
   
   
   if isdatetime(newtime) && numel(newtime) == height(T)
      
      % interpolate the numeric data
      data     =  retime(data,newtime,method);
      
      % interpolate the non-numeric data
      notdata  =  retime(notdata,newtime,'nearest');
      
   elseif isduration(newtime) && isscalar(newtime)
   
      % interpolate the numeric data
      data     =  retime(data,'regular',method,'TimeStep',newtime);

      % interpolate the non-numeric data
      notdata  =  retime(notdata,'regular','nearest','TimeStep',newtime);
         
   end
   
   % combine them into a new table
   T  =  synchronize(data,notdata);

end