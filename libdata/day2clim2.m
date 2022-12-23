function [ clim_data ] = day2clim2( daily_data,t )
%DAY2CLIM converts timeseries of daily data to long term averages i.e.
%climatology
%   Inputs:
%           'daily_data' a single column timeseries of daily data
%
%           't' a date/time matrix as produced by time_builder so
%           that column 1 is yyyy, column 2 is mm, column 3 is dd, column 4
%           and 5 don't matter, column 6 is doy
%
%           'scale' is 'daily' for daily climatology or 'monthly'
%
%           'option' is 'wy' to reshape the outputs for 10/1 - 9/30

[a,b,c] = size(daily_data);
if mod(a/365,1) ~= 0;
   disp('warning: no-leap calendar detected, removing all February 29 data');
   daily_data = rmleapinds(daily_data,t);
end
[a,b,c] = size(daily_data);
numyears = a/365;

% if strcmp('option','daily') == 1

data = reshape(daily_data,365,numyears,b,c);

clim_data = mean(data,2,'omitnan');

if ndims(clim_data) > 2
   clim_data = squeeze(clim_data);
end

% elseif strcmp('option','monthly') == 1
%
%     jan = daily_data(1:31,:);
%     feb = daily_data(32:59,:);
%     mar = daily_data(60:90,:);
%     apr = daily_data(91:120,:);
%     may = daily_data(121:151,:);
%     jun = daily_data(152:181,:);
%     jul = daily_data(182:212,:);
%     aug = daily_data(213:243,:);
%     sep = daily_data(244:273,:);
%     oct = daily_data(274:304,:);
%     nov = daily_data(305:334,:);
%     dec = daily_data(335:365,:);


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

