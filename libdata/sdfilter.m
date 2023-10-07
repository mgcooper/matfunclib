function [x, mu, sigma] = sdfilter(x, tolerance, passes)
   %SDFILTER Recursive standard deviation filter.
   %
   %  [x, mu, sigma] = sdfilter(x, tolerance, passes)
   %
   % See also:

   x = x(:);
   N = length(x);

   [mu, sigma] = deal(nan(passes, 1));

   for m = 1:passes
      mu(m) = nanmean(x);
      sigma(m) = nanstd(x);
      tol = repmat(tolerance*sigma(m), N, 1);
      outliers = abs(x-mu(m)) > tol;
      x(outliers) = nan;
   end
end
