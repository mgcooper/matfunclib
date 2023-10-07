function [newdata, newtime, timeidx] = fillmissingdates(data, time, dt)
   %FILLMISSINGDATES Fill missing values of regular timeseries with nan
   % 
   % Finds missing dates in a timeseries of 'data' given a vector 'time' of
   % matlab formatted datenums and returns the filled data and indices 'inds' of
   % missing data 
   %
   % See also: padtimeseries, trimtimeseries

   if nargin < 3
      dt = time(2) - time(1);
   end
   
   % Make sure the dates are datenums (could be a vector of years)
   time = datenum(time); %#ok<*DATNM> 

   % Find the indexes of the times
   timeidx = round((time-time(1))/dt) + 1;

   % Generate the new data and time vectors
   newtime = (time(1):dt:time(end))';
   newdata = NaN(length(newtime),1);

   % Insert the non NaN data into the new vector
   newdata(timeidx) = data;
end
