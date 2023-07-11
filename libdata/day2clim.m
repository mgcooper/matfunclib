function AnnualAverage = day2clim( DailyData, Time, TimeScale, CalendarType  )
%DAY2CLIM convert daily timeseries to long term averages i.e. climatology
% 
%  AnnualAverage = day2clim(DailyData, Time, TimeScale, CalendarType)
% 
% Inputs
%
% 'DailyData' a single column timeseries of daily data
% 
% 'Time' a date/time matrix as produced by time_builder so
% that column 1 is yyyy, column 2 is mm, column 3 is dd, column 4
% and 5 don't matter, column 6 is doy
% 
% 'TimeScale' is 'daily' for daily climatology or 'monthly'
% 
% 'CalendarType' is 'wy' to reshape the outputs for 10/1 - 9/30
% 
% See also
% 
% Note: this is an old pre-datetime function. Not recommended.

% % Simplify to:
% numyears = endyear - startyear + 1;
% data = reshape(DailyData,365,numyears);
% AnnualAverage = mean(data,2);

[a,b,c] = size(DailyData);
if mod(a/365,1) ~= 0
   disp('warning: no-leap calendar detected, removing all February 29 data');
   DailyData = rmleapinds(DailyData,Time);
end
[a,b,c] = size(DailyData);
numyears = a/365;

% if strcmp('option','daily') == 1

data = reshape(DailyData,365,numyears,b,c);

AnnualAverage = mean(data,2,'omitnan');

if ndims(AnnualAverage) > 2
   AnnualAverage = squeeze(AnnualAverage);
end

% elseif strcmp('option','monthly') == 1
%
%     jan = DailyData(1:31,:);
%     feb = DailyData(32:59,:);
%     mar = DailyData(60:90,:);
%     apr = DailyData(91:120,:);
%     may = DailyData(121:151,:);
%     jun = DailyData(152:181,:);
%     jul = DailyData(182:212,:);
%     aug = DailyData(213:243,:);
%     sep = DailyData(244:273,:);
%     oct = DailyData(274:304,:);
%     nov = DailyData(305:334,:);
%     dec = DailyData(335:365,:);


% a = find(Time(:,2) == 2 & Time(:,3) == 29);
% Tclim = T1;
% Tclim(a,:) = [];
% 
% if length(DailyData) == 366;
%     DailyData = [DailyData(1:151);DailyData(153:end)];
% end
% 
% 
% 
% if strcmp(TimeScale,'daily') == 1
%     for n = 1:365;
%         ind = find(Time(:,6) == n);
%         data = DailyData(ind);
%         data = nanmean(data);
%         AnnualAverage(n,1) = data;
%     end
% elseif strcmp(TimeScale,'monthly') == 1
%     for n = 1:12;
%         ind = find(Time(:,2) == n);
%         data = DailyData(ind);
%         data = nanmean(data);
%         AnnualAverage(n,1) = data;
%     end
% end
% 
% if strcmp(CalendarType,'wy') == 1
%     clim_data_temp(1:92,1) = AnnualAverage(274:365,1);
%     clim_data_temp(93:365,1) = AnnualAverage(1:273,1);
%     AnnualAverage = clim_data_temp;
% end
% 
% end

