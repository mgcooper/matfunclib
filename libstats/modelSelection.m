function [results, xfit, yfit, residuals] = modelSelection(x, y, f1, f2, b1, b2)
   
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
   
end
