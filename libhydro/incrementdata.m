function [ inc_data ] = cum2inc( cumul_data )
%CUM2INC Convert cumulative timeseries data to incremental. designed to
%work with cumulative rainfall data.
%
%  inc_data = cum2inc(cumul_data)
%
%   Inputs:
%           cumul_data: an mxn array of timeseries of cumulative data. m
%           must be the time axis.
%   Outputs:
%           inc_data: an mxn array of timeseries of incremental data
%
%   Notes:
%           the function simply subtracts the previous day cumulative value
%           from the current day, and assumes the difference is the
%           incremental increase. It then checks for negative values to
%           handle the case where the cumulative data resets at, e.g., the
%           beginning of a new year, and sets the negative value to either
%           0 in the case of no increase on that day, or to the value on
%           that day.

disp('Make sure the time axis is in the m direction. Press any key to continue')
pause

[a,b] = size(cumul_data);
inc_data(1,:) = 0;
for n = 1:a-1;
   for m = 1:b;
      inc_data(n+1,b) = cumul_data(n+1,b) - cumul_data(n,b);
   end
end

bi = find(inc_data < 0);

if cumul_data(bi) == 0;
   inc_data(bi) = 0;
else
   inc_data(bi) = cumul_data(bi);
end

