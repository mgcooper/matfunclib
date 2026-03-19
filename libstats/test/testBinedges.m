classdef testBinedges < matlab.unittest.TestCase

   properties
      ClusteredData
      GappedData
      PositiveData
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (TestMethodSetup)
      function createTestData(testCase)
         rng(0)
         testCase.ClusteredData = [randn(250, 1); 4 + 0.4 * randn(120, 1)];
         testCase.GappedData = [zeros(40, 1); ones(40, 1); 10 * ones(40, 1)];
         testCase.PositiveData = exp([randn(300, 1); 2 + 0.2 * randn(80, 1)]);
      end
   end

   methods (Test)
      function testKnuthRuleReturnsValidBinning(testCase)
         testCase.verifyValidBinning(testCase.ClusteredData, ...
            'BinMethod', 'knuth');
      end

      function testStoneRuleReturnsValidBinning(testCase)
         testCase.verifyValidBinning(testCase.ClusteredData, ...
            'BinMethod', 'stone');
      end

      function testBayesianBlocksReturnsAdaptiveWidths(testCase)
         [~, widths] = testCase.verifyValidBinning(testCase.GappedData, ...
            'BinMethod', 'bayesian-blocks');

         testCase.verifyGreaterThan(max(widths) - min(widths), 0);
      end

      function testStoneSupportsLogScale(testCase)
         [edges, ~, centers] = testCase.verifyValidBinning( ...
            testCase.PositiveData, 'BinMethod', 'stone', 'Scale', 'log10');

         testCase.verifyTrue(all(edges > 0));
         testCase.verifyEqual(centers, ...
            sqrt(edges(1:end-1) .* edges(2:end)), 'AbsTol', 1e-12);
      end

      function testLogBinedgesWrapperMatchesBinedges(testCase)
         [edges1, centers1] = logbinedges(testCase.PositiveData, 12);
         [edges2, ~, centers2] = binedges(testCase.PositiveData, ...
            'Scale', 'log10', 'NumBins', 12);

         testCase.verifyEqual(edges1, edges2, 'AbsTol', 1e-12);
         testCase.verifyEqual(centers1, centers2, 'AbsTol', 1e-12);
      end
   end

   methods (Access = private)
      function [edges, widths, centers, numbins] = verifyValidBinning( ...
            testCase, data, varargin)
         [edges, widths, centers, numbins] = binedges(data, varargin{:});

         testCase.verifyEqual(numel(edges), numbins + 1);
         testCase.verifyEqual(numel(widths), numbins);
         testCase.verifyEqual(numel(centers), numbins);
         testCase.verifyTrue(all(diff(edges) > 0));
         testCase.verifyTrue(all(widths > 0));
      end
   end
end
