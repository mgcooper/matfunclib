function [fieldSignificance, maxPVal, localSignificance] = fdrtest(pvals, alpha)
   %FDRTEST Control the false discovery rate in multiple hypothesis testing.
   %
   % [FIELDSIGNIFICANCE, MAXPVAL, LOCALSIGNIFICANCE] = FDRTEST(PVALS, ALPHA)
   %
   % References:
   % - Johnson 2013 (J. Clim.), pp. 4819-4820
   % - Wilks 2006 (J. Appl. Meteorol. Clim.)
   %
   % Control the false discovery rate in multiple hypothesis testing and assess
   % field significance.
   %
   % Inputs:
   % pvals - array of "local" p-values from multiple hypothesis tests
   % alpha - "global" significance (FDR) level (default: alpha=0.05)
   %
   % Outputs:
   % fieldSignificance - 1 if field is significant, 0 otherwise
   % maxPVal - maximum p-value that is considered significant under
   % FDR control. This is the p-value for local significance tests controlling
   % the false discovery rate at confidence level alpha.
   % localSignificance - logical array indicating which of the original
   % tests are significant under FDR control.
   %
   % Example:
   % pvalues = rand(1, 100);  % Assuming 100 p-values between 0 and 1
   % alpha = 0.05;
   % [fieldSignificance, maxPValue, localSignificance] = controlFdr(pvalues, alpha);
   %
   % See also:

   if nargin < 2
      alpha = 0.05;
   end

   % Store the original indices of the sorted p-values
   numTests = length(pvals);
   [sortedPs, originalIndices] = sort(pvals);

   criticalValues = alpha * (1:numTests) / numTests;
   underThreshold = sortedPs <= criticalValues;

   maxPVal = max(sortedPs(underThreshold));
   fieldSignificance = max(underThreshold);

   % Map back to the original indices to indicate which tests are significant
   localSignificance = zeros(1, numTests);
   localSignificance(originalIndices) = underThreshold;
end
