classdef testTrendplot < matlab.unittest.TestCase
   %TESTTRENDPLOT Unit tests for the trendplot 'ols' trend.
   %
   % trendplot fits the 'ols' trend with fitlm, coefCI, and predict. The
   % test compares the returned trend, slope error, fitted line, and bounds
   % with a LinearModel fit at the same alpha.

   properties (TestParameter)
      % The default significance level and a non-default one.
      alpha = struct('default', 0.05, 'ten', 0.1)
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so trendplot resolves from the repo
         % root without a manual addpath.
         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (Test)
      function testOlsMatchesLinearModel(testCase, alpha)
         % The 'ols' outputs equal the LinearModel values at alpha.
         t = transpose(datetime(1990:2020, 7, 1));
         y = transpose(0.3 * (1:31) + sin(1:31));
         tolerance = 1e-10;

         returned = trendplot(t, y, 'method', 'ols', 'alpha', alpha, ...
            'anomalies', false, 'showfig', false);
         testCase.addTeardown(@close, returned.figure)

         % trendplot fits against decimal years. The trend line holds them.
         tyears = reshape(get(returned.trend, 'XData'), [], 1);
         mdl = fitlm(tyears, y);
         confi = coefCI(mdl, alpha);
         ab_expected = transpose(mdl.Coefficients.Estimate);
         err_expected = confi(2, 2) - ab_expected(2);
         [yfit_expected, yci_expected] = predict(mdl, tyears, ...
            'Alpha', alpha);

         testCase.verifyEqual(returned.ab, ab_expected, 'RelTol', tolerance)
         testCase.verifyEqual(returned.err, err_expected, ...
            'RelTol', tolerance)
         testCase.verifyEqual(returned.yfit, yfit_expected, ...
            'RelTol', tolerance)
         testCase.verifyEqual(returned.yci, yci_expected, ...
            'RelTol', tolerance)
      end
   end
end
