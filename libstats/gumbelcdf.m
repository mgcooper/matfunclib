function cdf = gumbelcdf(x, location, scale)

   cdf = exp(-exp((location-x) ./ scale));
   
   % y_gumbel = 1-cdf(pd_gumbel, -x_values);
end
