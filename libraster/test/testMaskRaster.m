classdef testMaskRaster < matlab.unittest.TestCase

   methods (Test)
      function testStandardDeviationMasking(testCase)

         % Generate random data and introduce an outlier
         data = randn(10, 10, 10);
         data(5, 5, :) = 5;
         [Z, mask, info] = maskraster(data, ...
            'MaskType', "stdv", 'sigmaThreshold', 3);

         % Test if outlier is masked
         testCase.assertTrue(isnan(Z(5, 5, 1)));

         % Check if only the outlier is masked (across all pages)
         testCase.assertEqual(sum(mask(:)), size(data, 3));

         % Validate statistics table
         testCase.assertEqual(info.NumberMasked, sum(mask(:)));
      end

      function testNoDataMasking(testCase)

         % Set noData values
         data = ones(10, 10, 10);
         data(2:4, 2:4, :) = -9999;
         [Z, mask, info] = maskraster(data, ...
            'MaskType', "nodata", 'noDataValue', -9999);

         % Test if noData values are masked
         testCase.assertTrue(all(all(all(isnan(Z(2:4, 2:4, :))))));

         % Check correct mask application
         testCase.assertTrue(all(all(all(mask(2:4, 2:4, :)))));

         % Validate statistics table
         testCase.assertEqual(info.NumberMasked, sum(mask(:)));
      end

      function testEmptyInput(testCase)
         data = [];
         [Z, mask, info] = maskraster(data, ...
            'MaskType', "stdv", 'sigmaThreshold', 3);

         % Test outputs on empty input
         testCase.assertTrue(isempty(Z));
         testCase.assertTrue(isempty(mask));
         testCase.assertEqual(info.NumberMasked, 0);
      end

      function testInputWithInfsAndNaNs(testCase)

         % Nan is implicitly handled by the stdv filter which ignores them, but
         % Inf is not, and how to test for accurate handling of nan is not clear

         % data = rand(5, 5, 5);
         % data(1:2, :, :) = Inf; % Set some Inf values
         % data(3, :, :) = NaN;  % Set some NaN values
         % [Z, mask, info] = maskraster(data, [], ...
         %    'MaskType', "stdv", 'sigmaThreshold', 2);
         %
         % % Check masking did not error out and returned a sensible mask
         % testCase.assertSize(mask, size(data));
         %
         % % At least some data should be masked
         % testCase.assertGreaterThanOrEqual(info.NumberMasked, 0);
      end

      function testUserSuppliedMask(testCase)

         data = randn(5, 5, 5);
         suppliedMask = false(size(data));
         suppliedMask(1:2, 1:2, :) = true;

         [Z, returnedMask, info] = maskraster(data, suppliedMask, ...
            'MaskType', "stdv", 'sigmaThreshold', 2);

         % Validate that initial mask is considered
         testCase.assertTrue(all(all(all(isnan(Z(1:2, 1:2, :))))));
         testCase.assertTrue(all(all(all(returnedMask(1:2, 1:2, :)))));
         testCase.assertEqual(info.NumberMasked, sum(suppliedMask(:)));
      end
   end
end
