% demo_yorkfit Fit a line when both x and y carry errors, possibly correlated.
%
% Ordinary least squares assumes the x values are exact. When they are not,
% its slope is biased, and collecting more data does not remove the bias.
% Under the classical assumptions, that the errors have zero mean, that both
% errors are uncorrelated with the true x, and that the x and y errors are
% uncorrelated with each other, that bias runs toward zero. This demo checks yorkfit against
% the published solution, measures the bias in a simulation that meets those
% assumptions, and shows the two limits yorkfit reduces to when one of the
% two errors goes to zero.

%% The standard test problem
%
% Pearson (1901) ten-point data with the weights York (1966) assigned to it.
% York et al. (2004) Table II publishes the solution, so the fit can be
% checked digit for digit.

X = [0.0; 0.9; 1.8; 2.6; 3.3; 4.4; 5.2; 6.1; 6.5; 7.4];
Y = [5.9; 5.4; 4.4; 4.6; 3.5; 3.7; 2.8; 2.8; 2.4; 1.5];
wX = [1000; 1000; 500; 800; 200; 80; 60; 20; 1.8; 1];
wY = [1; 1.8; 4; 8; 20; 20; 70; 70; 100; 500];

% York (1966) assigned weights, and yorkfit takes errors, so invert them
sigX = 1 ./ sqrt(wX);
sigY = 1 ./ sqrt(wY);

% zero correlation between the x error and the y error of the same point,
% which is the standard assumption when that correlation is unknown
rxy = 0;

[ab, stats] = yorkfit(X, Y, sigX, sigY, rxy);

%% Compare with the published solution
%
% York et al. (2004) Table II gives the first five rows. Cantrell (2008)
% Table 2, Williamson-York row, gives the last two, which are the York
% sigmas widened by sqrt(S/(n-2)) because this fit scatters more than the
% assigned errors predict.

quantity = ["intercept a"; "slope b"; "sigma_a (unscaled)"; ...
   "sigma_b (unscaled)"; "S/(n-2)"; "a_std (scaled)"; "b_std (scaled)"];
published = [5.4799102; -0.4805334; 0.29497; 0.05799; 1.48329; 0.359; ...
   0.0706];
returned = [stats.a; stats.b; stats.a_sig; stats.b_sig; stats.Sbar; ...
   stats.a_std; stats.b_std];

disp('Pearson (1901) data with York (1966) weights:')
disp(table(quantity, published, returned, abs(published - returned), ...
   'VariableNames', {'quantity', 'published', 'returned', 'difference'}))

fprintf('converged in %d iterations\n', stats.iter)
fprintf('S = %.5f on %d degrees of freedom, p = %.4f\n', ...
   stats.S, numel(X) - 2, stats.S_pval)
fprintf(['a p-value of %.4f says the scatter is consistent with the ' ...
   'assigned errors\n\n'], stats.S_pval)

%% How much the two estimators disagree here
%
% Ordinary least squares ignores sigX and sigY entirely. On this data set
% that makes its slope steeper than the York slope, not flatter. The errors
% here are far from equal: the first point carries a thousand times the x
% weight of the last, while the y weights run the other way.
%
% With uncorrelated errors the York weight is 1/(sigY^2 + b^2*sigX^2), so a
% point counts for little when either contribution is large. The two
% contributions are not sigX and sigY themselves: the x error enters through
% the line, scaled by the slope, so the comparison is between sigY and
% abs(b)*sigX. Those two carry the same units; the raw errors need not.
%
% The table below prints both contributions. Point 7 shows why the scaling
% matters. Its raw sigX of 0.129 exceeds its sigY of 0.120, yet
% abs(b)*sigX is only 0.062, so the y error is what limits its weight. Point
% 1 has the most precise x of the ten and the least precise y, and it
% carries the smallest weight of all.
%
% Note: this section compares two estimators on one sample. It does not
% measure bias. Bias describes an estimator across samples from a model, and
% neither estimate here is the true slope, which nobody knows for this data.
% The next section measures the bias where the true slope is known.

abOLS = [ones(numel(X), 1), X] \ Y;

fprintf('ordinary least squares slope: %+.4f\n', abOLS(2))
fprintf('york slope:                   %+.4f\n', ab(2))
fprintf('difference:                   %+.4f\n\n', ab(2) - abOLS(2))

% York step 3 at the fitted slope, with uncorrelated errors
yorkWeight = wX .* wY ./ (wX + ab(2)^2 * wY);

% the two error contributions, both in the units of y
scaledXerror = abs(ab(2)) * sigX;

disp('How York weights each point:')
disp(table((1:numel(X))', sigX, sigY, scaledXerror, yorkWeight, ...
   'VariableNames', {'point', 'sigX', 'sigY', 'absB_sigX', 'yorkWeight'}))

%% The bias, averaged over repeated samples
%
% Bias is the gap between the average of an estimator over repeated samples
% and the truth, so one fit cannot show it: a single estimate differs from
% the truth by estimation error as well. Simulate many samples from a model
% that meets the classical assumptions and average the estimates.
%
% The comparison value is the probability limit of the ordinary
% least-squares slope under this model, b*var(x)/(var(x) + sigma^2). That is
% the value a single estimate approaches as the points per sample grow. It
% is a benchmark here, not the quantity being averaged: averaging over more
% samples converges to the expected slope at 400 points, which sits near the
% probability limit rather than exactly on it.

rng default
nPoints = 400;
nSamples = 200;
trueSlope = 2;
trueIntercept = 1;
equalError = 1.5;

xTrue = linspace(0, 10, nPoints)';
yTrue = trueIntercept + trueSlope * xTrue;

slopesOLS = zeros(nSamples, 1);
slopesYork = zeros(nSamples, 1);
designMatrix = ones(nPoints, 2);

for k = 1:nSamples
   % measure both axes with the same error at every point
   xObs = xTrue + equalError * randn(nPoints, 1);
   yObs = yTrue + equalError * randn(nPoints, 1);

   designMatrix(:, 2) = xObs;
   abOLSequal = designMatrix \ yObs;
   abYorkEqual = yorkfit(xObs, yObs, equalError, equalError, 0);

   slopesOLS(k) = abOLSequal(2);
   slopesYork(k) = abYorkEqual(2);
end

plimOLS = trueSlope * var(xTrue) / (var(xTrue) + equalError^2);

fprintf('known true slope:                    %+.4f\n', trueSlope)
fprintf('least squares, mean of %3d samples:  %+.4f\n', nSamples, ...
   mean(slopesOLS))
fprintf('least squares, large-sample limit:   %+.4f  (flattened)\n', ...
   plimOLS)
fprintf('york, mean of %3d samples:           %+.4f\n\n', nSamples, ...
   mean(slopesYork))

%% The two limits
%
% York (2004) Appendix D. As sigX goes to zero the York weight becomes
% omega(Y), so the fit becomes weighted least squares of y on x. As sigY
% goes to zero the weight becomes omega(X)/b^2, so the fit becomes weighted
% least squares of x on y, read back as a line in y. Passing a zero error
% takes either limit directly rather than returning NaN.
%
% Note: the second limit has one exception. omega(X)/b^2 is unbounded at a
% zero slope, so a zero sigY beside a horizontal solution raises an error
% instead. See the Known bound paragraph in the yorkfit help.
%
% Note: lscov appears twice below as the oracle, which invites the question
% of whether it could replace yorkfit outright. It cannot. lscov takes a
% fixed weight matrix, and the York weight depends on the slope, which is
% what makes the problem iterative rather than linear. The block after the
% comparison shows what lscov does instead.

designMatrixPearson = [ones(numel(X), 1), X];

abExactX = yorkfit(X, Y, 0, sigY, rxy);
abWLS = lscov(designMatrixPearson, Y, 1 ./ sigY.^2);

fprintf('exact x, yorkfit: a = %+.6f, b = %+.6f\n', abExactX(1), abExactX(2))
fprintf('exact x, lscov:   a = %+.6f, b = %+.6f\n', abWLS(1), abWLS(2))

% the mirror limit: regress x on y, then invert the line to compare
abExactY = yorkfit(X, Y, sigX, 0, rxy);
cdWLS = lscov([ones(numel(X), 1), Y], X, 1 ./ sigX.^2);
abMirror = [-cdWLS(1) / cdWLS(2); 1 / cdWLS(2)];

fprintf('exact y, yorkfit: a = %+.6f, b = %+.6f\n', abExactY(1), abExactY(2))
fprintf('exact y, lscov:   a = %+.6f, b = %+.6f\n\n', abMirror(1), ...
   abMirror(2))

% What lscov gives on the full problem, where neither error is zero. Called
% once with the y weights it never sees sigX. Called in a loop that refreshes
% the York weights it converges, but not to the York fit: that loop solves
% the fixed-weight problem at each step, so it drops the part of dS/db that
% comes from the weight depending on b. Its S is larger, which shows it is
% not minimizing York's objective either.
abYweights = lscov(designMatrixPearson, Y, wY);

bLoop = designMatrixPearson \ Y;
for k = 1:500
   yorkWeightLoop = wX .* wY ./ (wX + bLoop(2)^2 * wY);
   bNext = lscov(designMatrixPearson, Y, yorkWeightLoop);
   if abs(bNext(2) - bLoop(2)) < 1e-15
      bLoop = bNext;
      break
   end
   bLoop = bNext;
end

fprintf('neither error zero, so no limit applies:\n')
fprintf('  york                        b = %+.7f\n', ab(2))
fprintf('  lscov with the y weights    b = %+.7f  (cannot see sigX)\n', ...
   abYweights(2))
fprintf('  lscov looped on W_i(b)      b = %+.7f  (%d steps)\n', ...
   bLoop(2), k)
fprintf('  S at the york slope         %.6f\n', stats.S)
fprintf('  S at the looped lscov slope %.6f\n\n', ...
   sum((wX .* wY ./ (wX + bLoop(2)^2 * wY)) .* (Y - bLoop(1) - bLoop(2)*X).^2))

%% Plot the york and least-squares fits
%
% The error bars show the assigned sigX and sigY. The two lines are
% farthest apart at the ends of the x range, which is also where the two
% assigned errors are most lopsided.

figure
errorbar(X, Y, sigY, sigY, sigX, sigX, 'o', 'DisplayName', 'data')
hold on
plot(stats.xfit, stats.yfit, '-', 'LineWidth', 1.5, 'DisplayName', 'york')
plot(stats.xfit, abOLS(1) + abOLS(2) * stats.xfit, '--', ...
   'DisplayName', 'ordinary least squares')
xlabel('x')
ylabel('y')
title('Pearson (1901) data with York (1966) weights')
legend('Location', 'northeast')

%% The algorithm in its published form
%
% Everything above calls yorkfit, which wraps the algorithm in input
% checking, degenerate-case handling and numerical guards. Those earn their
% place, but they also bury the algorithm. The function at the end of this
% file is the York et al. (2004) recipe on its own, written in the paper's
% notation and step order with nothing else in it.
%
% Read it as the reference, not as a replacement. It assumes well-conditioned
% input: nonzero errors, a correlation away from +-1, and more than two
% points. yorkfit covers those cases and this does not.
%
% Section III of the paper states the recipe as ten steps.
%
%   1. Choose an approximate initial value of b. Ordinary least squares will
%      do, because the iteration is not sensitive to it.
%   2. Determine omega(Xi) and omega(Yi), the weight of each coordinate.
%      With independent errors each weight is 1/sigma^2.
%   3. Use those weights, ri and the current b to evaluate Wi.
%   4. Use Wi to evaluate Xbar and Ybar, then Ui, Vi and betai.
%   5. Use Wi, betai, Ui and Vi to evaluate an improved b.
%   6. Repeat steps 3 to 5 until two successive b agree to the tolerance.
%   7. From the final b, evaluate a = Ybar - b*Xbar.
%   8. For each point, evaluate the adjusted xi and yi.
%   9. Use the adjusted xi and Wi to evaluate xbar, then ui.
%  10. Evaluate sigma_b and sigma_a from ui, Wi and xbar.
%
% Running it beside yorkfit on the same data shows what the hardening costs:
% nothing in the interior. The two agree to the tolerance of the iteration.

[abReference, sigmaAreference, sigmaBreference, xiReference, ...
   yiReference] = yorkreference(X, Y, wX, wY, zeros(size(X)));

quantity = ["intercept a"; "slope b"; "sigma_a"; "sigma_b"];
published = [5.4799102; -0.4805334; 0.29497; 0.05799];
reference = [abReference(1); abReference(2); sigmaAreference; ...
   sigmaBreference];
production = [stats.a; stats.b; stats.a_sig; stats.b_sig];

disp('York et al. (2004) Section III, transcribed, against yorkfit:')
disp(table(quantity, published, reference, production, ...
   abs(reference - production), 'VariableNames', ...
   {'quantity', 'published', 'reference', 'yorkfit', 'difference'}))

% step 8 produces both adjusted coordinates, so check both against the fields
% yorkfit reports for them
fprintf('largest gap in the step-8 adjusted points: x %.3g, y %.3g\n\n', ...
   max(abs(xiReference - stats.xadj)), max(abs(yiReference - stats.yadj)))

function [ab, sigma_a, sigma_b, xi, yi] = yorkreference(X, Y, wX, wY, r)
   %YORKREFERENCE York et al. (2004) Section III, transcribed step by step.
   %
   %  [ab, sigma_a, sigma_b, xi, yi] = YORKREFERENCE(X, Y, wX, wY, r)
   %  returns the intercept and slope as ab = [a; b], their standard errors,
   %  and the step-8 adjusted points, for observed points X and Y whose
   %  coordinate weights are wX and wY and whose per-point error correlation
   %  is r.
   %
   %  The names follow the paper: wX and wY are its omega(Xi) and omega(Yi),
   %  and alpha, Wi, Xbar, Ybar, Ui, Vi, betai, xbar and ui are its
   %  alpha_i, W_i, Xbar, Ybar, U_i, V_i, beta_i, xbar and u_i.
   %
   %  This is a reference for reading. It assumes well-conditioned input and
   %  checks nothing. Use yorkfit for anything else.

   tol = 1e-15;
   maxiter = 1000;

   % step 1, an approximate initial b from ordinary least squares
   M = [ones(numel(X), 1), X] \ Y;
   b = M(2);

   % step 2, the weights, and the alpha_i that carries their geometric mean
   alpha = sqrt(wX .* wY);

   for iter = 1:maxiter
      bprevious = b;

      % step 3, the York weight of each point at the current slope
      Wi = wX .* wY ./ (wX + b^2 * wY - 2 * b * r .* alpha);

      % step 4, the weighted means, the centered data, and beta. The block
      % after the loop repeats this at the converged slope.
      Xbar = sum(Wi .* X) / sum(Wi);
      Ybar = sum(Wi .* Y) / sum(Wi);
      Ui = X - Xbar;
      Vi = Y - Ybar;
      betai = Wi .* (Ui ./ wY + b * Vi ./ wX - (b * Ui + Vi) .* r ./ alpha);

      % step 5, an improved slope
      b = sum(Wi .* betai .* Vi) / sum(Wi .* betai .* Ui);

      % step 6, stop when two successive slopes agree
      if abs(b - bprevious) <= tol
         break
      end
   end

   % Steps 3 and 4 again, at the slope step 5 just produced.
   %
   % The paper's step order is ambiguous here, and the ambiguity matters. Read
   % literally, steps 7 to 10 use the Wi, Xbar, Ybar and betai that the last
   % pass through steps 3 and 4 produced, and those belong to the slope
   % *before* the final update. Everything below would then mix two slopes.
   % On the Pearson data that shifts the intercept by about 2e-15, which the
   % tolerance hides, so a reference that skipped this would agree with
   % yorkfit and prove nothing.
   %
   % This is where defect D4 lived. yorkfit does the same recompute, in
   % yorkfinal. Leaving it out here would make this reference reproduce the
   % bug it exists to check against.
   Wi = wX .* wY ./ (wX + b^2 * wY - 2 * b * r .* alpha);
   Xbar = sum(Wi .* X) / sum(Wi);
   Ybar = sum(Wi .* Y) / sum(Wi);
   Ui = X - Xbar;
   Vi = Y - Ybar;
   betai = Wi .* (Ui ./ wY + b * Vi ./ wX - (b * Ui + Vi) .* r ./ alpha);

   % step 7, the intercept at the final slope
   a = Ybar - b * Xbar;

   % step 8, the adjusted points
   xi = Xbar + betai;
   yi = Ybar + b * betai;

   % step 9, the weighted mean of the adjusted x values, and ui
   xbar = sum(Wi .* xi) / sum(Wi);
   ui = xi - xbar;

   % step 10, the standard errors
   sigma_b = sqrt(1 / sum(Wi .* ui.^2));
   sigma_a = sqrt(1 / sum(Wi) + xbar^2 * sigma_b^2);

   ab = [a; b];
end
