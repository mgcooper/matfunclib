function [SE,CI,PM] = tconf(mu,sig,N,alpha)
   %TCONF Compute 1-alpha confidence intervals.
   %
   % [SE,CI,PM] = TCONF(MU,SIG,N,ALPHA) Returns 1-alpha confidence intervals
   % given mean mu, standard deviation sig, sample size N, and confidence level
   % alpha. No adjustment is made to N, so pass in N for a sample statistic such
   % as the mean of a sample, and N-1 if mu/sig are the mean/stdv of a sample of
   % regression coefficients (2-parameter model). alpha=.32 means 68% CI, alpha
   % = 0.05 means 95% CI. Default is 0.32, which correspond to an estimate of
   % the population standard deviation, the standard uncertainty.
   %
   % Output:
   %     SE: one standard error (stdv/sqrt(N))
   %     CI: upper and lower confidence intervals
   %     PM: the plus/minus i.e. CI-mu
   %
   %
   % See also: stderr

   % NOTE: this is not correct for regression coefficients. Not 100% sure
   % why I thought it was, but can compare with fitlm to see, by passing in
   % the regression coefficient and it's standard error from fitlm, the
   % CI's returned by this function will be much smaller than the ones
   % returned by mdl.coefCI. It might be a misunderstanding about the math,
   % recall I wrote this to compute the CI's on york regression, I think.
   % But how this CAN be used correctly is if we have a bootstrap sample of
   % regression coefficients, then I would pass in N-1 for sample size as
   % noted

   % note: t_c has N-1 dof, whereas the sample has N dof
   tc = tinv(1 - alpha / 2, N - 1);
   SE = sig ./ sqrt(N);
   % idx = N <= 30;
   % SE(idx) = SE(idx) .* tc(idx);

   % June 2020, define 'plus/minus' which is the value we normally want to
   % see / quote in the results:
   PM = tc .* SE;
   if isscalar(mu) || isvector(mu)
      CI = mu + PM .* [-1 1];
   elseif ismatrix(mu) && all(size(mu) > 1)
      PM = cat(3, PM .* -1 .* ones(size(SE)), PM .* ones(size(SE)));
      CI = mu + PM;
   end
end
