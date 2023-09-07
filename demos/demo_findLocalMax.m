function [maxVals, inflectionPts] = findLocalMax(A)
% Find all local maxima along the rows of A.

% Find local maxima.
s = sign(diff(A));

nanMask = isnan(A);
if any(nanMask(:))
   % Non-finites in A represent +Inf entries, and the sign mask must
   % reflect the behavior of +Inf.
   s(nanMask(1:(end-1),:)) = -1;
   s(~nanMask(1:(end-1),:) & nanMask(2:end,:)) = 1;
end

% Correct for repeated points.  To have the first local maxima of a
% plateau marked as true, the sign of subsequent repeated values should
% be set to the sign of the next non-zero difference.  This ensures
% that the second order difference has the correct sign.
if ~all(s(:))
   if isinteger(A)
      s = single(s);
   end
   s(s == 0) = NaN;
   s = fillmissing(s, 'next', 'EndValues', 'nearest');
end

% Find points where the second order difference is negative and pad the
% result to be of the correct size.
pad = true(1, size(A,2));
maxVals = [~pad; diff(s) < 0; ~pad];

% Ignore repeated values.
uniquePts = [pad; (A(2:end,:) ~= A(1:(end-1),:))];
if isfloat(A) && any(isnan(A(:)))
   uniquePts = uniquePts & ...
      [pad; ~(isnan(A(2:end,:)) & isnan(A(1:(end-1),:)))];
end

% Get the inflection points: every place where the first order
% difference of A changes sign.  Remove duplicate points.  Consider end
% points inflection points.
inflectionPts = [pad; (s(1:(end-1),:) ~= s(2:end, :)) & ...
   uniquePts(2:(end-1),:); pad];
end
