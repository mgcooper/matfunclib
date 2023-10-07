function tests = test_bootdraws
   %TEST_BOOTDRAWS Test performance of random draws for bootstrapping.
   tests = functiontests(localfunctions);
end

% Set-up function to initialize data.
function testCase = setup(testCase)
   
   % Create test data
   L = 1000;   % number of data points in each dataset
   M = 10;     % number of datasets
   N = 10000;  % number of bootstrap samples
   
   data = arrayfun(@(x) randn(L, 1), 1:M, 'UniformOutput', false);
   stat = zeros(N, M);

   testCase.TestData.N = N;
   testCase.TestData.L = L;
   testCase.TestData.data = data;
   testCase.TestData.stat = stat;
end

function test_drawEachIteration(testCase)
   data = testCase.TestData.data;
   nboot = testCase.TestData.N;
   nsamp = testCase.TestData.L;
   for m = 1:numel(data)
      for n = 1:nboot
         testCase.TestData.stat(n, m) = median( data{m}(randi(nsamp, [1 nsamp])) );
      end
   end
end

function test_preallocateDraws(testCase)
   data = testCase.TestData.data;
   nboot = testCase.TestData.N;
   nsamp = testCase.TestData.L;
   for m = 1:numel(data)
      draws = randi(nsamp, [nboot, nsamp]);
      for n = 1:nboot
         testCase.TestData.stat(n, m) = median( data{m}(draws(n, :)) );
      end
   end
end
