function M = estimatemode(data, plotfig)
   %ESTIMATEMODE Estimates the mode of a dataset using kernel density estimation
   %
   % Inputs:
   %   data - a vector of data points
   %
   % Outputs:
   %   mode_est - estimated mode of the dataset
   %
   % Note: This function should work OK for unimodal data, but no checks are
   % made for multimodal data.

   if nargin < 2
      plotfig = false;
   end
   
   % Remove any NaN values which can interfere with the density estimation
   data = data(~isnan(data));

   % Choose the number of points for the density estimation
   N = 1000;

   % Generate a range of values over which to estimate the density
   x = linspace(min(data), max(data), N);

   % Use the kernel density estimation on the data
   [pdf, x] = ksdensity(data, x);

   % Find the maximum of the estimated density
   [~, imax] = max(pdf);

   % The x value corresponding to the maximum density is the mode
   M = x(imax);
   
   if plotfig
      figure
      plot(x, pdf); hold on
      vertline(M)
      xlabel('x')
      ylabel('kernel density')
   end
end
