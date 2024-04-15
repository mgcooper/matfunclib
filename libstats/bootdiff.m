function results = bootdiff(data, nboot, alpha, ndraws)
   % BOOTDIFF Compare bootstrap medians of multiple datasets.
   %
   %   RESULTS = BOOTDIFF(DATA) performs a bootstrap comparison of all datasets
   %   against the first dataset. DATA is a cell array of numeric arrays.
   %   Default number of bootstrap samples is 10,000 and a 95% confidence level
   %   is used.
   %
   %   RESULTS = BOOTDIFF(DATA, NBOOT) specifies the number of bootstrap
   %   samples.
   %
   %   RESULTS = BOOTDIFF(DATA, NBOOT, ALPHA) specifies the significance level
   %   for confidence intervals. ALPHA is between 0 and 1. E.g., 0.05 for 95%
   %   CIs.
   %
   %   RESULTS = BOOTDIFF(DATA, NBOOT, ALPHA, NDRAWS) specifies either a single
   %   scalar or a vector of numbers of samples to draw in each bootstrap
   %   iteration.
   %
   %   Outputs: - RESULTS is a structure with fields:
   %       * boot_medians: bootstrapped medians for each dataset.
   %       * median_diff: difference in medians compared to the first dataset.
   %       * CI_lower: lower bound of the confidence interval for each
   %       difference.
   %       * CI_upper: upper bound of the confidence interval for each
   %       difference.
   %       * significant_diff: boolean array indicating if the difference is
   %       significant.
   %
   % See also: bootci

   if ~iscell(data)
      data = {data};
   end
   if nargin < 2 || isempty(nboot)
      nboot = 10000;
   end
   if nargin < 3 || isempty(alpha)
      alpha = 0.05; % default 95% confidence level
   end

   % Generate an array of sample sizes.
   nsamples = cellfun(@numel, data);
   if nargin < 4 || isempty(ndraws)
      ndraws = [ones(numel(data), 1) nsamples(:)];
   else
      if numel(ndraws) == 1
         ndraws = [ones(numel(data), 1) ndraws.*ones(numel(data), 1)];
      else
         assert(numel(ndraws) == numel(data), ...
            'Specify one value of ndraws per dataset')
         ndraws = [ones(numel(data), 1) ndraws(:)];
      end
   end

   % Get bootstrap medians
   boot_medians = zeros(nboot, numel(data));
   for m = 1:numel(data)
      for n = 1:nboot
         boot_medians(n, m) = median( data{m}(randi(nsamples(m), ndraws(m, :))) );
      end
   end

   % Preallocate outputs
   median_diff = zeros(1, numel(data) - 1);
   CI_lower = zeros(1, numel(data) - 1);
   CI_upper = zeros(1, numel(data) - 1);

   % Compare all datasets to the first one
   for m = 1:numel(data) - 1
      diff_medians = abs(boot_medians(:,1) - boot_medians(:,m+1));
      %diff_medians = boot_medians(:,m+1) - boot_medians(:,1);
      median_diff(m) = median(diff_medians);

      % Confidence interval
      CI_lower(m) = quantile(diff_medians, alpha/2);
      CI_upper(m) = quantile(diff_medians, 1 - alpha/2);
   end

   % Package output
   results.boot_medians = boot_medians;
   results.median_diff = median_diff;
   results.CI_lower = CI_lower;
   results.CI_upper = CI_upper;

   % Check if difference is significant based on CI not including zero
   results.h_bootdiff = (CI_lower > 0 & CI_upper > 0) | ...
      (CI_lower < 0 & CI_upper < 0);
end

%    stat = arrayfun(@median(fcs1(randi(length(fcs1), [1 ndraws])));
%    minmax(stat1.') minmax(stat2.')

% Npte: numBootstrap = 1000; bootstrapMeans = zeros(numBootstrap, 1); for i =
% 1:numBootstrap
%     sample = datasample(dP, length(dP)); bootstrapMeans(i) = mean(sample);
% end % Compute confidence intervals, etc. These should match "results"
% median(bootstrapMeans) [bootresult.CI_lower quantile(bootstrapMeans, 0.05/2)]
% [bootresult.CI_upper quantile(bootstrapMeans, 1 - 0.05/2)]
