classdef testCcdf < matlab.unittest.TestCase
   %TESTCCDF Unit tests for the empirical complementary CDF, ccdf.
   %
   % ccdf returns 1 minus the ecdf values, packs [F X] into one array for a
   % single output, and draws the function when makeplot is true.

   properties (TestParameter)
      % The makeplot flag, including the default case, which does not plot.
      makeplot = struct('noPlot', false, 'plot', true)
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so ccdf resolves from the repo root.
         testFolder = fileparts(mfilename("fullpath"));
         projectFolder = fileparts(fileparts(testFolder));
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (Test)
      function testComplementOfEcdf(testCase, makeplot)
         %TESTCOMPLEMENTOFECDF F is 1 minus ecdf, with and without a plot.

         % Close only the figures this test opens.
         figsbefore = findall(0, 'Type', 'figure');
         testCase.addTeardown(@() close(setdiff( ...
            findall(0, 'Type', 'figure'), figsbefore)));

         data = [3; 1; 4; 1; 5; 9; 2; 6];
         [f_expected, x_expected] = ecdf(data);
         F_expected = 1 - f_expected;

         % Two outputs return F and X separately.
         [F_returned, x_returned] = ccdf(data, 'makeplot', makeplot);
         testCase.verifyEqual(F_returned, F_expected)
         testCase.verifyEqual(x_returned, x_expected)

         % makeplot true opens one figure; false opens none.
         nfigs_returned = numel(setdiff(findall(0, 'Type', 'figure'), ...
            figsbefore));
         testCase.verifyEqual(nfigs_returned, double(makeplot))
      end

      function testSingleOutput(testCase)
         %TESTSINGLEOUTPUT One output returns [F X] in one array.

         data = [3; 1; 4; 1; 5; 9; 2; 6];
         [f_expected, x_expected] = ecdf(data);
         returned = ccdf(data);
         testCase.verifyEqual(returned, [1 - f_expected, x_expected])
      end
   end
end
