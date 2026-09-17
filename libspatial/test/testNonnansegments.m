classdef testNonnansegments < matlab.unittest.TestCase
   %TESTNONNANSEGMENTS Unit tests for nonnansegments.
   %
   % Each case builds an input x and checks the segment starts S, ends E,
   % and lengths L. The vector cases cover leading, interior, and trailing
   % nans, an all-nan vector, and the nmin filter. The cell and matrix cases
   % cover the per-element and per-column outputs. The option cases check
   % 'each', 'all', and 'any' on a two-column matrix with nans in different
   % rows, and check that option has no effect on a vector. The mixed cell
   % cases check that a vector element and a matrix element of one cell array
   % get the vector and the matrix results for each option.

   properties (TestParameter)
      % Every option must give the same segments for a vector.
      option = {'each', 'all', 'any'}

      % Each value names an option and the segments of twocolumnmatrix under
      % that option. The values match the testMatrixOption cases, so a
      % matrix element of a cell array must give the same segments.
      matrixcase = struct( ...
         'each', struct('option', 'each', 'S', {{[2; 7], [3; 7]}}, ...
            'E', {{[4; 8], [5; 7]}}, 'L', {{[3; 2], [3; 1]}}), ...
         'all', struct('option', 'all', 'S', [3; 7], 'E', [4; 7], ...
            'L', [2; 1]), ...
         'any', struct('option', 'any', 'S', [2; 7], 'E', [5; 8], ...
            'L', [4; 2]))
   end

   properties
      % Several cases share these vectors, so name them once.
      fullvector = [0, 1, 2, 3]
      leftnanvector = [nan, 1, 2, 3]

      % The option cases share this matrix. Rows 1 and 6 are all nan.
      % Rows 2, 5, and 8 have a nan in one column only.
      twocolumnmatrix = [nan, nan; 1, nan; 2, 2; 3, 3; nan, 4; ...
         nan, nan; 6, 6; 7, nan]
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so nonnansegments resolves from the
         % repo root without a manual addpath.
         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (Test)
      function testNoNans(testCase)
         % A full vector is one segment.
         x = testCase.fullvector;
         S_expected = 1;
         E_expected = 4;
         L_expected = 4;
         verifySegments(testCase, x, S_expected, E_expected, L_expected)
      end

      function testInteriorNans(testCase)
         % Interior nans split the vector into two segments.
         x = [0, 1, 2, 3, nan, nan, nan, 1, 2, 3, 4];
         S_expected = [1; 8];
         E_expected = [4; 11];
         L_expected = [4; 4];
         verifySegments(testCase, x, S_expected, E_expected, L_expected)
      end

      function testLeftEdgeNan(testCase)
         % A leading nan shifts the segment start.
         x = testCase.leftnanvector;
         S_expected = 2;
         E_expected = 4;
         L_expected = 3;
         verifySegments(testCase, x, S_expected, E_expected, L_expected)
      end

      function testRightEdgeNan(testCase)
         % A trailing nan ends the segment early.
         x = [1, 2, 3, nan];
         S_expected = 1;
         E_expected = 3;
         L_expected = 3;
         verifySegments(testCase, x, S_expected, E_expected, L_expected)
      end

      function testBothEdgeNans(testCase)
         % Nans on both edges bound one interior segment.
         x = [nan, 1, 2, 3, nan];
         S_expected = 2;
         E_expected = 4;
         L_expected = 3;
         verifySegments(testCase, x, S_expected, E_expected, L_expected)
      end

      function testEdgeAndInteriorNans(testCase)
         % Edge and interior nans together produce two interior segments.
         x = [nan, 1, 2, 3, nan, nan, nan, 1, 2, 3, nan];
         S_expected = [2; 8];
         E_expected = [4; 10];
         L_expected = [3; 3];
         verifySegments(testCase, x, S_expected, E_expected, L_expected)
      end

      function testAllNanVector(testCase)
         % An all-nan vector returns empty column outputs with the default
         % nmin and with nmin = 0, which keeps every segment.
         x = [nan, nan, nan];
         S_expected = zeros(0, 1);
         E_expected = zeros(0, 1);
         L_expected = zeros(0, 1);
         verifySegments(testCase, x, S_expected, E_expected, L_expected)
         verifySegments(testCase, x, S_expected, E_expected, L_expected, 0)
      end

      function testScalarNan(testCase)
         % A scalar nan also returns empty column outputs.
         x = nan;
         S_expected = zeros(0, 1);
         E_expected = zeros(0, 1);
         L_expected = zeros(0, 1);
         verifySegments(testCase, x, S_expected, E_expected, L_expected)
      end

      function testMinimumLength(testCase)
         % nonnansegments removes segments shorter than nmin. Longer
         % segments keep their original indices.
         x = [nan, 1, nan, 2, 3, 4, nan];
         nmin = 2;
         S_expected = 4;
         E_expected = 6;
         L_expected = 3;
         verifySegments(testCase, x, S_expected, E_expected, L_expected, ...
            nmin)
      end

      function testCellInput(testCase)
         % A cell array of vectors returns cell outputs, one per element.
         x = {testCase.fullvector, testCase.leftnanvector};
         S_expected = {1, 2};
         E_expected = {4, 4};
         L_expected = {4, 3};
         verifySegments(testCase, x, S_expected, E_expected, L_expected)
      end

      function testMatrixInput(testCase)
         % A matrix returns per-column cell outputs by default.
         x = [testCase.fullvector', testCase.leftnanvector'];
         S_expected = {1, 2};
         E_expected = {4, 4};
         L_expected = {4, 3};
         verifySegments(testCase, x, S_expected, E_expected, L_expected)
      end

      function testVectorIgnoresOption(testCase, option)
         % A vector has one nan mask, so each option gives its segments.
         x = [nan, 1, 2, nan, 3];
         S_expected = [2; 5];
         E_expected = [3; 5];
         L_expected = [2; 1];
         verifySegments(testCase, x, S_expected, E_expected, L_expected, ...
            1, option)
      end

      function testMatrixOptionEach(testCase)
         % 'each' segments the columns on their own, with and without the
         % option argument.
         x = testCase.twocolumnmatrix;
         S_expected = {[2; 7], [3; 7]};
         E_expected = {[4; 8], [5; 7]};
         L_expected = {[3; 2], [3; 1]};
         verifySegments(testCase, x, S_expected, E_expected, L_expected)
         verifySegments(testCase, x, S_expected, E_expected, L_expected, ...
            1, 'each')
      end

      function testMatrixOptionAll(testCase)
         % 'all' keeps only the rows where both columns are non-nan.
         x = testCase.twocolumnmatrix;
         S_expected = [3; 7];
         E_expected = [4; 7];
         L_expected = [2; 1];
         verifySegments(testCase, x, S_expected, E_expected, L_expected, ...
            1, 'all')
      end

      function testMatrixOptionAny(testCase)
         % 'any' keeps the rows where at least one column is non-nan.
         x = testCase.twocolumnmatrix;
         S_expected = [2; 7];
         E_expected = [5; 8];
         L_expected = [4; 2];
         verifySegments(testCase, x, S_expected, E_expected, L_expected, ...
            1, 'any')
      end

      function testMatrixOptionAllMinimumLength(testCase)
         % nmin filters the row segments that 'all' returns.
         x = testCase.twocolumnmatrix;
         nmin = 2;
         S_expected = 3;
         E_expected = 4;
         L_expected = 2;
         verifySegments(testCase, x, S_expected, E_expected, L_expected, ...
            nmin, 'all')
      end

      function testCellVectorAndMatrix(testCase, matrixcase)
         % A cell array holds a vector and a matrix. The vector element
         % ignores option. The matrix element gets the matrix result for
         % the option, so its cell holds per-column cells for 'each'.
         x = {testCase.leftnanvector, testCase.twocolumnmatrix};
         S_expected = {2, matrixcase.S};
         E_expected = {4, matrixcase.E};
         L_expected = {3, matrixcase.L};
         verifySegments(testCase, x, S_expected, E_expected, L_expected, ...
            1, matrixcase.option)
      end

      function testUnknownOption(testCase)
         % An option that matches no choice is an error.
         x = testCase.twocolumnmatrix;
         testCase.verifyError(@() nonnansegments(x, 1, 'none'), ...
            "MATLAB:nonnansegments:unrecognizedStringChoice")
      end
   end

   methods (Access = private)
      function verifySegments(testCase, x, S_expected, E_expected, ...
            L_expected, varargin)
         % Compare all three outputs with the expected values. Optional
         % trailing nmin and option arguments pass through to
         % nonnansegments.
         [S_returned, E_returned, L_returned] = ...
            nonnansegments(x, varargin{:});
         returned = {S_returned, E_returned, L_returned};
         expected = {S_expected, E_expected, L_expected};
         testCase.verifyEqual(returned, expected)
      end
   end
end
