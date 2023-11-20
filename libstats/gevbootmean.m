function [mu, CI] = gevbootmean(x, alpha, bootreps)

   % The GEV distribution mean is not directly given by a parameter in the
   % parametric form. You need to compute it from the parameters (k,sigma,mu)
   % The mean of GEV is given by: mu + sigma * (Gamma(1-k) - 1) / k, where
   % Gamma is the gamma function. This is valid for k < 1. For k >= 1, the
   % mean is infinite or undefined.

   debug = false;
   logtransform = false;

   if nargin < 2
      alpha = 5;
   end
   if nargin < 3
      bootreps = 1000; % Number of bootstrap repetitions
   end

   job = withwarnoff( ...
      {'stats:gevfit:IterLimit', ...
      'stats:gevfit:ConvergedToBoundary', ...
      'MATLAB:nearlySingularMatrix'});

   % Compute the empirical confidence interval from the bootstrap distribution
   params = bootstrp(bootreps, @gevfit, x);
   params = params(params(:, 1) < 1, :);
   [bootM, bootV] = gevstat(params(:, 1), params(:, 2), params(:, 3));
   mu = median(bootM(~isinf(bootM)));
   CI = prctile(bootM(~isinf(bootM)), [alpha/2 100-alpha/2], 'Method', 'approximate');
   
   truncate = CI(2) > prctile(x, 90);
   
   if truncate == true
      % Trim or winsorize a percentage of the largest values
      
      trimmedPercentage = 5;
      sortedBootM = sort(bootM);
   
      % Determine the number of elements to trim from each end
      trimNum = round(bootreps * trimmedPercentage / 100 / 2);
   
      % Trim the sorted array at both ends
      % trimmedBootM = sortedBootM((trimNum + 1):(end - trimNum));
      
      % Trim the sorted array at one end
      trimmedBootM = sortedBootM(1:(end - trimNum));
   
      % Compute the confidence intervals on the trimmed/winsorized distribution
      CI = prctile(trimmedBootM, [alpha/2, 100 - alpha/2], 'Method', 'approximate');
      mu = mean(trimmedBootM);
      % mu = trimmean(bootM, trimmedPercentage, 'round', 1);
   end
   
   if logtransform == true

      % Apply log transformation to reduce skewness
      logBootM = log(trimmedBootM);

      % Compute the confidence intervals in the log space
      logCI = prctile(logBootM, [alpha/2, 100 - alpha/2]);

      % Transform the confidence intervals back to the original scale
      CI = exp(logCI);
   end
   % variance:
   % v = mean(bootV(~isinf(bootV)));

   if debug == true
      sum(isinf(bootM))
      sum(isinf(bootV))

      % If the CI is extremely large, this will show that the bootM values are
      % heavily skewed
      figure; 
      histogram(trimmedBootM, 'NumBins', 30); hold on;
      histogram(bootM, 'NumBins', 30);
      
      figure;
      histogram(log(trimmedBootM), 'NumBins', 30); hold on;
      histogram(log(bootM), 'NumBins', 30)
      
      % Check if GEV is the best fit
      [D, PD] = allfitdist(x);
      GP = fitdist(x, 'GeneralizedPareto');
      EV = fitdist(x, 'GeneralizedExtremeValue');
      [GP.mean EV.mean]
      
      
      % Could use this to get the CIs of the distribution itself and use them
      % instead of CIs on the mean
      % low = prctile(pfit, 5);
      % upp = prctile(pfit, 95);
      
      % The problem with using mean(bootM(~isinf(bootM))) is the bootM sample might
      % be non-symmetrics.

      x = sort(x);
      pd = fitdist(x, 'GeneralizedExtremeValue');
      xfit = linspace(min(x), max(x), 1000);
      pfit = gevpdf(xfit, mean(params(:, 1)), mean(params(:, 2)), mean(params(:, 3)));
      
      figure
      histogram(x, 'Normalization', 'pdf', 'NumBins', 30); hold on;
      line(xfit, pfit, 'Color', 'red')

      vertline(pd.mean);
      vertline(mu);
      vertline(mean(x));
      vertline(CI(1), 'r--')
      vertline(CI(2), 'r--')
      legend('data', 'pdf', 'pd.mean', 'boot mean', 'mean(x)', 'CI')

      [pd.k mean(params(:, 1))]
      [pd.sigma mean(params(:, 2))]
      [pd.mu mean(params(:, 3))]
      [pd.mean mu mean(x)]
      
   end

end

function [mu, CI] = demoFunction(x, bootreps)

   % Explicit method:
   bootM = zeros(bootreps, 1);
   for n = 1:bootreps
      sample = randsample(x, length(x), true);
      pdBoot = fitdist(sample, 'GeneralizedExtremeValue');

      % Compute mean only if shape parameter k < 1
      if pdBoot.k < 1
         bootM(n) = Fmean(pdBoot.k, pdBoot.sigma, pdBoot.mu);
      else
         bootM(n) = Inf;
      end
   end

   % Remove Inf values which represent undefined means when k >= 1
   bootM = bootM(bootM < Inf);

   % Compute the mean
   mu = mean(bootM);

   % Compute the empirical confidence interval from the bootstrap distribution
   if ~isempty(bootM)
      CI = prctile(bootM, [alpha/2 100-alpha/2]);
   else
      CI = [Inf Inf];
   end
end


% % Define your custom function that fits GEV and computes the mean
% gevMeanFunc = @(data) computeGEVMean(data);
%
% % Compute the bootstrap confidence intervals using 'bootci'
% ci = bootci(1000, gevMeanFunc, x, 'type', 'normal');
%
% % This is the function you'll use with bootci
% function meanVal = computeGEVMean(data)
%     params = gevfit(data);
%     [~, meanVal] = gevstat(params(1), params(2), params(3));
%     meanVal = meanVal(~isinf(meanVal));
%     if isempty(meanVal)
%         meanVal = Inf; % If all means are Inf, return Inf
%     else
%         meanVal = mean(meanVal); % Compute the mean of non-Inf values
%     end
% end


% Function to compute the mean of a gev distribution
%    F = arrayfun( ...
%       @(params) gevstat(params(:, 1), params(:, 2), params(:, 3)), params);
%
%    ci = bootci(1000, ...
%       {@(params) gevstat(params(1),params(2),params(3)), x}, 'Type', 'normal')
% Fmean = @(k, sigma, mu) mu + sigma .* (gamma(1 - k) - 1) ./ k;


% Fstat = @(p) gevstat(p(p(:, 1) < 1, 1), p(p(:, 1) < 1, 2), p(p(:, 1) < 1, 3));
%    ci = bootci(1000, ...
%       {@(params) Fstat(params(1),params(2),params(3)), x}, 'Type', 'normal')
%
%    ci = bootci(1000, gevMeanFunc, x, 'type', 'normal');
