function x_fit = dataspace(data, N, pad)

   arguments
      data
      N = 1000
      pad = 10
   end
   pad = pad / 100;

   % Define x_values for plotting fitted distributions
   x_min = max(min(data) - abs(min(data) * pad), pad);
   x_max = max(data) * (1 + pad);
   x_fit = linspace(x_min, x_max, N);
end
