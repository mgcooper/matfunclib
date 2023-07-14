function [ variance,data_monthly ] = tsvar( data,time,scale1,scale2 )
%TSVAR compute the variance of data on specified timescale

% INPUTS:
%       'DATA' = a mxn matrix of daily timeseries data.
%       'TIME' = a mx3 matrix. Columns 1:3 must be, in order, YYYY MM DD.
%       These columns are used to aggregate the data to
%       the appropriate scale, as specified by 'SCALE'.
%
% OUTPUTS:
%       'VARIANCE' = a 1xn matrix of the variance on the scale specified
%
% OPTIONS:
%       'SCALE1' = the initial aggregation of the data to a coarser scale.
%       For example you might want to aggregate the data to monthly, then
%       get the daily variance in each month, so you would set SCALE2 to
%       'daily'. Or you might want to aggregate to monthly, then get the
%       monthly variance.
%       'daily', 'weekly', 'monthly', 'annual'
%       'SCALE2' = explained above.
%       'daily', 'weekly', 'monthly', 'annual'
%
% WORKAROUND
%       If you want the daily variance on a month by month basis, feed in
%       data that starts out as moj

%% Start code

startyr = time(1,1);
startmm = time(1,2);
startdd = time(1,3);

endyr = time(end,1);
endmm = time(end,2);
enddd = time(end,3);

numdays = length(time);
numyears = endyr - startyr;
[a,b] = size(data);


% if scale1 == 'daily';
%     variance = nanvar(data);
% end

if strcmp(scale1,'monthly') == strcmp(scale2,'daily');
   for n = 1:b;
      for m = 1:numyears;
         year = m + startyr - 1;
         for j = 1:12;
            ind = find(time(:,1) == year & time(:,2) == j);
            data_monthly = data(ind,n);
            variance(m,j,n) = nanstd(data_monthly)/nanmean(data_monthly);

         end
      end
   end
end

