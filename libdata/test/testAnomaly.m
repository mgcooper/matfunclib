classdef testAnomaly < matlab.unittest.TestCase
   %TESTANOMALY Unit tests for anomaly with vector data.
   %
   % anomaly gives a row vector and a column vector the same values. TIMEDIM
   % sets the output shape: TIMEDIM 1 gives columns and TIMEDIM 2 gives rows.

   properties (TestParameter)
      % The same vector data in each orientation.
      data = struct('column', [1; 2; 3; 6], 'row', [1, 2, 3, 6])
      % TIMEDIM and the function that gives the expected output shape.
      timecase = struct( ...
         'timedim1', {{1, @(v) v(:)}}, ...
         'timedim2', {{2, @(v) v(:).'}})
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so anomaly resolves from the repo
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
      function testVectorOrientation(testCase, data, timecase)
         % A row or column vector gives the same anomalies about its mean,
         % in the shape that TIMEDIM sets, with no warning.
         [timedim, toshape] = timecase{:};
         norms_expected = 3;
         anoms_expected = toshape([-2, -1, 0, 3]);
         pctdif_expected = 100 * (anoms_expected ./ norms_expected);
         pctanom_expected = 100 + pctdif_expected;

         testCase.verifyWarningFree(@() anomaly(data, [], timedim))
         [anoms_returned, norms_returned, pctdif_returned, ...
            pctanom_returned] = anomaly(data, [], timedim);

         testCase.verifyEqual(anoms_returned, anoms_expected)
         testCase.verifyEqual(norms_returned, norms_expected)
         testCase.verifyEqual(pctdif_returned, pctdif_expected)
         testCase.verifyEqual(pctanom_returned, pctanom_expected)
      end
   end
end
