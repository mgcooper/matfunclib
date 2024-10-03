function q = invquantile(data, value)

   % Compute the empirical CDF
   [f, x] = ecdf(unique(data));

   % Remove duplicate values in x
   [x, ia] = unique(x);
   f = f(ia);

   % Interpolate to find the quantile corresponding to the given value
   q = interp1(x, f, value, 'linear', 'extrap');


   % % Ensure the data is sorted
   % x = unique(sort(data));
   %
   % % Calculate the empirical cumulative distribution values
   % f = linspace(0, 1, length(x));
   %
   % % Use interpolation to find the quantile corresponding to the given value
   % q = interp1(x, f, value, 'linear', 'extrap');
end
