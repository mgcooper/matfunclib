function [ clim_data ] = day2clim( daily_data, time_matrix, scale, option  )
%DAY2CLIM converts timeseries of daily data to long term averages i.e.
%climatology
% 
%  [ clim_data ] = day2clim( daily_data, time_matrix, scale, option)
% 
%   Inputs:
%           'daily_data' a single column timeseries of daily data
%
%           'time_matrix' a date/time matrix as produced by time_builder so
%           that column 1 is yyyy, column 2 is mm, column 3 is dd, column 4
%           and 5 don't matter, column 6 is doy
%
%           'scale' is 'daily' for daily climatology or 'monthly'
%
%           'option' is 'wy' to reshape the outputs for 10/1 - 9/30

numyears = endyear - startyear + 1;
data = reshape(daily_data,365,numyears);
clim_data = mean(data,2);

% a = find(time_matrix(:,2) == 2 & time_matrix(:,3) == 29);
% Tclim = T1;
% Tclim(a,:) = [];
% 
% if length(daily_data) == 366;
%     daily_data = [daily_data(1:151);daily_data(153:end)];
% end
% 
% 
% 
% if strcmp(scale,'daily') == 1
%     for n = 1:365;
%         ind = find(time_matrix(:,6) == n);
%         data = daily_data(ind);
%         data = nanmean(data);
%         clim_data(n,1) = data;
%     end
% elseif strcmp(scale,'monthly') == 1
%     for n = 1:12;
%         ind = find(time_matrix(:,2) == n);
%         data = daily_data(ind);
%         data = nanmean(data);
%         clim_data(n,1) = data;
%     end
% end
% 
% if strcmp(option,'wy') == 1
%     clim_data_temp(1:92,1) = clim_data(274:365,1);
%     clim_data_temp(93:365,1) = clim_data(1:273,1);
%     clim_data = clim_data_temp;
% end
% 
% end

