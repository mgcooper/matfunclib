function [x_fit, pdf_fits, cdf_fits] = fitFloodFrequency(annual_peaks, x_fit, kwargs)
   % fitFloodFrequency Fits specified distributions to annual peak data.
   %
   % Inputs:
   %   annual_peaks  - Data vector of annual peak discharges.
   %   x_fit         - (optional) Vector of x values to evaluate the PDFs and
   %                   CDFs (optional). If not provided, it will be generated
   %                   based on annual_peaks.
   %   Distributions - (name-value) Cell array or string array of distribution
   %                   names to fit. Default: {'Normal', 'Lognormal', 'Gumbel',
   %                   'LogPearsonIII'}
   %
   % Outputs:
   %   x_fit         - Vector of x values used for evaluating the distributions.
   %   pdf_fits      - Struct containing PDFs for each distribution.
   %   cdf_fits      - Struct containing CDFs for each distribution.

   arguments
      annual_peaks (:, 1) double
      x_fit (1, :) double = []
      kwargs.Distributions (:, 1) string = ["Normal", "Lognormal", "Gumbel", "LogPearsonIII"]
   end
   dists = kwargs.Distributions;

   % Define default x_values if not provided
   if isempty(x_fit)
      x_fit = dataspace(annual_peaks, 1000);
   else
      x_fit = unique(x_fit);
   end

   % Initialize structs to store PDFs and CDFs
   pdf_fits = struct();
   cdf_fits = struct();

   % Loop over each requested distribution
   for n = 1:numel(dists)

      switch dists(n)
         case 'Gumbel'
            % Fit Gumbel distribution (ExtremeValue for minima, hence negative values)
            pd_gumbel = fitdist(-annual_peaks, 'ExtremeValue');
            pdf_fits.Gumbel = pdf(pd_gumbel, -x_fit);
            cdf_fits.Gumbel = 1 - cdf(pd_gumbel, -x_fit);

         case 'LogPearsonIII'
            % Fit Log-Pearson Type III distribution (special case)
            [pdf_lp3, cdf_lp3] = lp3fit(annual_peaks, x_fit);
            pdf_fits.LogPearsonIII = pdf_lp3;
            cdf_fits.LogPearsonIII = cdf_lp3;

         otherwise
            % Fit standard distributions using MATLAB's fitdist function
            pd = fitdist(annual_peaks, dists(n));
            pdf_fits.(dists(n)) = pdf(pd, x_fit);
            cdf_fits.(dists(n)) = cdf(pd, x_fit);
      end
   end
end
