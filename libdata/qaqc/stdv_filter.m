function [dataFiltered, pctFiltered, indices] = stdvFilter(data, time, ...
      timestep, tolerance, passes, missingDataValue)
   % STDVFILTER filters out data beyond N standard deviations. 
   % 
   % Performs M repeat passes to correct for the sensitivity of the stdv to
   % outliers. Data will be returned in no-leap format. Computes the standard
   % deviation for the provided timestep - 1 for daily, 2 for monthly i.e. if
   % user provided daily, then the data is binned into each day of the year and
   % the statistics are computed on the bins. If provided, the no_data value is
   % set to nan.
   %
   % See also:

   [rows, cols] = size(data); %#ok<*ASGLU>

   if cols>rows
      data = data';
      disp('time should be in the column direction - transposing input');
   end

   dataFiltered = data;

   numNanStart = sum(isnan(dataFiltered), 1);

   % set the no-data values to nan
   noDataInds = data == missingDataValue;
   dataFiltered(noDataInds) = nan;

   switch timestep
      case 1
         timeidx = 6;  % daily
         timesteps = unique(time(:, timeidx));
      case 2
         timeidx = 2;  % monthly
         timesteps = unique(time(:, timeidx));
   end

   % check for leap years
   if timesteps == 366
      dataFiltered = rmleapinds(dataFiltered,time);
   end

   outliers = cell(length(timesteps), cols, passes);
   [mu, sigma] = deal(nan(length(timesteps), cols, passes));
   
   % update July 2020 = convert t to datetime object
   if ~isdatetime(time)
      time = datetime(time(:,7));

      for i = 1:passes
         for n = 1:cols
            for m = 1:length(timesteps)

               inds = find(time(:,timeidx) == m);
               mu(m,n,i) = nanmean(dataFiltered(inds,n));
               sigma(m,n,i) = nanstd(dataFiltered(inds,n));
               tol = repmat(tolerance*sigma(m,n,i),length(inds),1);
               outliers{m,n,i} = find(abs(dataFiltered(inds,n)-mu(m,n,i)) > tol);

               % but the outliers indices are in reference to the length of
               % group of monthly values, not the original timeseries
               outliers{m,n,i} = inds(outliers{n,m});
               dataFiltered(outliers{n,m,i}(:),n) = NaN;
            end
         end
      end
      num_nan_after = sum(isnan(dataFiltered),1);
      pctFiltered = 100.*(num_nan_after - numNanStart)./(rows*cols);
      indices = outliers';
   end
end
