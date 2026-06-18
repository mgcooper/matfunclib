classdef testScatteredInterpolation < matlab.unittest.TestCase
   %TESTSCATTEREDINTERPOLATION Tests for scatteredInterpolation.
   %
   % Covers the build-once optimization (one interpolant reused across value
   % columns) and guards the single-column-NaN regression where an empty inner
   % for-loop ran one iteration with an empty column index.

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture
         testFolder = fileparts(mfilename("fullpath"));
         projectFolder = fileparts(fileparts(testFolder));
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (Test)
      function testSingleColumnWithNaN(testCase)
         % Regression: a single value column with a NaN must interpolate the gap
         % without erroring (the empty inner-loop bug threw BadFormatInterpValues).
         [Xg, Yg] = meshgrid(0:2, 0:2);
         X = Xg(:); Y = Yg(:);
         V = (1:9).'; V(5) = NaN;          % center cell missing
         returned = scatteredInterpolation(X, Y, V, X, Y, 'natural', 'none');
         testCase.verifyEqual(size(returned), [9 1]);
         testCase.verifyTrue(isfinite(returned(5)));
      end

      function testBuildOnceMatchesPerColumnNoNaN(testCase)
         % The reused interpolant must give identical results to rebuilding one
         % interpolant per column.
         [Xg, Yg] = meshgrid(0:2, 0:2);
         X = Xg(:); Y = Yg(:);
         V = [(1:9).', (11:19).', (21:29).'];
         returned = scatteredInterpolation(X, Y, V, X, Y, 'natural', 'none');
         expected = nan(9, 3);
         for k = 1:3
            F = scatteredInterpolant(X, Y, V(:, k), 'natural', 'none');
            expected(:, k) = F(X, Y);
         end
         testCase.verifyEqual(returned, expected, 'AbsTol', 1e-12);
      end

      function testSharedNaNMaskMatchesPerColumn(testCase)
         [Xg, Yg] = meshgrid(0:2, 0:2);
         X = Xg(:); Y = Yg(:);
         V = [(1:9).', (11:19).', (21:29).']; V(5, :) = NaN;
         returned = scatteredInterpolation(X, Y, V, X, Y, 'natural', 'none');
         m = isnan(V(:, 1));
         expected = nan(9, 3);
         for k = 1:3
            F = scatteredInterpolant(X(~m), Y(~m), V(~m, k), 'natural', 'none');
            expected(:, k) = F(X, Y);
         end
         testCase.verifyEqual(returned, expected, 'AbsTol', 1e-12);
      end

      function testDifferentNaNMasksMatchPerColumn(testCase)
         [Xg, Yg] = meshgrid(0:2, 0:2);
         X = Xg(:); Y = Yg(:);
         V = [(1:9).', (11:19).']; V(2, 1) = NaN; V(6, 2) = NaN;
         returned = scatteredInterpolation(X, Y, V, X, Y, 'natural', 'none');
         expected = nan(9, 2);
         for k = 1:2
            mk = isnan(V(:, k));
            F = scatteredInterpolant(X(~mk), Y(~mk), V(~mk, k), 'natural', 'none');
            expected(:, k) = F(X, Y);
         end
         testCase.verifyEqual(returned, expected, 'AbsTol', 1e-12);
      end

      function testIrregularScatteredInput(testCase)
         % Genuinely scattered (irregular) points must be accepted, not rejected
         % as an invalid grid, and match a direct scatteredInterpolant call.
         rng(0);
         n = 30;
         X = rand(n, 1) * 10; Y = rand(n, 1) * 10;
         V = sin(X) + cos(Y);
         Xq = (0:10).'; Yq = (0:10).';
         returned = scatteredInterpolation(X, Y, V, Xq, Yq, 'natural', 'none');
         F = scatteredInterpolant(X, Y, V, 'natural', 'none');
         expected = F(Xq, Yq);
         testCase.verifyEqual(returned, expected, 'AbsTol', 1e-12);
      end
   end
end
