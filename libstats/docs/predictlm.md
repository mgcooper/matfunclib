# predictlm

In MATLAB, the `predict` method of the `LinearModel` class (`fitlm` returns an object of this class) can provide the confidence intervals for predictions. However, Octave's statistics package provides the fit and statistics differently and does not have a `predict` method like MATLAB.

The `predictlm` code computes the confidence interval of the fitted curve in an Octave and Matlab compatible way. The code also includes an option to compute the prediction interval for new observations.

Given the coefficients and their confidence intervals, we can manually compute the confidence intervals for predictions. The confidence interval for a new observation \( t \) is given by:

\[
\hat{y}(t) \pm t_{\alpha/2, n-2} \times \sqrt{MSE \times \left(1 + \frac{1}{n} + \frac{(t - \bar{t})^2}{\sum (t_i - \bar{t})^2}\right)}
\]

Where:

- \( \hat{y}(t) \) is the predicted value for \( t \) (which is `yfit` in your code).
- \( t_{\alpha/2, n-2} \) is the t-value for a given alpha level (like 0.05 for 95% confidence) and \( n-2 \) degrees of freedom.
- \( MSE \) is the mean squared error (this should be available in the statistics output from `fitlm`).
- \( \bar{t} \) is the mean of the \( t \) values.

Let's implement the code for this:

```octave
% Using your provided code
[lmmdl, stats] = fitlm(t, y(:, n), "display", "off");
coeff = stats.coeffs(:, 1);
confi = stats.coeffs(:, 3:4);
yfit = coeff(1) + t.*coeff(2);

% Compute prediction confidence interval manually
n = length(t);
tbar = mean(t);
mse = stats.sse / (n - 2);
tval = tinv(1-alpha/2, n-2); % assuming alpha like 0.05 for 95% CI

% Compute the standard error for each prediction
se = sqrt(mse .* (1 + 1/n + ((t - tbar).^2) ./ sum((t - tbar).^2)));

% Compute the upper and lower prediction intervals
yconf_lower = yfit - tval*se;
yconf_upper = yfit + tval*se;

% Combine into a single matrix for convenience
yconf = [yconf_lower, yconf_upper];
```


Quick detour: The code below was originally matlab I converted to octave the only thing remaining is yconf, the upper and lower prediction intervals. confi(1, 1:2) is the lower/upper intercept CI, confi(2, 1:2) the slope CIs. Coeff(1) intercept, (2) slope. Can you provide the code to get yconf? 
[lmmdl, stats] = fitlm(t,y(:,n),"display", "off");
% coeff = [lmmdl{2:3, 2}]; % this might work in matlab too
coeff = stats.coeffs(:, 1);
confi = stats.coeffs(:, 3:4);
yfit = coeff(1) + t.*coeff(2);
[yfit,yconf] = predict(lmmdl,t,'alpha',alpha); % fitted line and CIs
