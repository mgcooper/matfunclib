function [ dataFiltered,pct_filtered,indices ] = monthlyStdFilter( data, t, ...
      timestep, N_deviations, M_passes, tolerance)
   %MONTHLYSTDFILTER Filter out data beyond N standard deviations. 
   % 
   % Performs M repeat passes to correct for the sensitivity of the stdv to
   % outliers. Data must be in no-leap calendar format. Computes the standard
   % deviation across the provided timestep - 1 for daily, 2 for monthly, 3 for
   % yearly.
   %
   % See also:

   [rows, cols] = size(data); %#ok<*ASGLU>

   tolerance = N_deviations;

   if cols > rows
      data = data';
      disp('time should be in the column direction - transposing input');
   end

   dataFiltered = data;
   numNanBefore = sum(isnan(data),1);

   switch timestep
      case 1
         t_ind = 1;  % daily
         for i = 1:M_passes
            for n = 1:cols
               for m = 1:timestep

                  inds = find(t(:,2) == m);
                  mu(n,m) = nanmean(data(inds,n));
                  sigma(n,m) = nanstd(data(inds,n));

                  tol = repmat(tolerance*sigma(n,m),length(inds),1);
                  outliers{n,m} = find(abs(data(inds,n) - mu(n,m)) > tol); %#ok<*AGROW
                  
                  % but the outliers indices are in reference to the length of group
                  % of monthly values, not the original timeseries
                  outliers{n,m} = inds(outliers{n, m});
                  dataFiltered(outliers{n,m}(:), n) = NaN;
               end
            end
            num_nan_after = sum(isnan(dataFiltered),1);
            pct_filtered = 100.*(num_nan_after - numNanBefore)./(rows*cols);
            indices = outliers';
         end
   end
end