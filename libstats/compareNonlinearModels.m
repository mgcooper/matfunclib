function [results, xfit, yfit, residuals] = compareNonlinearModels(x, y, f1, f2, b1, b2)
   %COMPARENONLINEARMODELS Fit and compare two nonlinear models.
   %
   %  RESULTS = COMPARENONLINEARMODELS(X, Y, F1, F2) fits the two model
   %  functions F1 and F2 to the paired data X and Y using FITNLM and returns
   %  a summary table of coefficients and model selection metrics.
   %
   %  [RESULTS, XFIT, YFIT, RESIDUALS] = COMPARENONLINEARMODELS(X, Y, F1, F2,
   %  B1, B2) also returns predicted values evaluated on a uniform grid XFIT
   %  and the raw residuals from each fitted model. B1 and B2 are the initial
   %  coefficient guesses passed to FITNLM for F1 and F2, respectively.
   %
   %  Inputs
   %
   %  X, Y - Paired predictor and response data vectors.
   %
   %  F1, F2 - Function handles defining the nonlinear model forms accepted by
   %  FITNLM.
   %
   %  B1, B2 - Initial coefficient guesses for F1 and F2. If omitted, both
   %  default to [1 1].
   %
   %  Outputs
   %
   %  RESULTS - Table containing the model names, fitted coefficients, R^2,
   %  AIC, and BIC for each model.
   %
   %  XFIT - Column vector of evenly spaced x values spanning the data range.
   %
   %  YFIT - Matrix of fitted response values evaluated at XFIT. Column 1
   %  corresponds to F1 and column 2 corresponds to F2.
   %
   %  RESIDUALS - Matrix of raw residuals for each fitted model.
   %
   %  See also fitnlm

   if nargin < 5
      b1 = [1 1];
      b2 = [1 1];
   end

   % Fit the first model
   m1 = fitnlm(x, y, f1, b1);

   % Fit the second model
   m2 = fitnlm(x, y, f2, b2);

   % Store the results
   results.f(1, 1) = string(func2str(f1));
   results.f(2, 1) = string(func2str(f2));
   results.b1(1, 1) = m1.Coefficients.Estimate(1);
   results.b1(2, 1) = m2.Coefficients.Estimate(1);
   results.b2(1, 1) = m1.Coefficients.Estimate(2);
   results.b2(2, 1) = m2.Coefficients.Estimate(2);
   results.rsq(1, 1) = m1.Rsquared.Ordinary;
   results.rsq(2, 1) = m2.Rsquared.Ordinary;
   results.aic(1, 1) = m1.ModelCriterion.AIC;
   results.aic(2, 1) = m2.ModelCriterion.AIC;
   results.bic(1, 1) = m1.ModelCriterion.BIC;
   results.bic(2, 1) = m2.ModelCriterion.BIC;

   % Convert the struct to a table
   results = struct2table(results);

   % Predict values at 100 points for visualization
   xfit = linspace(min(x), max(x), 100)';
   yfit(:, 1) = predict(m1, xfit);
   yfit(:, 2) = predict(m2, xfit);

   % Store residuals
   residuals(:, 1) = m1.Residuals.Raw;
   residuals(:, 2) = m2.Residuals.Raw;

   % results.xfit = xfit;
   % results.yfit = yfit;
   % results.residuals = residuals;

   %% test different methods below here

   % This would greatly simplify things if there was an option to reshape
   % duplicate rows into multi-column variables ... todo later.
   % results.Coefficients = stacktables(m1.Coefficients, m2.Coefficients);


   % % This creates a table where each variable has two-columns
   % % Create a struct of results
   % results.f1 = string(func2str(f1));
   % results.f2 = string(func2str(f2));
   % results.b1(1, 1) = m1.Coefficients.Estimate(1);
   % results.b1(1, 2) = m2.Coefficients.Estimate(1);
   % results.b2(1, 1) = m1.Coefficients.Estimate(2);
   % results.b2(1, 2) = m2.Coefficients.Estimate(2);
   % results.rsq(1, 1) = m1.Rsquared.Ordinary;
   % results.rsq(1, 2) = m2.Rsquared.Ordinary;
   % results.aic(1, 1) = m1.ModelCriterion.AIC;
   % results.aic(1, 2) = m2.ModelCriterion.AIC;
   % results.bic(1, 1) = m1.ModelCriterion.BIC;
   % results.bic(1, 2) = m2.ModelCriterion.BIC;

   % % This doesn't work b/c Coefficients and ModelCriterion have different sizes,
   % % but the "b1", "b2" row subscripting is useful and likely necessary if using
   % % models with more than two terms. Could also return Coefficients and
   % % ModelCriterion as separate tables.
   % Coefficients(1, 1) = m1.Coefficients.Estimate("b1");
   % Coefficients(1, 2) = m2.Coefficients.Estimate("b1");
   % Coefficients(2, 1) = m1.Coefficients.Estimate("b2");
   % Coefficients(2, 2) = m2.Coefficients.Estimate("b2");
   %
   % ModelCriterion(1, 1) = m1.Rsquared.Ordinary;
   % ModelCriterion(1, 2) = m2.Rsquared.Ordinary;
   % ModelCriterion(2, 1) = m1.ModelCriterion.AIC;
   % ModelCriterion(2, 2) = m2.ModelCriterion.AIC;
   % ModelCriterion(3, 1) = m1.ModelCriterion.BIC;
   % ModelCriterion(3, 2) = m2.ModelCriterion.BIC;
   %
   % results.Coefficients = Coefficients;
   % results.ModelCriterion = ModelCriterion;

   % This depends on the nonlinear model form. For y = ax^b i.e. log-log, I
   % think it would be [log(ab(1)) log(ab(2))/100]; But in general a better
   % approach might be to log the data and fit linear?
   % ab = lm.Coefficients.Estimate(1:2);
   % nm = fitnlm(x, y, f, [ab(1) log(ab(2))/100]);

   % % This is exactly as it was in the original script
   % % Store slopes
   % results.intercept(n, 1) = lm.Coefficients.Estimate(1);
   % results.slope(n, 1) = lm.Coefficients.Estimate(2);
   % results.beta(n, 1) = nm.Coefficients.Estimate(2);
   %
   % % Store R-squared values
   % results.rsq(n, 1) = lm.Rsquared.Ordinary;
   % results.rsq(n, 2) = nm.Rsquared.Ordinary;
   %
   % % Store AIC and BIC values
   % results.aic(n, 1) = lm.ModelCriterion.AIC;
   % results.aic(n, 2) = nm.ModelCriterion.AIC;
   % results.bic(n, 1) = lm.ModelCriterion.BIC;
   % results.bic(n, 2) = nm.ModelCriterion.BIC;
   %
   % % Residual Analysis
   % residuals(:, 1) = lm.Residuals.Raw;
   % residuals(:, 2) = nm.Residuals.Raw;


   % % Likelihood ratio test. Only works for models with different numbers of
   % % estimated parameters (df). This example from FCS analysis comparing linear
   % % to exponential didn't work b/c they both have two df.
   % logL_lm = -0.5 * lm.SSE / lm.RMSE^2 - (lm.NumObservations / 2) * log(2 * pi * lm.RMSE^2);
   % logL_nm = nm.LogLikelihood;
   % LRT_stat = -2 * (logL_lm - logL_nm);
   % df = nm.NumEstimatedCoefficients - lm.NumEstimatedCoefficients;
   % p_value = 1 - chi2cdf(LRT_stat, df);

end
