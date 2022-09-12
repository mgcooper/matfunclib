function [ mo_avg ] = monthlyAvg( daily_data, option1, option2 )
%MONTHLYAVG takes a year of daily data and averages it to monthly
%   Detailed explanation goes here


[a,b,c] = size(daily_data);
if strcmp(option1,'average') == 1
        
    if a == 365 && c == 1

        jan = daily_data(1:31,:);
        feb = daily_data(32:59,:);
        mar = daily_data(60:90,:);
        apr = daily_data(91:120,:);
        may = daily_data(121:151,:);
        jun = daily_data(152:181,:);
        jul = daily_data(182:212,:);
        aug = daily_data(213:243,:);
        sep = daily_data(244:273,:);
        oct = daily_data(274:304,:);
        nov = daily_data(305:334,:);
        dec = daily_data(335:365,:);


        mo_avg(1) = squeeze(nanmean(jan,1));
        mo_avg(2) = squeeze(nanmean(feb,1));
        mo_avg(3) = squeeze(nanmean(mar,1));
        mo_avg(4) = squeeze(nanmean(apr,1));
        mo_avg(5) = squeeze(nanmean(may,1));
        mo_avg(6) = squeeze(nanmean(jun,1));
        mo_avg(7) = squeeze(nanmean(jul,1));
        mo_avg(8) = squeeze(nanmean(aug,1));
        mo_avg(9) = squeeze(nanmean(sep,1));
        mo_avg(10) = squeeze(nanmean(oct,1));
        mo_avg(11) = squeeze(nanmean(nov,1));
        mo_avg(12) = squeeze(nanmean(dec,1));


    elseif b == 365 && c == 1

        jan = daily_data(:,1:31);
        feb = daily_data(:,32:59);
        mar = daily_data(:,60:90);
        apr = daily_data(:,91:120);
        may = daily_data(:,121:151);
        jun = daily_data(:,152:181);
        jul = daily_data(:,182:212);
        aug = daily_data(:,213:243);
        sep = daily_data(:,244:273);
        oct = daily_data(:,274:304);
        nov = daily_data(:,305:334);
        dec = daily_data(:,335:365);

        mo_avg(1) = squeeze(nanmean(jan,2));
        mo_avg(2) = squeeze(nanmean(feb,2));
        mo_avg(3) = squeeze(nanmean(mar,2));
        mo_avg(4) = squeeze(nanmean(apr,2));
        mo_avg(5) = squeeze(nanmean(may,2));
        mo_avg(6) = squeeze(nanmean(jun,2));
        mo_avg(7) = squeeze(nanmean(jul,2));
        mo_avg(8) = squeeze(nanmean(aug,2));
        mo_avg(9) = squeeze(nanmean(sep,2));
        mo_avg(10) = squeeze(nanmean(oct,2));
        mo_avg(11) = squeeze(nanmean(nov,2));
        mo_avg(12) = squeeze(nanmean(dec,2));

    elseif a == 365 && c ~= 1

        jan = daily_data(1:31,:,:);
        feb = daily_data(32:59,:,:);
        mar = daily_data(60:90,:,:);
        apr = daily_data(91:120,:,:);
        may = daily_data(121:151,:,:);
        jun = daily_data(152:181,:,:);
        jul = daily_data(182:212,:,:);
        aug = daily_data(213:243,:,:);
        sep = daily_data(244:273,:,:);
        oct = daily_data(274:304,:,:);
        nov = daily_data(305:334,:,:);
        dec = daily_data(335:365,:,:);

        mo_avg(1) = squeeze(nanmean(jan,1));
        mo_avg(2) = squeeze(nanmean(feb,1));
        mo_avg(3) = squeeze(nanmean(mar,1));
        mo_avg(4) = squeeze(nanmean(apr,1));
        mo_avg(5) = squeeze(nanmean(may,1));
        mo_avg(6) = squeeze(nanmean(jun,1));
        mo_avg(7) = squeeze(nanmean(jul,1));
        mo_avg(8) = squeeze(nanmean(aug,1));
        mo_avg(9) = squeeze(nanmean(sep,1));
        mo_avg(10) = squeeze(nanmean(oct,1));
        mo_avg(11) = squeeze(nanmean(nov,1));
        mo_avg(12) = squeeze(nanmean(dec,1));

    elseif b == 365 && c ~= 1

        jan = daily_data(:,1:31,:);
        feb = daily_data(:,32:59,:);
        mar = daily_data(:,60:90,:);
        apr = daily_data(:,91:120,:);
        may = daily_data(:,121:151,:);
        jun = daily_data(:,152:181,:);
        jul = daily_data(:,182:212,:);
        aug = daily_data(:,213:243,:);
        sep = daily_data(:,244:273,:);
        oct = daily_data(:,274:304,:);
        nov = daily_data(:,305:334,:);
        dec = daily_data(:,335:365,:);

        mo_avg(1) = squeeze(nanmean(jan,2));
        mo_avg(2) = squeeze(nanmean(feb,2));
        mo_avg(3) = squeeze(nanmean(mar,2));
        mo_avg(4) = squeeze(nanmean(apr,2));
        mo_avg(5) = squeeze(nanmean(may,2));
        mo_avg(6) = squeeze(nanmean(jun,2));
        mo_avg(7) = squeeze(nanmean(jul,2));
        mo_avg(8) = squeeze(nanmean(aug,2));
        mo_avg(9) = squeeze(nanmean(sep,2));
        mo_avg(10) = squeeze(nanmean(oct,2));
        mo_avg(11) = squeeze(nanmean(nov,2));
        mo_avg(12) = squeeze(nanmean(dec,2));

    elseif c == 365

        jan = daily_data(:,:,1:31);
        feb = daily_data(:,:,32:59);
        mar = daily_data(:,:,60:90);
        apr = daily_data(:,:,91:120);
        may = daily_data(:,:,121:151);
        jun = daily_data(:,:,152:181);
        jul = daily_data(:,:,182:212);
        aug = daily_data(:,:,213:243);
        sep = daily_data(:,:,244:273);
        oct = daily_data(:,:,274:304);
        nov = daily_data(:,:,305:334);
        dec = daily_data(:,:,335:365);

        mo_avg(:,:,1) = nanmean(jan,3);
        mo_avg(:,:,2) = nanmean(feb,3);
        mo_avg(:,:,3) = nanmean(mar,3);
        mo_avg(:,:,4) = nanmean(apr,3);
        mo_avg(:,:,5) = nanmean(may,3);
        mo_avg(:,:,6) = nanmean(jun,3);
        mo_avg(:,:,7) = nanmean(jul,3);
        mo_avg(:,:,8) = nanmean(aug,3);
        mo_avg(:,:,9) = nanmean(sep,3);
        mo_avg(:,:,10) = nanmean(oct,3);
        mo_avg(:,:,11) = nanmean(nov,3);
        mo_avg(:,:,12) = nanmean(dec,3);
        
    end
    
elseif strcmp(option1,'sum') == 1
    
    if a == 365 && c == 1

        jan = daily_data(1:31,:);
        feb = daily_data(32:59,:);
        mar = daily_data(60:90,:);
        apr = daily_data(91:120,:);
        may = daily_data(121:151,:);
        jun = daily_data(152:181,:);
        jul = daily_data(182:212,:);
        aug = daily_data(213:243,:);
        sep = daily_data(244:273,:);
        oct = daily_data(274:304,:);
        nov = daily_data(305:334,:);
        dec = daily_data(335:365,:);


        mo_avg(1) = squeeze(nansum(jan,1));
        mo_avg(2) = squeeze(nansum(feb,1));
        mo_avg(3) = squeeze(nansum(mar,1));
        mo_avg(4) = squeeze(nansum(apr,1));
        mo_avg(5) = squeeze(nansum(may,1));
        mo_avg(6) = squeeze(nansum(jun,1));
        mo_avg(7) = squeeze(nansum(jul,1));
        mo_avg(8) = squeeze(nansum(aug,1));
        mo_avg(9) = squeeze(nansum(sep,1));
        mo_avg(10) = squeeze(nansum(oct,1));
        mo_avg(11) = squeeze(nansum(nov,1));
        mo_avg(12) = squeeze(nansum(dec,1));


    elseif b == 365 && c == 1

        jan = daily_data(:,1:31);
        feb = daily_data(:,32:59);
        mar = daily_data(:,60:90);
        apr = daily_data(:,91:120);
        may = daily_data(:,121:151);
        jun = daily_data(:,152:181);
        jul = daily_data(:,182:212);
        aug = daily_data(:,213:243);
        sep = daily_data(:,244:273);
        oct = daily_data(:,274:304);
        nov = daily_data(:,305:334);
        dec = daily_data(:,335:365);

        mo_avg(1) = squeeze(nansum(jan,2));
        mo_avg(2) = squeeze(nansum(feb,2));
        mo_avg(3) = squeeze(nansum(mar,2));
        mo_avg(4) = squeeze(nansum(apr,2));
        mo_avg(5) = squeeze(nansum(may,2));
        mo_avg(6) = squeeze(nansum(jun,2));
        mo_avg(7) = squeeze(nansum(jul,2));
        mo_avg(8) = squeeze(nansum(aug,2));
        mo_avg(9) = squeeze(nansum(sep,2));
        mo_avg(10) = squeeze(nansum(oct,2));
        mo_avg(11) = squeeze(nansum(nov,2));
        mo_avg(12) = squeeze(nansum(dec,2));

    elseif a == 365 && c ~= 1

        jan = daily_data(1:31,:,:);
        feb = daily_data(32:59,:,:);
        mar = daily_data(60:90,:,:);
        apr = daily_data(91:120,:,:);
        may = daily_data(121:151,:,:);
        jun = daily_data(152:181,:,:);
        jul = daily_data(182:212,:,:);
        aug = daily_data(213:243,:,:);
        sep = daily_data(244:273,:,:);
        oct = daily_data(274:304,:,:);
        nov = daily_data(305:334,:,:);
        dec = daily_data(335:365,:,:);

        mo_avg(1) = squeeze(nansum(jan,1));
        mo_avg(2) = squeeze(nansum(feb,1));
        mo_avg(3) = squeeze(nansum(mar,1));
        mo_avg(4) = squeeze(nansum(apr,1));
        mo_avg(5) = squeeze(nansum(may,1));
        mo_avg(6) = squeeze(nansum(jun,1));
        mo_avg(7) = squeeze(nansum(jul,1));
        mo_avg(8) = squeeze(nansum(aug,1));
        mo_avg(9) = squeeze(nansum(sep,1));
        mo_avg(10) = squeeze(nansum(oct,1));
        mo_avg(11) = squeeze(nansum(nov,1));
        mo_avg(12) = squeeze(nansum(dec,1));

    elseif b == 365 && c ~= 1

        jan = daily_data(:,1:31,:);
        feb = daily_data(:,32:59,:);
        mar = daily_data(:,60:90,:);
        apr = daily_data(:,91:120,:);
        may = daily_data(:,121:151,:);
        jun = daily_data(:,152:181,:);
        jul = daily_data(:,182:212,:);
        aug = daily_data(:,213:243,:);
        sep = daily_data(:,244:273,:);
        oct = daily_data(:,274:304,:);
        nov = daily_data(:,305:334,:);
        dec = daily_data(:,335:365,:);

        mo_avg(1) = squeeze(nansum(jan,2));
        mo_avg(2) = squeeze(nansum(feb,2));
        mo_avg(3) = squeeze(nansum(mar,2));
        mo_avg(4) = squeeze(nansum(apr,2));
        mo_avg(5) = squeeze(nansum(may,2));
        mo_avg(6) = squeeze(nansum(jun,2));
        mo_avg(7) = squeeze(nansum(jul,2));
        mo_avg(8) = squeeze(nansum(aug,2));
        mo_avg(9) = squeeze(nansum(sep,2));
        mo_avg(10) = squeeze(nansum(oct,2));
        mo_avg(11) = squeeze(nansum(nov,2));
        mo_avg(12) = squeeze(nansum(dec,2));

    elseif c == 365

        jan = daily_data(:,:,1:31);
        feb = daily_data(:,:,32:59);
        mar = daily_data(:,:,60:90);
        apr = daily_data(:,:,91:120);
        may = daily_data(:,:,121:151);
        jun = daily_data(:,:,152:181);
        jul = daily_data(:,:,182:212);
        aug = daily_data(:,:,213:243);
        sep = daily_data(:,:,244:273);
        oct = daily_data(:,:,274:304);
        nov = daily_data(:,:,305:334);
        dec = daily_data(:,:,335:365);

        mo_avg(:,:,1) = nansum(jan,3);
        mo_avg(:,:,2) = nansum(feb,3);
        mo_avg(:,:,3) = nansum(mar,3);
        mo_avg(:,:,4) = nansum(apr,3);
        mo_avg(:,:,5) = nansum(may,3);
        mo_avg(:,:,6) = nansum(jun,3);
        mo_avg(:,:,7) = nansum(jul,3);
        mo_avg(:,:,8) = nansum(aug,3);
        mo_avg(:,:,9) = nansum(sep,3);
        mo_avg(:,:,10) = nansum(oct,3);
        mo_avg(:,:,11) = nansum(nov,3);
        mo_avg(:,:,12) = nansum(dec,3);
        
    end
    
end

