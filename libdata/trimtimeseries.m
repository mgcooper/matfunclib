function [data_out,dates_out] = trimtimeseries(data,dates,trimstart,trimend)
   %TRIMTIMESERIES Trim timeseries from 1:trimstart and trimend:end
   %
   % [data_out,dates_out] = trimtimeseries(data,dates,trimstart,trimend)
   %
   % Inputs:
   % data - timeseries of monotonically increasing data
   % dates - vector of datenums corresponding to data
   % trimstart - date you want the trimmed data to start
   % trimend - date you want the trimmed data to end
   %
   % Outputs:
   % data_out - trimmed data
   % dates_out - trimmed dates
   %
   % See also: padtimeseries, fillmissingdates

   % first double check it is a datenum vector
   dates = datenum(dates); %#ok<*DATNM>
   trimstart = datenum(trimstart);
   trimend = datenum(trimend);

   % get the index on the data vector of the trimstart date
   if ~isempty(trimstart)
      indi = find(trimstart == dates);
      data(1:indi-1,:,:) = [];
      dates(1:indi-1,:,:) = [];
   end

   if ~isempty(trimend)
      indf = find(trimend == dates);
      data(indf+1:end,:,:) = [];
      dates(indf+1:end,:,:) = [];
   end
   data_out = data;
   dates_out = dates;
end
