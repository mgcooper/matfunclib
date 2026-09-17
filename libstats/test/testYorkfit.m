classdef testYorkfit < matlab.unittest.TestCase
   %TESTYORKFIT Test the York bivariate regression function.
   %
   % One test checks the iterative York solution against published values
   % for the Pearson (1901) data with York (1966) weights. A second checks
   % the same slope against the York cubic solved by fzero, which is an
   % estimator independent of the iteration yorkfit uses. The remaining
   % tests use hand-computed values for each input branch: the error
   % scaling rule, the p-value and confidence-bound agreement, the
   % Appendix D zero-error limits, the two ordinary least-squares short
   % circuits, the zero rxy default for four inputs, the unit-weight
   % major-axis case, the degenerate N = 2 and horizontal-line cases, and
   % the input validation errors.

   properties (TestParameter)
      % Sizes of the x and y vectors for the zero-error OLS short circuit.
      % Row vectors take the short circuit like columns.
      orientation = struct('column', [4, 1], 'row', [1, 4])

      % Sigma vector pairs for x = (1:6)' in the omitted-rxy test. Constant
      % sigma vectors have no defined correlation with each other.
      % Proportional sigma vectors correlate perfectly across points. That
      % is not an error correlation, so an omitted rxy must still equal an
      % explicit zero rxy.
      sigmapair = struct( ...
         'constant', {{0.5*ones(6, 1), 0.2*ones(6, 1)}}, ...
         'proportional', {{0.1*(1:6)', 0.2*(1:6)'}})

      % Invalid inputs. Each case holds the position of one of the valid
      % inputs, the invalid value that replaces it, and the expected error
      % identifier. validateattributes raises the MATLAB:yorkfit:* errors;
      % yorkfit itself raises the matfunclib:yorkfit:* errors.
      badinput = struct( ...
         'xNaN', {{1, [1; NaN; 3], 'MATLAB:yorkfit:expectedNonNaN'}}, ...
         'ySize', {{2, [2; 4], 'MATLAB:yorkfit:incorrectSize'}}, ...
         'sigxInf', {{3, [0.1; Inf; 0.1], ...
         'MATLAB:yorkfit:expectedFinite'}}, ...
         'sigyNaN', {{4, [1; NaN; 3], 'MATLAB:yorkfit:expectedNonNaN'}}, ...
         'rxyNaN', {{5, NaN, 'MATLAB:yorkfit:expectedNonNaN'}}, ...
         'sigxNegative', {{3, -0.1, ...
         'MATLAB:yorkfit:expectedNonnegative'}}, ...
         'sigyNegative', {{4, [0.1; -0.1; 0.1], ...
         'MATLAB:yorkfit:expectedNonnegative'}}, ...
         'rxyAboveOne', {{5, 1.5, 'MATLAB:yorkfit:notLessEqual'}}, ...
         'rxyBelowMinusOne', {{5, -1.5, ...
         'MATLAB:yorkfit:notGreaterEqual'}}, ...
         'sigxWrongLength', {{3, [0.1; 0.1], ...
         'matfunclib:yorkfit:inconsistentSize'}}, ...
         'sigyWrongLength', {{4, [0.1; 0.1; 0.1; 0.1], ...
         'matfunclib:yorkfit:inconsistentSize'}}, ...
         'rxyWrongLength', {{5, [0; 0], ...
         'matfunclib:yorkfit:inconsistentSize'}})
   end

   properties (Constant)
      % Valid x, y, sigX, sigY, and rxy inputs for the input validation
      % tests. Each badinput case replaces one of them.
      validinputs = {[1; 2; 3], [2; 4; 7], [0.1; 0.1; 0.1], ...
         [0.1; 0.1; 0.1], 0}
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so yorkfit resolves from the repo
         % root without a manual addpath.
         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (Static, Access = private)
      function [x, y, sigx, sigy] = pearsondata()
         % Pearson (1901) data with York (1966) weights. Reference: York et
         % al. (2004) Table I, and Cantrell (2008), Atmos. Chem. Phys. 8,
         % 5477-5487, Table 2.
         x = [0.0; 0.9; 1.8; 2.6; 3.3; 4.4; 5.2; 6.1; 6.5; 7.4];
         y = [5.9; 5.4; 4.4; 4.6; 3.5; 3.7; 2.8; 2.8; 2.4; 1.5];
         wx = [1000; 1000; 500; 800; 200; 80; 60; 20; 1.8; 1];
         wy = [1; 1.8; 4; 8; 20; 20; 70; 70; 100; 500];
         sigx = 1./sqrt(wx);
         sigy = 1./sqrt(wy);
      end

      function b = cubicslope(x, y, sigx, sigy, b0)
         % Solve the York cubic for the slope when the errors are
         % uncorrelated, using fzero rather than the fixed-point iteration
         % yorkfit runs. This is an independent estimator, so it checks the
         % iteration rather than restating it.
         %
         % Note: the cubic must be centered on the weight-dependent means
         % barX and barY, not on mean(x) and mean(y). Centering on the
         % unweighted means solves a different problem and does not
         % reproduce the published York slope.
         wx = 1./sigx.^2;
         wy = 1./sigy.^2;
         b = fzero(@residualcubic, b0);

         function r = residualcubic(b)
            % Value of the York cubic at the slope b. fzero drives this to
            % zero. The cubic is the stationary condition of the weighted
            % sum of squares, so its root is the York slope.
            W = wx.*wy./(b^2*wy + wx);
            U = x - sum(W.*x)/sum(W);
            V = y - sum(W.*y)/sum(W);
            r = b^3*sum(W.^2.*U.^2./wx) ...
               - 2*b^2*sum(W.^2.*U.*V./wx) ...
               - b*(sum(W.*U.^2) - sum(W.^2.*V.^2./wx)) ...
               + sum(W.*U.*V);
         end
      end
   end

   methods (Access = private)
      function varargout = runquiet(testCase, varargin)
         % Call yorkfit with the warning display off. Tests that assert a
         % specific warning use verifyWarning against its identifier; this
         % helper is for the calls whose warnings are incidental. The
         % teardown restores the warning state if yorkfit errors.
         warnstate = warning('off', 'all');
         testCase.addTeardown(@warning, warnstate)
         [varargout{1:nargout}] = yorkfit(varargin{:});
         warning(warnstate)
      end
   end

   methods (Test)
      function testPearsonYorkReference(testCase)
         % Pearson (1901) data with York (1966) weights and uncorrelated
         % errors. Reference: York et al. (2004) Table II gives the slope
         % -0.4805334, the intercept 5.4799102, the unscaled sigmas
         % 0.29497 and 0.05799, and S/(n-2) = 1.48329. Cantrell (2008)
         % Table 2, Williamson-York row, gives the scaled standard errors
         % 0.359 and 0.0706, which are those sigmas times sqrt(S/(n-2)).
         % Each tolerance is half of the last published digit.
         [x, y, sigx, sigy] = testYorkfit.pearsondata();
         rxy = zeros(size(x));
         alpha = 0.05;

         a_expected = 5.4799102;
         a_tol = 0.5e-7;
         b_expected = -0.4805334;
         b_tol = 0.5e-7;
         a_sig_expected = 0.29497;
         a_sig_tol = 0.5e-5;
         b_sig_expected = 0.05799;
         b_sig_tol = 0.5e-5;
         sbar_expected = 1.48329;
         sbar_tol = 0.5e-5;
         a_std_expected = 0.359;
         a_std_tol = 0.5e-3;
         b_std_expected = 0.0706;
         b_std_tol = 0.5e-4;

         [ab_returned, stats_returned] = yorkfit(x, y, sigx, sigy, rxy, ...
            alpha);

         % Intercept and slope match the published York solution.
         ab_expected = [a_expected; b_expected];
         ab_tol = [a_tol; b_tol];
         testCase.verifyEqual(ab_returned, ab_expected, 'AbsTol', ab_tol)
         testCase.verifyEqual(stats_returned.a, a_expected, 'AbsTol', a_tol)
         testCase.verifyEqual(stats_returned.b, b_expected, 'AbsTol', b_tol)

         % The unscaled sigmas match York Table II directly. The suite used
         % to check only the scaled errors, which hid whether the scaling
         % or the solver was responsible for a change.
         testCase.verifyEqual(stats_returned.a_sig, a_sig_expected, ...
            'AbsTol', a_sig_tol)
         testCase.verifyEqual(stats_returned.b_sig, b_sig_expected, ...
            'AbsTol', b_sig_tol)
         testCase.verifyEqual(stats_returned.Sbar, sbar_expected, ...
            'AbsTol', sbar_tol)

         % S/(n-2) exceeds 1 here, so the scaling rule widens the errors and
         % reproduces the Cantrell values.
         testCase.verifyEqual(stats_returned.a_std, a_std_expected, ...
            'AbsTol', a_std_tol)
         testCase.verifyEqual(stats_returned.b_std, b_std_expected, ...
            'AbsTol', b_std_tol)

         % Confidence bounds use the Student t critical value for n-2 = 8
         % degrees of freedom at two-sided alpha = 0.05: 2.306 in a t table.
         % The tolerance adds the rounding of each published factor.
         t_c_expected = 2.306;
         t_c_tol = 0.5e-3;
         a_ci_tol = a_tol + t_c_expected*a_std_tol + t_c_tol*a_std_expected;
         b_ci_tol = b_tol + t_c_expected*b_std_tol + t_c_tol*b_std_expected;
         a_L_expected = a_expected - t_c_expected*a_std_expected;
         a_H_expected = a_expected + t_c_expected*a_std_expected;
         b_L_expected = b_expected - t_c_expected*b_std_expected;
         b_H_expected = b_expected + t_c_expected*b_std_expected;
         testCase.verifyEqual(stats_returned.a_L, a_L_expected, ...
            'AbsTol', a_ci_tol)
         testCase.verifyEqual(stats_returned.a_H, a_H_expected, ...
            'AbsTol', a_ci_tol)
         testCase.verifyEqual(stats_returned.b_L, b_L_expected, ...
            'AbsTol', b_ci_tol)
         testCase.verifyEqual(stats_returned.b_H, b_H_expected, ...
            'AbsTol', b_ci_tol)

         % The x-intercept is -a/b. The tolerance propagates the a and b
         % rounding.
         xint_expected = -a_expected/b_expected;
         xint_tol = a_tol/abs(b_expected) ...
            + abs(a_expected)*b_tol/b_expected^2;
         testCase.verifyEqual(stats_returned.xintercept, xint_expected, ...
            'AbsTol', xint_tol)

         % A well-posed fit converges inside the iteration limit.
         testCase.verifyTrue(stats_returned.converged)
         testCase.verifyGreaterThan(stats_returned.iter, 0)
         testCase.verifyLessThan(stats_returned.iter, 1000)
      end

      function testCubicOracleMatchesIterativeSlope(testCase)
         % The York cubic solved by fzero is an estimator independent of the
         % fixed-point iteration yorkfit runs, so it checks the iteration
         % rather than restating it. Both must land on the published slope.
         [x, y, sigx, sigy] = testYorkfit.pearsondata();
         tol = 1e-9;

         b_expected = testYorkfit.cubicslope(x, y, sigx, sigy, -0.5);

         [ab_returned, ~] = yorkfit(x, y, sigx, sigy, 0);

         testCase.verifyEqual(ab_returned(2), b_expected, 'AbsTol', tol)
      end

      function testScalingNeverNarrowsAGoodFit(testCase)
         % Data on an exact line has zero residuals, so S/(n-2) is zero.
         % York Section V says the scaling is not a mechanical step, so a
         % fit better than the assigned errors predict must not produce an
         % interval narrower than those errors support. a_std must equal
         % a_sig rather than collapsing to zero.
         x = [2; 0; 3; 1];
         y = 1 + 2*x;
         sigx = [1; 2; 1; 2];
         sigy = [1; 1; 2; 2];
         tol = 1e-12;

         [~, stats_returned] = testCase.runquiet(x, y, sigx, sigy);

         testCase.verifyEqual(stats_returned.Sbar, 0, 'AbsTol', tol)
         testCase.verifyEqual(stats_returned.a_std, stats_returned.a_sig, ...
            'AbsTol', tol)
         testCase.verifyEqual(stats_returned.b_std, stats_returned.b_sig, ...
            'AbsTol', tol)
      end

      function testScalingWidensAPoorFit(testCase)
         % When S/(n-2) exceeds 1 the scatter exceeds what the assigned
         % errors predict, so the errors widen by sqrt(S/(n-2)). The
         % expected values come from the returned a_sig and Sbar through the
         % rule itself, not from a_std.
         [x, y, sigx, sigy] = testYorkfit.pearsondata();
         tol = 1e-12;

         [~, stats_returned] = yorkfit(x, y, sigx, sigy, 0);

         testCase.verifyGreaterThan(stats_returned.Sbar, 1)
         scale_expected = sqrt(stats_returned.Sbar);
         a_std_expected = stats_returned.a_sig*scale_expected;
         b_std_expected = stats_returned.b_sig*scale_expected;
         testCase.verifyEqual(stats_returned.a_std, a_std_expected, ...
            'AbsTol', tol)
         testCase.verifyEqual(stats_returned.b_std, b_std_expected, ...
            'AbsTol', tol)
      end

      function testPvalueAgreesWithConfidenceBounds(testCase)
         % A p-value below alpha must mean the matching interval excludes
         % zero. These five points have S/(n-2) near 5, so the scaled and
         % unscaled slope p-values fall on opposite sides of alpha = 0.05.
         % Computing the p-value from the unscaled b_sig, as the function
         % used to, reports a significant slope beside an interval that
         % contains zero.
         x = [4.3840923144089352; 5.3849587041043367; 7.234651778309412; ...
            7.7991879224011464; 9.7798951199660262];
         y = [1.659564656439712; 0.36871120480956621; ...
            1.8582369613779577; 2.1694298029483332; 3.4910999002293699];
         sigx = 0.3;
         sigy = 0.3;
         alpha = 0.05;
         N = numel(x);
         tol = 1e-12;

         [~, stats_returned] = yorkfit(x, y, sigx, sigy, 0, alpha);

         % The premise of the test: the fit is poor enough to be scaled.
         testCase.verifyGreaterThan(stats_returned.Sbar, 1)

         % The interval contains zero, so the p-value must not be
         % significant.
         testCase.verifyLessThan(stats_returned.b_L, 0)
         testCase.verifyGreaterThan(stats_returned.b_H, 0)
         testCase.verifyGreaterThanOrEqual(stats_returned.b_pval, alpha)

         % The returned p-value is the one built from b_std.
         b_pval_expected = 2*(1 - tcdf(abs(stats_returned.b/ ...
            stats_returned.b_std), N - 2));
         testCase.verifyEqual(stats_returned.b_pval, b_pval_expected, ...
            'AbsTol', tol)

         % The unscaled p-value would have disagreed with that interval.
         b_pval_unscaled = 2*(1 - tcdf(abs(stats_returned.b/ ...
            stats_returned.b_sig), N - 2));
         testCase.verifyLessThan(b_pval_unscaled, alpha)
      end

      function testSpvalIsUpperTailChiSquare(testCase)
         % S_pval reports whether the scatter is consistent with the
         % assigned errors. It is the upper-tail chi-square probability of S
         % on n-2 degrees of freedom.
         [x, y, sigx, sigy] = testYorkfit.pearsondata();
         N = numel(x);
         tol = 1e-12;

         [~, stats_returned] = yorkfit(x, y, sigx, sigy, 0);

         S_pval_expected = 1 - chi2cdf(stats_returned.S, N - 2);
         testCase.verifyEqual(stats_returned.S_pval, S_pval_expected, ...
            'AbsTol', tol)
         testCase.verifyGreaterThanOrEqual(stats_returned.S_pval, 0)
         testCase.verifyLessThanOrEqual(stats_returned.S_pval, 1)
      end

      function testCovAbSatisfiesYorkIdentity(testCase)
         % York gives cov(a,b) = -xbar*sigma_b^2, where xbar is the weighted
         % mean of the adjusted x values of step 9. The oracle rebuilds the
         % York weights and that mean from the inputs and the returned
         % slope, so it does not read xbar back out of cov_ab. Recovering
         % xbar from cov_ab instead would pass even if the function computed
         % the covariance from the wrong mean.
         [x, y, sigx, sigy] = testYorkfit.pearsondata();
         tol = 1e-10;

         [~, stats_returned] = yorkfit(x, y, sigx, sigy, 0);

         % York step 3, uncorrelated form, at the returned slope.
         b = stats_returned.b;
         wx = 1./sigx.^2;
         wy = 1./sigy.^2;
         W = wx.*wy./(wx + b^2*wy);
         barx_expected = sum(W.*stats_returned.xadj)/sum(W);
         cov_ab_expected = -barx_expected*stats_returned.b_sig^2;

         testCase.verifyEqual(stats_returned.cov_ab, cov_ab_expected, ...
            'RelTol', tol)

         % The same xbar closes York's variance identity
         % sigma_a^2 = 1/sum(W) + xbar^2*sigma_b^2.
         a_sig_expected = sqrt(1/sum(W) ...
            + barx_expected^2*stats_returned.b_sig^2);
         testCase.verifyEqual(stats_returned.a_sig, a_sig_expected, ...
            'RelTol', tol)
      end

      function testFinalStateUsesTheConvergedSlope(testCase)
         % The iteration leaves Wi, barX, barY and beta at the values from
         % the slope before the last update. Reporting the intercept and the
         % standard errors from those stale weights mixes two slopes. This
         % rebuilds every step-3 through step-9 quantity at the returned
         % slope and checks the outputs against it, so an implementation
         % that skipped the post-loop recompute would fail here.
         [x, y, sigx, sigy] = testYorkfit.pearsondata();
         tol = 1e-10;

         [~, stats_returned] = yorkfit(x, y, sigx, sigy, 0);

         b = stats_returned.b;
         wx = 1./sigx.^2;
         wy = 1./sigy.^2;
         W = wx.*wy./(wx + b^2*wy);                 % step 3
         sumW = sum(W);
         barX = sum(W.*x)/sumW;                     % step 4
         barY = sum(W.*y)/sumW;
         U = x - barX;
         V = y - barY;
         beta = W.*(U./wy + b*V./wx);               % step 4, rxy = 0
         a_expected = barY - b*barX;                % step 7
         xadj_expected = barX + beta;               % step 8
         yadj_expected = barY + b*beta;             % step 8
         barx = sum(W.*xadj_expected)/sumW;         % step 9
         u = xadj_expected - barx;
         b_sig_expected = sqrt(1/sum(W.*u.*u));
         a_sig_expected = sqrt(1/sumW + barx^2*b_sig_expected^2);

         testCase.verifyEqual(stats_returned.a, a_expected, 'RelTol', tol)
         testCase.verifyEqual(stats_returned.xadj, xadj_expected, ...
            'RelTol', tol)
         testCase.verifyEqual(stats_returned.yadj, yadj_expected, ...
            'RelTol', tol)
         testCase.verifyEqual(stats_returned.b_sig, b_sig_expected, ...
            'RelTol', tol)
         testCase.verifyEqual(stats_returned.a_sig, a_sig_expected, ...
            'RelTol', tol)
      end

      function testZeroSigxGivesWeightedLeastSquares(testCase)
         % York (2004) Appendix D: sigX = 0 gives W_i = omega(Y_i), which is
         % weighted least squares of y on x. The oracle is lscov, not
         % yorkfit. Before this rule the call returned [NaN NaN].
         x = [0; 1; 2; 3];
         y = [1; 3; 2; 4];
         sigx = 0;
         sigy = [0.5; 0.2; 0.8; 0.4];
         tol = 1e-10;

         ab_expected = lscov([ones(4, 1), x], y, 1./sigy.^2);

         ab_returned = yorkfit(x, y, sigx, sigy, 0);

         testCase.verifyEqual(ab_returned, ab_expected, 'AbsTol', tol)
      end

      function testZeroSigyGivesMirrorLimit(testCase)
         % The mirror case sigY = 0 gives W_i = omega(X_i)/b^2. York page
         % 370 states the fit of y on x is symmetric with the fit of x on y,
         % so exchanging the roles must give weighted least squares of x on
         % y, expressed back in the y = a + b*x form.
         x = [1; 3; 2; 4];
         y = [0; 1; 2; 3];
         sigx = [0.5; 0.2; 0.8; 0.4];
         sigy = 0;
         tol = 1e-8;

         % Weighted least squares of x on y, then invert the line.
         cd_expected = lscov([ones(4, 1), y], x, 1./sigx.^2);
         b_expected = 1/cd_expected(2);
         a_expected = -cd_expected(1)/cd_expected(2);
         ab_expected = [a_expected; b_expected];

         ab_returned = yorkfit(x, y, sigx, sigy, 0);

         testCase.verifyEqual(ab_returned, ab_expected, 'AbsTol', tol)
      end

      function testZeroSigxAtOnePointOnly(testCase)
         % The Appendix D limit applies per point, not per call. Only the
         % weight of the exact point changes; the other three keep the
         % general expression. The oracle rebuilds the weight vector by
         % hand at the returned slope.
         x = [0; 1; 2; 3];
         y = [1; 3; 2; 4];
         sigx = [0; 0.3; 0.3; 0.3];
         sigy = [0.5; 0.5; 0.5; 0.5];
         tol = 1e-10;

         [~, stats_returned] = yorkfit(x, y, sigx, sigy, 0);

         % Rebuild the York weights at the returned slope. wY at the exact
         % point, the general expression elsewhere.
         b = stats_returned.b;
         wx = 1./sigx.^2;
         wy = 1./sigy.^2;
         W_expected = wx.*wy./(wx + b^2*wy);
         W_expected(1) = wy(1);
         testCase.verifyTrue(all(isfinite(W_expected)))

         % The fit must reproduce itself from those weights: a weighted
         % least-squares step at the converged weights and slope leaves the
         % adjusted points where yorkfit put them.
         barx_expected = sum(W_expected.*stats_returned.xadj) ...
            /sum(W_expected);
         barx_returned = -stats_returned.cov_ab/stats_returned.b_sig^2;
         testCase.verifyEqual(barx_returned, barx_expected, 'AbsTol', tol)

         % The exact point is not adjusted in x, because its x carries no
         % error.
         testCase.verifyEqual(stats_returned.xadj(1), x(1), 'AbsTol', tol)
      end

      function testVerySmallErrorsDoNotOverflow(testCase)
         % The York weight is wX*wY/(wX + b^2*wY - 2*b*r*sqrt(wX*wY)).
         % Forming wX*wY or sqrt(wX*wY) directly overflows to Inf once the
         % errors fall to about 1e-78, even though wX and wY are each
         % still finite, and every weight becomes NaN for a fit that is
         % otherwise well posed. Dividing through by wX or wY first keeps
         % the denominator near 1, so the fit survives to the limit of the
         % weights themselves.
         x = [0; 1; 2; 3];
         y = [1; 3; 2; 4];
         sigy = 0.5;
         tol = 1e-10;

         % One tiny error. The x values are effectively exact, so the fit
         % must approach the weighted least-squares limit of y on x.
         ab_expected = lscov([ones(4, 1), x], y, ones(4, 1)/sigy^2);
         for sigx = [1e-77, 1e-100, 1e-154, 1e-300]
            ab_returned = yorkfit(x, y, sigx, sigy, 0);
            testCase.verifyEqual(ab_returned, ab_expected, 'AbsTol', tol)
         end

         % Both errors tiny and equal. Equal weights with zero correlation
         % give the major axis, whose slope for these data is 1 and whose
         % intercept is 1, from the sums Sxx = Syy = 5 and Sxy = 4 about the
         % means (1.5, 2.5).
         ab_major_expected = [1; 1];
         for sigboth = [1e-77, 1e-80, 1e-100, 1e-150]
            ab_returned = yorkfit(x, y, sigboth, sigboth, 0);
            testCase.verifyEqual(ab_returned, ab_major_expected, ...
               'AbsTol', tol)
         end
      end

      function testBothErrorsZeroAtOnePointErrors(testCase)
         % A point whose x and y are both exact has no defined York weight.
         % Every point exact is a different case: that still takes the
         % ordinary least-squares short circuit.
         x = [0; 1; 2; 3];
         y = [1; 3; 2; 4];
         sigx = [0; 0.3; 0.3; 0.3];
         sigy = [0; 0.5; 0.5; 0.5];
         errid = 'matfunclib:yorkfit:bothErrorsZero';

         testCase.verifyError(@() yorkfit(x, y, sigx, sigy, 0), errid)
      end

      function testCorrelatedZeroErrorErrors(testCase)
         % A zero-variance error has no defined correlation with anything,
         % so a nonzero rxy at a point with a zero error is contradictory.
         x = [0; 1; 2; 3];
         y = [1; 3; 2; 4];
         sigx = [0; 0.3; 0.3; 0.3];
         sigy = [0.5; 0.5; 0.5; 0.5];
         rxy = 0.5;
         errid = 'matfunclib:yorkfit:correlatedZeroError';

         testCase.verifyError(@() yorkfit(x, y, sigx, sigy, rxy), errid)
      end

      function testNonConvergenceWarnsAndReturnsLastIterate(testCase)
         % These six points with strongly correlated errors drive the
         % fixed-point iteration into a cycle it cannot leave inside the
         % 1000-iteration limit. yorkfit must say so and return the last
         % iterate rather than NaN, because a caller can still inspect it.
         x = [-10.35984778513393; 18.778654604958582; ...
            9.4070440335213181; 7.8734577993524626; ...
            -8.7587426195667248; 3.1994913438233126];
         y = [-5.5829428485090364; -3.1142941854689461; ...
            -5.7000991664218574; -10.257336156287128; ...
            -9.0874558687432518; -2.0989733405559079];
         sigx = [16.988640851726103; 6.0760057684608393; ...
            1.1779829026796245; 6.9916033464416669; ...
            2.6964864271659783; 4.9428705637941075];
         sigy = [14.831210235158988; 10.202643866829654; ...
            4.4699501174452747; 1.0965859232760262; ...
            11.287364530282829; 2.8996304180002794];
         rxy = [0.63932248311831741; 0.43628116852535559; ...
            0.93636136180172513; 0.062605145318217606; ...
            -0.34935892772252108; -0.78795285174861418];
         warnid = 'matfunclib:yorkfit:notConverged';
         maxiter_expected = 1000;

         testCase.verifyWarning(@() yorkfit(x, y, sigx, sigy, rxy), warnid)

         [ab_returned, stats_returned] = testCase.runquiet(x, y, sigx, ...
            sigy, rxy);

         testCase.verifyFalse(stats_returned.converged)
         testCase.verifyEqual(stats_returned.iter, maxiter_expected)
         testCase.verifyTrue(all(isfinite(ab_returned)))

         % The last iterate must still be self-consistent. Rebuilding the
         % York weights and means at the returned slope must reproduce the
         % returned intercept, which fails if the outputs were left at the
         % previous slope's weights. Convergence and consistency are
         % separate properties, and this data set has the second without the
         % first.
         b = ab_returned(2);
         wx = 1./sigx.^2;
         wy = 1./sigy.^2;
         W = wx.*wy./(wx + b^2*wy - 2*b*rxy.*sqrt(wx.*wy));
         a_expected = sum(W.*y)/sum(W) - b*sum(W.*x)/sum(W);
         testCase.verifyEqual(ab_returned(1), a_expected, 'RelTol', 1e-10)
      end

      function testTwoPointsReturnFitWithNaNErrorStatistics(testCase)
         % Two points determine the line exactly, so n-2 is zero and the
         % error statistics are undefined rather than unknown. The fit is
         % still correct and useful, so yorkfit warns instead of erroring.
         x = [0; 1];
         y = [0; 2];
         sigx = [0.1; 0.1];
         sigy = [0.1; 0.1];
         a_expected = 0;
         b_expected = 2;
         tol = 1e-10;
         warnid = 'matfunclib:yorkfit:zeroDegreesOfFreedom';

         testCase.verifyWarning(@() yorkfit(x, y, sigx, sigy, 0), warnid)

         [ab_returned, stats_returned] = testCase.runquiet(x, y, sigx, ...
            sigy, 0);

         % The line through the two points is still returned.
         ab_expected = [a_expected; b_expected];
         testCase.verifyEqual(ab_returned, ab_expected, 'AbsTol', tol)

         % Every quantity derived from n-2 is NaN. a_sig and b_sig are not,
         % because they come from the assigned errors rather than from the
         % degrees of freedom.
         nanstats_returned = [stats_returned.Sbar, stats_returned.a_std, ...
            stats_returned.b_std, stats_returned.a_L, stats_returned.a_H, ...
            stats_returned.b_L, stats_returned.b_H, ...
            stats_returned.a_pval, stats_returned.b_pval, ...
            stats_returned.SE, stats_returned.S_pval];
         testCase.verifyTrue(all(isnan(nanstats_returned)))
         testCase.verifyTrue(isfinite(stats_returned.a_sig))
         testCase.verifyTrue(isfinite(stats_returned.b_sig))
      end

      function testHorizontalLineHasNoXIntercept(testCase)
         % A horizontal line never crosses the x-axis, so -a/b is not an
         % x-intercept. It is also constant, so the weighted correlation of
         % y with yhat is undefined; the fit explains none of the variance
         % in y, which is rsq = 0.
         x = [0; 1; 2; 3];
         y = [1; 1; 1; 1];
         sigx = 0.1;
         sigy = 0.1;
         b_expected = 0;
         xint_expected = NaN;
         rsq_expected = 0;
         tol = 1e-12;

         [~, stats_returned] = yorkfit(x, y, sigx, sigy, 0);

         testCase.verifyEqual(stats_returned.b, b_expected, 'AbsTol', tol)
         testCase.verifyEqual(stats_returned.xintercept, xint_expected)
         testCase.verifyEqual(stats_returned.rsq, rsq_expected, ...
            'AbsTol', tol)
      end

      function testWeightedFitStatistics(testCase)
         % rsq, SSE and SE describe the weighted fit that was performed, so
         % they use the York weights. With markedly nonuniform weights the
         % weighted values differ from the unweighted ones, which is what
         % makes this test meaningful.
         [x, y, sigx, sigy] = testYorkfit.pearsondata();
         N = numel(x);
         tol = 1e-12;

         [~, stats_returned] = yorkfit(x, y, sigx, sigy, 0);

         % SSE is the weighted residual sum, which is York's S.
         testCase.verifyEqual(stats_returned.SSE, stats_returned.S, ...
            'AbsTol', tol)
         SE_expected = sqrt(stats_returned.S/(N - 2));
         testCase.verifyEqual(stats_returned.SE, SE_expected, ...
            'AbsTol', tol)

         % The unweighted residual sum differs, so the weighting is real.
         SSE_unweighted = sum(stats_returned.resids.^2);
         testCase.verifyNotEqual(stats_returned.SSE, SSE_unweighted)

         % rsq is the weighted squared correlation of y with yhat. The
         % oracle rebuilds it from the weights implied by cov_ab and the
         % returned residuals is not available, so rebuild the weights from
         % the Appendix-free general expression at the returned slope.
         b = stats_returned.b;
         W = (1./sigx.^2).*(1./sigy.^2) ...
            ./((1./sigx.^2) + b^2*(1./sigy.^2));
         sumW = sum(W);
         dY = y - sum(W.*y)/sumW;
         dH = stats_returned.yhat - sum(W.*stats_returned.yhat)/sumW;
         rsq_expected = sum(W.*dY.*dH)^2 ...
            /(sum(W.*dY.*dY)*sum(W.*dH.*dH));
         testCase.verifyEqual(stats_returned.rsq, rsq_expected, ...
            'AbsTol', tol)

         % The unweighted squared correlation differs.
         rsq_unweighted = corr(y, stats_returned.yhat)^2;
         testCase.verifyNotEqual(stats_returned.rsq, rsq_unweighted)
      end

      function testStatsFieldsIdenticalOnEveryPath(testCase)
         % A caller must not have to guess which struct shape a call
         % returns. The iterative path and both ordinary least-squares
         % short circuits must agree, field for field and in order.
         [x, y, sigx, sigy] = testYorkfit.pearsondata();

         [~, stats_iterative] = yorkfit(x, y, sigx, sigy, 0);
         [~, stats_zeroerrors] = testCase.runquiet([0; 1; 2; 3], ...
            [1; 3; 2; 4], 0, 0, 0);
         [~, stats_zerodenominator] = testCase.runquiet([0; 1], [0; 1], ...
            1, 1, 1);

         fields_expected = fieldnames(stats_iterative);
         testCase.verifyEqual(fieldnames(stats_zeroerrors), ...
            fields_expected)
         testCase.verifyEqual(fieldnames(stats_zerodenominator), ...
            fields_expected)
      end

      function testExactLineFourInputs(testCase)
         % Points on the line y = 1 + 2x have zero residuals, so the York
         % fit returns the line for any weights. With zero residuals, York
         % et al. (2004) step 4 gives beta_i = U_i. The step 8 adjusted
         % points equal the data, sigma_b = 1/sqrt(sum(W U^2)), and
         % sigma_a = sqrt(1/sum(W) + Xbar^2 sigma_b^2). Four inputs set rxy
         % to zero. The x values are unsorted to test xfit.
         x = [2; 0; 3; 1];
         a_expected = 1;
         b_expected = 2;
         y = a_expected + b_expected*x;
         sigx = [1; 2; 1; 2];
         sigy = [1; 1; 2; 2];
         tol = 1e-10;
         warnid = 'matfunclib:yorkfit:defaultErrorCorrelation';

         % Four inputs warn that the error covariance is set to zero.
         testCase.verifyWarning(@() yorkfit(x, y, sigx, sigy), warnid)

         [ab_returned, stats_returned] = testCase.runquiet(x, y, sigx, ...
            sigy);

         % The fit recovers the exact line.
         ab_expected = [a_expected; b_expected];
         testCase.verifyEqual(ab_returned, ab_expected, 'AbsTol', tol)

         % Hand-derived sigma values for rxy = 0 and exact data.
         wx = 1./sigx.^2;
         wy = 1./sigy.^2;
         W = wx.*wy./(wx + b_expected^2*wy);
         xbar = sum(W.*x)/sum(W);
         U = x - xbar;
         b_sig_expected = 1/sqrt(sum(W.*U.^2));
         a_sig_expected = sqrt(1/sum(W) + xbar^2*b_sig_expected^2);
         testCase.verifyEqual(stats_returned.b_sig, b_sig_expected, ...
            'AbsTol', tol)
         testCase.verifyEqual(stats_returned.a_sig, a_sig_expected, ...
            'AbsTol', tol)

         % Zero residuals make S, Sbar, SSE and SE zero. a_std and b_std do
         % not collapse with them: the scaling multiplier never falls below
         % 1, so they stay at a_sig and b_sig. The intervals are therefore
         % the assigned-error intervals, not zero-width.
         zerostats_returned = [stats_returned.S, stats_returned.Sbar, ...
            stats_returned.SSE, stats_returned.SE];
         zerostats_expected = zeros(1, 4);
         testCase.verifyEqual(zerostats_returned, zerostats_expected, ...
            'AbsTol', tol)
         testCase.verifyEqual(stats_returned.a_std, a_sig_expected, ...
            'AbsTol', tol)
         testCase.verifyEqual(stats_returned.b_std, b_sig_expected, ...
            'AbsTol', tol)

         % For n-2 = 2 degrees of freedom the Student t CDF has the closed
         % form F(t) = 1/2 + t/(2 sqrt(2 + t^2)), so the two-sided p-value
         % is 1 - |t|/sqrt(2 + t^2). a_std equals a_sig here, so the
         % p-values are unchanged by the scaling rule.
         t_c_expected = tinv(0.975, 2);
         a_ci_tol = tol*(1 + t_c_expected);
         testCase.verifyEqual(stats_returned.a_L, ...
            a_expected - t_c_expected*a_sig_expected, 'AbsTol', a_ci_tol)
         testCase.verifyEqual(stats_returned.a_H, ...
            a_expected + t_c_expected*a_sig_expected, 'AbsTol', a_ci_tol)
         t_a = a_expected/a_sig_expected;
         t_b = b_expected/b_sig_expected;
         a_pval_expected = 1 - abs(t_a)/sqrt(2 + t_a^2);
         b_pval_expected = 1 - abs(t_b)/sqrt(2 + t_b^2);
         testCase.verifyEqual(stats_returned.a_pval, a_pval_expected, ...
            'AbsTol', tol)
         testCase.verifyEqual(stats_returned.b_pval, b_pval_expected, ...
            'AbsTol', tol)

         % Fitted, sorted, residual, and adjusted values follow from exact
         % data.
         resids_expected = zeros(size(x));
         testCase.verifyEqual(stats_returned.resids, resids_expected, ...
            'AbsTol', tol)
         yhat_expected = y;
         testCase.verifyEqual(stats_returned.yhat, yhat_expected, ...
            'AbsTol', tol)
         xfit_expected = [0; 1; 2; 3];
         testCase.verifyEqual(stats_returned.xfit, xfit_expected)
         yfit_expected = a_expected + b_expected*xfit_expected;
         testCase.verifyEqual(stats_returned.yfit, yfit_expected, ...
            'AbsTol', tol)
         xadj_expected = x;
         testCase.verifyEqual(stats_returned.xadj, xadj_expected, ...
            'AbsTol', tol)
         yadj_expected = y;
         testCase.verifyEqual(stats_returned.yadj, yadj_expected, ...
            'AbsTol', tol)
         rsq_expected = 1;
         testCase.verifyEqual(stats_returned.rsq, rsq_expected, ...
            'AbsTol', tol)
         xint_expected = -a_expected/b_expected;
         testCase.verifyEqual(stats_returned.xintercept, xint_expected, ...
            'AbsTol', tol)

         % The model description and function handle evaluate the same
         % line.
         func_expected = 'y=a+b*x';
         testCase.verifyEqual(stats_returned.func, func_expected)
         xeval = 5;
         fnc_expected = a_expected + b_expected*xeval;
         testCase.verifyEqual(stats_returned.fnc(xeval), fnc_expected, ...
            'AbsTol', tol)
      end

      function testUnitWeightsMajorAxis(testCase)
         % Scalar unit errors with four inputs set rxy to 0. York regression
         % with equal unit weights and zero correlation is major-axis
         % (orthogonal) regression:
         % b = (Syy - Sxx + sqrt((Syy - Sxx)^2 + 4 Sxy^2))/(2 Sxy).
         % For these data, hand-computed sums about the means (1.5, 2.5) are
         % Sxx = 5, Syy = 5, and Sxy = 4.
         x = [0; 1; 2; 3];
         y = [1; 3; 2; 4];
         sigx = 1;
         sigy = 1;
         Sxx = 5;
         Syy = 5;
         Sxy = 4;
         xmean = 1.5;
         ymean = 2.5;
         tol = 1e-12;
         b_expected = (Syy - Sxx + sqrt((Syy - Sxx)^2 + 4*Sxy^2))/(2*Sxy);
         a_expected = ymean - b_expected*xmean;

         ab_returned = testCase.runquiet(x, y, sigx, sigy);

         ab_expected = [a_expected; b_expected];
         testCase.verifyEqual(ab_returned, ab_expected, 'AbsTol', tol)
      end

      function testZeroErrorsReturnOLS(testCase, orientation)
         % Zero errors in x and y short-circuit to ordinary least squares
         % with a warning, for column and row vectors. Hand-computed OLS for
         % these data: Sxy = 4, Sxx = 5, so b = 0.8 and
         % a = 2.5 - 0.8*1.5 = 1.3. The residuals are [-0.3; 0.9; -0.9; 0.3]
         % so SSE = 1.8 and s^2 = 0.9.
         x = reshape([0, 1, 2, 3], orientation);
         y = reshape([1, 3, 2, 4], orientation);
         sigx = 0;
         sigy = 0;
         N = 4;
         Sxx = 5;
         Sxy = 4;
         Syy = 5;
         xmean = 1.5;
         ymean = 2.5;
         tol = 1e-12;
         warnid = 'matfunclib:yorkfit:zeroErrors';
         b_expected = Sxy/Sxx;
         a_expected = ymean - b_expected*xmean;
         s2_expected = 1.8/(N - 2);

         testCase.verifyWarning(@() yorkfit(x, y, sigx, sigy), warnid)

         [ab_returned, stats_returned] = testCase.runquiet(x, y, sigx, ...
            sigy);

         ab_expected = [a_expected; b_expected];
         testCase.verifyEqual(ab_returned, ab_expected, 'AbsTol', tol)
         testCase.verifyEqual(stats_returned.a, a_expected, 'AbsTol', tol)
         testCase.verifyEqual(stats_returned.b, b_expected, 'AbsTol', tol)

         % Ordinary least squares has no assigned errors, so its standard
         % errors come from the residual scatter and a_sig equals a_std.
         b_sig_expected = sqrt(s2_expected/Sxx);
         a_sig_expected = sqrt(s2_expected*(1/N + xmean^2/Sxx));
         testCase.verifyEqual(stats_returned.b_sig, b_sig_expected, ...
            'AbsTol', tol)
         testCase.verifyEqual(stats_returned.a_sig, a_sig_expected, ...
            'AbsTol', tol)
         testCase.verifyEqual(stats_returned.a_std, a_sig_expected, ...
            'AbsTol', tol)
         testCase.verifyEqual(stats_returned.b_std, b_sig_expected, ...
            'AbsTol', tol)

         % Unit weights make S the residual sum of squares, and rsq the
         % ordinary squared correlation Sxy^2/(Sxx*Syy).
         testCase.verifyEqual(stats_returned.S, 1.8, 'AbsTol', tol)
         testCase.verifyEqual(stats_returned.Sbar, s2_expected, ...
            'AbsTol', tol)
         testCase.verifyEqual(stats_returned.rsq, Sxy^2/(Sxx*Syy), ...
            'AbsTol', tol)
         testCase.verifyEqual(stats_returned.cov_ab, ...
            -xmean*b_sig_expected^2, 'AbsTol', tol)

         % S is a chi-square variate only when the weights are inverse
         % variances, which unit weights are not.
         testCase.verifyEqual(stats_returned.S_pval, NaN)

         % Ordinary least squares treats x as exact and does not iterate.
         testCase.verifyEqual(stats_returned.xadj, x(:), 'AbsTol', tol)
         testCase.verifyEqual(stats_returned.iter, 0)
         testCase.verifyTrue(stats_returned.converged)
      end

      function testOmittedRxy(testCase, sigmapair)
         % Four inputs warn and return the same fit as five inputs with an
         % explicit zero rxy. The fnc field is a function handle, and two
         % handles from separate calls never compare equal, so the test
         % removes it.
         x = (1:6)';
         y = [1; 3; 2; 5; 4; 6];
         [sigx, sigy] = sigmapair{:};
         rxy = 0;
         warnid = 'matfunclib:yorkfit:defaultErrorCorrelation';
         [ab_expected, stats_expected] = testCase.runquiet(x, y, sigx, ...
            sigy, rxy);
         stats_expected = rmfield(stats_expected, 'fnc');

         testCase.verifyWarning(@() yorkfit(x, y, sigx, sigy), warnid)

         [ab_returned, stats_returned] = testCase.runquiet(x, y, sigx, ...
            sigy);

         testCase.verifyEqual(ab_returned, ab_expected)
         testCase.verifyEqual(rmfield(stats_returned, 'fnc'), stats_expected)
      end

      function testZeroWeightDenominatorReturnsOLS(testCase)
         % With rxy = 1, the York weight denominator is
         % wX + b^2 wY - 2 b sqrt(wX wY) = (sqrt(wX) - b sqrt(wY))^2. Two
         % points on y = x give the OLS slope b = 1 = sigY/sigX, so every
         % denominator is zero and yorkfit returns the OLS line. Five inputs
         % use the default alpha. Two points also leave n-2 = 0, so the
         % error statistics are undefined and yorkfit warns.
         x = [0; 1];
         y = [0; 1];
         sigx = 1;
         sigy = 1;
         rxy = 1;
         a_expected = 0;
         b_expected = 1;
         warnid = 'matfunclib:yorkfit:zeroDegreesOfFreedom';

         testCase.verifyWarning(@() yorkfit(x, y, sigx, sigy, rxy), warnid)

         [ab_returned, stats_returned] = testCase.runquiet(x, y, sigx, ...
            sigy, rxy);

         ab_expected = [a_expected; b_expected];
         testCase.verifyEqual(ab_returned, ab_expected)
         testCase.verifyEqual(stats_returned.a, a_expected)
         testCase.verifyEqual(stats_returned.b, b_expected)
         testCase.verifyTrue(isnan(stats_returned.Sbar))
      end

      function testInvalidRxyRejectedEvenWithZeroErrors(testCase)
         % The all-errors-zero short circuit returns before the fit runs, so
         % validation placed after it would never see a supplied rxy. An
         % invalid rxy must be rejected on every path, not only on the paths
         % that reach the iteration.
         x = [1; 2; 3];
         y = [2; 4; 7];
         sigx = 0;
         sigy = 0;

         testCase.verifyError(@() yorkfit(x, y, sigx, sigy, NaN), ...
            'MATLAB:yorkfit:expectedNonNaN')
         testCase.verifyError(@() yorkfit(x, y, sigx, sigy, 5), ...
            'MATLAB:yorkfit:notLessEqual')
         testCase.verifyError(@() yorkfit(x, y, sigx, sigy, [0; 0]), ...
            'matfunclib:yorkfit:inconsistentSize')
      end

      function testWidelySeparatedErrorScales(testCase)
         % Selecting the weight form by sigY == 0 alone squares the larger
         % error ratio, which overflows long before either weight does. With
         % sigX = 1e80 and sigY = 1e-80 both weights are finite and the
         % reciprocal ratio is finite, but ratioXY^2 is Inf. The y values are
         % effectively exact at that scale, so the fit must approach the
         % mirror limit: weighted least squares of x on y, read back as a
         % line in y.
         x = [0; 1; 2; 3];
         y = [1; 3; 2; 4];
         sigx = 1e80;
         sigy = 1e-80;
         tol = 1e-8;

         cd_expected = lscov([ones(4, 1), y], x, ones(4, 1));
         ab_expected = [-cd_expected(1)/cd_expected(2); 1/cd_expected(2)];

         ab_returned = yorkfit(x, y, sigx, sigy, 0);

         testCase.verifyEqual(ab_returned, ab_expected, 'AbsTol', tol)
      end

      function testRsqIsInvariantToWeightScale(testCase)
         % A squared correlation does not change when every weight is
         % multiplied by the same number. Forming the moments from
         % unnormalized weights overflows for very small errors: weights
         % near 1e200 send both the numerator and the denominator to Inf and
         % rsq to NaN, even though the slope and intercept come back finite.
         x = [0; 1; 2; 3];
         y = [1; 3; 2; 4];
         tol = 1e-10;

         % equal errors give equal weights, so rsq reduces to the ordinary
         % squared correlation. Sxy = 4, Sxx = 5 and Syy = 5 about the means
         % (1.5, 2.5), so rsq is 16/25.
         rsq_expected = 0.64;

         for sigboth = [1, 1e-50, 1e-100, 1e-150]
            [~, stats_returned] = yorkfit(x, y, sigboth, sigboth, 0);
            testCase.verifyEqual(stats_returned.rsq, rsq_expected, ...
               'AbsTol', tol)
         end
      end

      function testPvaluesSurviveTheUpperTail(testCase)
         % Writing a p-value as 1 - cdf rounds everything below about 1e-16
         % to zero, which is exactly the range a highly significant fit
         % lands in. The upper-tail form keeps the value. These points lie
         % on an exact line with small assigned errors, so the slope is
         % significant far beyond the resolution of the subtraction.
         x = (1:12)';
         y = 1 + 2*x;
         sigx = 1e-3;
         sigy = 1e-3;
         N = numel(x);

         [~, stats_returned] = yorkfit(x, y, sigx, sigy, 0);

         % positive, not rounded to zero, and matching the upper-tail form
         testCase.verifyGreaterThan(stats_returned.b_pval, 0)
         b_pval_expected = 2*tcdf(abs(stats_returned.b/ ...
            stats_returned.b_std), N - 2, 'upper');
         testCase.verifyEqual(stats_returned.b_pval, b_pval_expected)
         testCase.verifyEqual(1 - tcdf(abs(stats_returned.b/ ...
            stats_returned.b_std), N - 2), 0)
      end

      function testSpvalSurvivesTheUpperTail(testCase)
         % The same underflow applies to S_pval, and a poor fit is precisely
         % where a caller needs it. gammainc is the independent oracle: the
         % chi-square upper tail on nu degrees of freedom is
         % gammainc(S/2, nu/2, 'upper').
         x = (1:10)';
         y = [0; 40; 5; 45; 10; 50; 15; 55; 20; 60];
         sigx = 1e-2;
         sigy = 1e-2;
         N = numel(x);

         [~, stats_returned] = yorkfit(x, y, sigx, sigy, 0);

         S_pval_expected = gammainc(stats_returned.S/2, (N - 2)/2, 'upper');
         testCase.verifyEqual(stats_returned.S_pval, S_pval_expected, ...
            'RelTol', 1e-10)
         testCase.verifyGreaterThan(stats_returned.S, 1e3)
         testCase.verifyEqual(1 - chi2cdf(stats_returned.S, N - 2), 0)
      end

      function testZeroSeedSlopeWithAnExactYValue(testCase)
         % An exact y value makes its step-3 weight proportional to 1/b^2,
         % so an ordinary least-squares seed of exactly zero makes every
         % weight infinite before the first iteration. These four points
         % produce that seed exactly, and their York solution is finite. The
         % reverse regression of x on y cannot rescue the seed, because it
         % shares the same cross-product and is zero whenever the forward one
         % is. The oracle minimizes the York weighted sum of squares over the
         % slope, scanning a grid to choose a starting point before
         % refining it with fminsearch.
         x = [-1; 0; 1; 2];
         y = [0; 0; -3; 1];
         sigx = 0.2*ones(4, 1);
         sigy = [0; 0.4; 0.4; 0.4];
         tol = 1e-3;

         % the premise: the seed really is exactly zero
         M = [ones(4, 1), x]\y;
         testCase.verifyEqual(M(2), 0)

         wx = 1./sigx.^2;
         wy = 1./sigy.^2;

         % scan a grid before refining. The weighted sum of squares can hold
         % more than one local minimum, so an oracle that refines from a
         % single arbitrary start can settle in the wrong basin and agree
         % with a wrong answer.
         bgrid = linspace(-30, 30, 60001);
         [~, kbest] = min(arrayfun(@weightedsumsquares, bgrid));
         b_expected = fminsearch(@weightedsumsquares, bgrid(kbest));
         a_expected = intercept(b_expected);

         [ab_returned, stats_returned] = yorkfit(x, y, sigx, sigy, 0);

         testCase.verifyTrue(stats_returned.converged)
         testCase.verifyEqual(ab_returned(2), b_expected, 'AbsTol', tol)
         testCase.verifyEqual(ab_returned(1), a_expected, 'AbsTol', tol)

         function S = weightedsumsquares(b)
            % York weighted sum of squares at the slope b, with the
            % Appendix D limit at the exact y value. fminsearch minimizes
            % this, which is the definition the iteration solves.
            W = yorkweight(b);
            if ~all(isfinite(W))
               S = Inf;
               return
            end
            a = sum(W.*y)/sum(W) - b*sum(W.*x)/sum(W);
            S = sum(W.*(y - a - b*x).^2);
         end

         function a = intercept(b)
            % Weighted-mean intercept at the slope b, York step 7.
            W = yorkweight(b);
            a = sum(W.*y)/sum(W) - b*sum(W.*x)/sum(W);
         end

         function W = yorkweight(b)
            % York step-3 weights for uncorrelated errors, with the
            % Appendix D mirror limit where the y error is zero.
            W = wx.*wy./(wx + b^2*wy);
            W(sigy == 0) = wx(sigy == 0)./b.^2;
         end
      end

      function testTwoLocalMinimaPicksTheSmallerSum(testCase)
         % The weighted sum of squares holds two local minima for these
         % points, and the iteration stays in the basin of its seed. The
         % degenerate seed carries no sign, so yorkfit must try both signs
         % and keep the smaller sum rather than reporting whichever one the
         % positive seed reaches. Here the positive seed converges to
         % b = 1.5889 with S = 53.70, and the negative seed to b = -0.6406
         % with S = 30.92, so the negative root is the answer.
         x = [-1; 0; 1; 2];
         y = [0; 0; -3; 1];
         sigx = [0.1; 0.1; 1; 10];
         sigy = [0; 0.1; 0.1; 0.1];
         wx = 1./sigx.^2;
         wy = 1./sigy.^2;
         tol = 1e-3;

         % the premise: the seed is exactly zero and two minima exist
         M = [ones(4, 1), x]\y;
         testCase.verifyEqual(M(2), 0)
         bgrid = linspace(-30, 30, 60001);
         Sgrid = arrayfun(@weightedsumsquares, bgrid);
         turning = diff(sign(diff(Sgrid)));
         testCase.verifyEqual(nnz(turning > 0), 2)

         [~, kbest] = min(Sgrid);
         b_expected = fminsearch(@weightedsumsquares, bgrid(kbest));
         S_expected = weightedsumsquares(b_expected);

         [ab_returned, stats_returned] = yorkfit(x, y, sigx, sigy, 0);

         testCase.verifyTrue(stats_returned.converged)
         testCase.verifyEqual(ab_returned(2), b_expected, 'AbsTol', tol)
         testCase.verifyEqual(stats_returned.S, S_expected, 'RelTol', tol)

         % the answer must be the smaller of the two minima, not the other
         testCase.verifyLessThan(ab_returned(2), 0)

         function S = weightedsumsquares(b)
            % York weighted sum of squares at the slope b, with the
            % Appendix D mirror limit where the y error is zero.
            W = wx.*wy./(wx + b^2*wy);
            W(sigy == 0) = wx(sigy == 0)./b.^2;
            if ~all(isfinite(W))
               S = Inf;
               return
            end
            a = sum(W.*y)/sum(W) - b*sum(W.*x)/sum(W);
            S = sum(W.*(y - a - b*x).^2);
         end
      end

      function testCorrelatedErrorsConvergedFit(testCase)
         % A converged fit with a nonzero rxy, checked against the York
         % objective minimized directly. Without this the only nonzero-rxy
         % fixture in the suite is the non-convergence case, and deleting
         % the correlation term from the step-4 beta would still leave that
         % one cycling for its full 1000 iterations and passing.
         x = [1; 2; 3; 4; 5; 6];
         y = [2.1; 3.9; 6.2; 7.8; 10.3; 11.9];
         sigx = [0.2; 0.3; 0.25; 0.4; 0.3; 0.2];
         sigy = [0.5; 0.4; 0.6; 0.3; 0.5; 0.4];
         rxy = 0.6*ones(6, 1);
         wx = 1./sigx.^2;
         wy = 1./sigy.^2;
         tol = 1e-4;

         % Minimize the York weighted sum of squares over the slope, which
         % is the quantity the iteration solves, using a grid scan before
         % fminsearch so the oracle cannot settle in a wrong basin.
         bgrid = linspace(-10, 10, 40001);
         [~, kbest] = min(arrayfun(@weightedsumsquares, bgrid));
         b_expected = fminsearch(@weightedsumsquares, bgrid(kbest));
         S_expected = weightedsumsquares(b_expected);

         [ab_returned, stats_returned] = yorkfit(x, y, sigx, sigy, rxy);

         testCase.verifyTrue(stats_returned.converged)
         testCase.verifyEqual(ab_returned(2), b_expected, 'AbsTol', tol)
         testCase.verifyEqual(stats_returned.S, S_expected, 'RelTol', tol)

         % The correlation term must reach the answer. The same data with
         % rxy = 0 gives a different slope, so a fit that dropped the term
         % would not match the oracle above.
         ab_uncorrelated = testCase.runquiet(x, y, sigx, sigy, 0);
         testCase.verifyNotEqual(ab_returned(2), ab_uncorrelated(2))

         function S = weightedsumsquares(b)
            % York weighted sum of squares at the slope b, correlated form.
            % A nonpositive weight means the slope is outside the range the
            % assigned correlation admits, so exclude it from the search.
            W = wx.*wy./(wx + b^2*wy - 2*b*rxy.*sqrt(wx.*wy));
            if ~all(isfinite(W)) || any(W <= 0)
               S = Inf;
               return
            end
            a = sum(W.*y)/sum(W) - b*sum(W.*x)/sum(W);
            S = sum(W.*(y - a - b*x).^2);
         end
      end

      function testOneCandidateSeedSingularTheOtherConverges(testCase)
         % The degenerate seed tries both signs, and one of them can pass
         % through a slope where a weight is unbounded while the other does
         % not. A failure must disqualify that candidate alone.
         %
         % These points give an ordinary least-squares slope of exactly
         % zero, so the spread seed applies, and point 2 is tuned so that its
         % step-3 denominator 1 + b^2*q^2 - 2*b*rxy*q vanishes exactly at the
         % positive seed and equals 4 at the negative one. Without the
         % per-candidate isolation the positive seed aborts the whole call.
         x = [-1; 0; 1; 2];
         y = [0; 0; -3; 1];
         spread = std(y)/std(x);
         sigx = [0.1; 0.5/spread; 0.3; 0.4];
         sigy = [0; 0.5; 0.3; 0.4];
         rxy = [0; 1; 0; 0];
         wx = 1./sigx.^2;
         wy = 1./sigy.^2;
         tol = 1e-4;

         % the premise: exactly zero seed, and one signed seed is singular
         M = [ones(4, 1), x]\y;
         testCase.verifyEqual(M(2), 0)
         q = sigx(2)/sigy(2);
         testCase.verifyEqual(1 + spread^2*q^2 - 2*spread*q, 0, ...
            'AbsTol', 1e-12)

         bgrid = linspace(-15, 15, 60001);
         [~, kbest] = min(arrayfun(@weightedsumsquares, bgrid));
         b_expected = fminsearch(@weightedsumsquares, bgrid(kbest));

         [ab_returned, stats_returned] = yorkfit(x, y, sigx, sigy, rxy);

         testCase.verifyTrue(stats_returned.converged)
         testCase.verifyEqual(ab_returned(2), b_expected, 'AbsTol', tol)

         function S = weightedsumsquares(b)
            % York weighted sum of squares at the slope b, with the
            % Appendix D mirror limit where the y error is zero.
            W = wx.*wy./(wx + b^2*wy - 2*b*rxy.*sqrt(wx.*wy));
            W(sigy == 0) = wx(sigy == 0)./b.^2;
            if ~all(isfinite(W)) || any(W <= 0)
               S = Inf;
               return
            end
            a = sum(W.*y)/sum(W) - b*sum(W.*x)/sum(W);
            S = sum(W.*(y - a - b*x).^2);
         end
      end

      function testConvergedCandidateOutranksACyclingOne(testCase)
         % A candidate that reaches the iteration limit stopped at an
         % arbitrary point of its cycle, so its weighted sum of squares
         % describes that point rather than a solution. It must not displace
         % a candidate that converged, even when its sum is smaller.
         %
         % These points give an ordinary least-squares slope of exactly
         % zero, so both signs of the spread seed are tried. The positive
         % seed cycles to the limit and stops at b = 2.7987 with S = 4.2804.
         % The negative seed converges to b = -0.6964 with S = 6.2282.
         % Ranking on S alone would return the cycling result.
         x = [-1; 0; 1; 2];
         y = [0; 0; -3; 1];
         sigx = [1.5029021671326519; 1.0758253178896209; ...
            0.98486143746080634; 0.15590153601276011];
         sigy = [0; 4.0610100057324647; 0.66878899817684967; ...
            1.3753557170281363];
         rxy = [0; 0.27642617615128545; 0.75450694766271087; ...
            0.3418487704073746];
         b_expected = -0.696419;
         S_expected = 6.228157;
         b_cycling = 2.798728;
         S_cycling = 4.280435;
         tol = 1e-5;

         % the premise: the seed is exactly zero, so both signs are tried
         M = [ones(4, 1), x]\y;
         testCase.verifyEqual(M(2), 0)

         [ab_returned, stats_returned] = yorkfit(x, y, sigx, sigy, rxy);

         % the converged root is returned, not the cycling last iterate
         testCase.verifyTrue(stats_returned.converged)
         testCase.verifyEqual(ab_returned(2), b_expected, 'AbsTol', tol)
         testCase.verifyEqual(stats_returned.S, S_expected, 'RelTol', tol)

         % the premise that makes this test discriminating: the rejected
         % candidate really does have the smaller sum
         testCase.verifyLessThan(S_cycling, S_expected)
         testCase.verifyNotEqual(ab_returned(2), b_cycling)
      end

      function testNearSingularDenominatorStaysReal(testCase)
         % At rxy = +-1 the step-3 denominator is a perfect square, so it can
         % never be negative. Computing it as the expanded quadratic
         % 1 + b^2*q^2 - 2*b*r*q loses that guarantee: when the slope nearly
         % matches the ratio of the errors the expansion cancels and rounds
         % below zero. A negative denominator gives a negative weight, and
         % the standard errors then come back complex with no error raised,
         % which is the worst way to be wrong.
         %
         % These points lie on y = 7x, and sigX is chosen so that
         % 7*sigX/sigY is 1 to within rounding. The expanded form evaluates
         % to -2.22e-16 here; the sum-of-squares form gives +4.12e-17.
         x = [-1; -1; 1; 1];
         y = 7*x;
         sigx = 0.14285714194003854;
         sigy = 1;
         rxy = 1;

         % the premise: the expanded quadratic really does round negative
         q = sigx/sigy;
         b = 7;
         expanded_returned = 1 + b^2*q^2 - 2*b*rxy*q;
         testCase.verifyLessThan(expanded_returned, 0)
         factored_expected = (1 - b*rxy*q)^2 + b^2*q^2*(1 - rxy^2);
         testCase.verifyGreaterThanOrEqual(factored_expected, 0)

         [ab_returned, stats_returned] = testCase.runquiet(x, y, sigx, ...
            sigy, rxy);

         % every returned quantity must be real
         testCase.verifyTrue(isreal(ab_returned))
         testCase.verifyTrue(isreal(stats_returned.a_sig))
         testCase.verifyTrue(isreal(stats_returned.b_sig))
         testCase.verifyTrue(isreal(stats_returned.a_std))
         testCase.verifyTrue(isreal(stats_returned.a_L))
         testCase.verifyTrue(isreal(stats_returned.a_H))
         testCase.verifyTrue(isreal(stats_returned.S))

         % the fit itself is the exact line
         testCase.verifyEqual(ab_returned, [0; 7], 'AbsTol', 1e-8)

         % Realness alone does not catch the matching cancellation in the
         % York step-4 bracket, which is sigY^2 + b^2*sigX^2 - 2*b*sigX*sigY
         % here and rounds to the wrong sign. With zero residuals step 4
         % gives beta proportional to U, so the adjusted x values must equal
         % the observed ones, and sigma_b must be sqrt(denom)/2 for these
         % four symmetric points. Both fail when the bracket is left
         % expanded.
         %
         % The tolerance reflects what the arithmetic can deliver here, not
         % what it could on ordinary data. The root of the denominator is
         % 6.4e-9 formed from operands near 1, so its relative accuracy is
         % about 1e-16/6.4e-9, and everything downstream inherits that. The
         % point of the check is the sign and the magnitude: before the
         % grouping, xadj came back as [5.39; 5.39; -5.39; -5.39].
         testCase.verifyEqual(stats_returned.xadj, x, 'AbsTol', 1e-7)
         testCase.verifyEqual(stats_returned.yadj, y, 'AbsTol', 1e-6)
         b_sig_expected = sqrt(factored_expected)/2;
         testCase.verifyEqual(stats_returned.b_sig, b_sig_expected, ...
            'RelTol', 1e-6)
      end

      function testRoundedSingularityTakesTheShortCircuit(testCase)
         % With rxy = 1 the York denominator vanishes at the slope
         % sigY/sigX, and the ordinary least-squares seed reaches that slope
         % only to within rounding. Here the seed is 0.49999999999999994
         % against a singular slope of exactly 0.5, so its denominator is
         % about 3e-33 rather than 0. Testing the denominator against exact
         % zero misses this: the next iterate lands on the singularity and
         % the fit fails instead of returning the documented ordinary
         % least-squares line.
         x = (0:3)';
         y = 1 + 0.5*x;
         sigx = 2;
         sigy = 1;
         rxy = 1;
         a_expected = 1;
         b_expected = 0.5;

         % the premise: the seed is near the singular slope but not on it
         M = [ones(4, 1), x]\y;
         testCase.verifyNotEqual(M(2), sigy/sigx)
         testCase.verifyEqual(M(2), sigy/sigx, 'AbsTol', 1e-15)

         [ab_returned, stats_returned] = testCase.runquiet(x, y, sigx, ...
            sigy, rxy);

         testCase.verifyEqual(ab_returned, [a_expected; b_expected], ...
            'AbsTol', 1e-12)

         % iter = 0 confirms the short circuit ran rather than the iteration
         testCase.verifyEqual(stats_returned.iter, 0)
      end

      function testOneSingularPointIsNotTheDegenerateCase(testCase)
         % The ordinary least-squares fallback is for the case where one slope
         % zeroes every denominator at once. A single singular point among
         % ordinary ones is not that case, so yorkfit must report the singular
         % weight rather than quietly substituting an unweighted line.
         %
         % These two points put the ordinary least-squares seed exactly on the
         % singular slope of the first point and nowhere near the second. Each
         % denominator vanishes at sigY/(rxy*sigX), which is 0.5 and 1 here, so
         % no single slope is degenerate. Every candidate therefore fails, and
         % the gate must refuse the fallback and rethrow. Before the gate
         % required a shared singular slope, this call returned the unweighted
         % line [0; 0.5] instead, with nothing raised.
         x = [0; 1];
         y = [0; 0.5];
         sigx = 2;
         sigy = [1; 2];
         rxy = 1;
         errid = 'matfunclib:yorkfit:unboundedWeight';

         % the premise: the seed sits exactly on one point's singular slope,
         % and the two singular slopes differ
         M = [ones(2, 1), x]\y;
         singular_returned = sigy./(rxy*sigx);
         testCase.verifyEqual(M(2), singular_returned(1))
         testCase.verifyNotEqual(singular_returned(1), singular_returned(2))

         testCase.verifyError(@() yorkfit(x, y, sigx, sigy, rxy), errid)
      end

      function testEqualQuotientsAreNotADegenerateFit(testCase)
         % The fallback gate asks whether one slope zeroes every denominator.
         % Each denominator vanishes at sigY/(rxy*sigX), but comparing those
         % quotients to each other is not the same test: distinct error ratios
         % can round to the same quotient while their denominators do not both
         % vanish.
         %
         % Here all four quotients are exactly 5, and the denominators at a
         % slope of 5 are 0, 1.23e-32, 0 and 1.23e-32. Only points 1 and 3 are
         % singular. Comparing quotients called that degenerate and returned
         % the unweighted line [-0.5; 5], which has nonzero residuals at two
         % infinite-weight points, with nothing raised.
         x = [-1; -1; 1; 1];
         y = [-15; 4; 13; -4];
         sigx = [1; 0.500005; 1; 0.500005];
         sigy = [5; 2.5000250000000004; 5; 2.5000250000000004];
         rxy = 1;
         errid = 'matfunclib:yorkfit:unboundedWeight';

         % the premise: the quotients agree exactly, the denominators do not
         quotient_returned = sigy./(rxy*sigx);
         testCase.verifyEqual(quotient_returned, 5*ones(4, 1))

         b = 5;
         ratioXY = sigx./sigy;
         useXY = ratioXY <= 1;
         denom_returned = zeros(4, 1);
         denom_returned(useXY) = (1 - rxy*b*ratioXY(useXY)).^2;
         denom_returned(~useXY) = (sigy(~useXY)./sigx(~useXY) - b*rxy).^2;
         testCase.verifyEqual(nnz(denom_returned == 0), 2)

         testCase.verifyError(@() yorkfit(x, y, sigx, sigy, rxy), errid)
      end

      function testRsqIsInvariantToDataScale(testCase)
         % The squared correlation does not change when y is multiplied by a
         % constant, but forming its moments from unscaled data does. Values
         % near 1e80 send every term to Inf and rsq to NaN, and values near
         % 1e-200 send them to zero and rsq to 0, for exact-line data whose
         % rsq is 1. Normalizing the weights alone does not fix it, because
         % the overflow is in the data.
         x = [-1; 0; 1; 2];
         sigx = 1e-100;
         sigy = 1;
         rsq_expected = 1;
         tol = 1e-12;

         for scale = [1, 1e80, 1e-80, 1e200, 1e-200]
            [~, stats_returned] = yorkfit(x, scale*x, sigx, sigy, 0);
            testCase.verifyEqual(stats_returned.rsq, rsq_expected, ...
               'AbsTol', tol)
         end
      end

      function testUnboundedWeightMessageNamesBothCauses(testCase)
         % A vanishing denominator has two causes, and the message must not
         % send the caller to change the wrong input. Here every sigY is 1,
         % so advice to make sigY nonzero would be useless: the cause is the
         % perfectly correlated first point.
         x = [-1; 0; 1];
         y = x;
         sigx = 1;
         sigy = 1;
         rxy = [1; 0; 0];
         errid = 'matfunclib:yorkfit:unboundedWeight';

         testCase.verifyError(@() yorkfit(x, y, sigx, sigy, rxy), errid)

         % verifyError does not hand back the exception, so catch it to read
         % the message
         message_returned = '';
         try
            yorkfit(x, y, sigx, sigy, rxy);
         catch err
            message_returned = err.message;
         end

         testCase.verifySubstring(message_returned, 'rxy')
         testCase.verifySubstring(message_returned, 'sigY/sigX')
      end

      function testAllExactYValuesTakeTheMirrorLimit(testCase)
         % Every y exact, with an ordinary least-squares seed of exactly
         % zero. At an exact y value the step-3 denominator is b^2, so a
         % zero seed makes every denominator zero at once. A short circuit
         % that keys on a vanishing denominator alone would fire here and
         % return the unweighted fit, whose slope is the zero seed itself.
         % The documented answer is the York (2004) Appendix D mirror limit:
         % weighted least squares of x on y, read back as a line in y.
         x = [-1; 0; 1; 2];
         y = [0; 0; -3; 1];
         sigx = [0.1; 0.1; 1; 10];
         sigy = 0;
         tol = 1e-8;

         % the premise: the seed is exactly zero
         M = [ones(4, 1), x]\y;
         testCase.verifyEqual(M(2), 0)

         cd_expected = lscov([ones(4, 1), y], x, 1./sigx.^2);
         ab_expected = [-cd_expected(1)/cd_expected(2); 1/cd_expected(2)];

         ab_returned = yorkfit(x, y, sigx, sigy, 0);

         testCase.verifyEqual(ab_returned, ab_expected, 'AbsTol', tol)

         % the unweighted fit would have returned the zero seed
         testCase.verifyNotEqual(ab_returned(2), 0)
      end

      function testConstantYWithAnExactValueIsUnbounded(testCase)
         % A constant y beside an exact y value pins a horizontal line, and
         % the York weight for that point grows without bound as the slope
         % approaches zero.
         %
         % Note: a finite limit does exist here. Replacing the zero sigY by
         % a small positive one and shrinking it converges on a = 2, b = 0.
         % yorkfit does not take that limit, and matfunclib-2td records the
         % reason as a known bound. It names the offending points and tells
         % the caller to assign a small nonzero sigY, which reaches the same
         % line. This test pins the current behavior, not an ideal one.
         x = [0; 1; 2; 3];
         y = [2; 2; 2; 2];
         sigx = 0.2;
         sigy = [0; 0.4; 0.4; 0.4];
         errid = 'matfunclib:yorkfit:unboundedWeight';

         testCase.verifyError(@() yorkfit(x, y, sigx, sigy, 0), errid)
      end

      function testTooFewInputs(testCase)
         % Fewer than four inputs raise the narginchk error.
         args = testCase.validinputs(1:3);
         errid = 'MATLAB:narginchk:notEnoughInputs';
         testCase.verifyError(@() yorkfit(args{:}), errid)
      end

      function testInvalidInput(testCase, badinput)
         % Each case makes one input invalid and keeps the other inputs
         % valid.
         [position, value, errid] = badinput{:};
         args = testCase.validinputs;
         args{position} = value;
         testCase.verifyError(@() yorkfit(args{:}), errid)
      end

      function testInvalidAlpha(testCase)
         % alpha is a significance level, so it must lie strictly inside
         % (0, 1). tinv would otherwise return Inf or NaN bounds.
         args = testCase.validinputs;
         errid = 'MATLAB:yorkfit:notLess';
         testCase.verifyError(@() yorkfit(args{:}, 1), errid)
      end
   end
end
