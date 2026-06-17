classdef testGridxyz < matlab.unittest.TestCase
   %TESTGRIDXYZ Tests for gridxyz output contract and gap-fill behavior.

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
      function testSingleOutputReturnsV(testCase)
         % Regression: V = gridxyz(...) used to error with unassigned output.
         xs = [0 1 2 0 1 2 0 1 2].'; ys = [0 0 0 1 1 1 2 2 2].'; vs = (1:9).';
         returned = gridxyz(xs, ys, vs);
         testCase.verifyEqual(size(returned), [3 3]);
      end

      function testGapFillKeepsKnownExactAndFillsMissing(testCase)
         % Known cells keep their exact input values; only the missing cell is
         % interpolated. The 3x3 grid omits the center (1,1).
         xs = [0 1 2 0 2 0 1 2].'; ys = [0 0 0 1 1 2 2 2].';
         vs = 10 * xs + ys;
         [V, ~, X, Y] = gridxyz(xs, ys, vs);
         known = V(X == 0 & Y == 0);
         filled = V(X == 1 & Y == 1);
         testCase.verifyEqual(known, 0);            % exact, not interpolated
         testCase.verifyTrue(isfinite(filled));      % previously-missing cell filled
      end

      function testThreeOutputsAreVXY(testCase)
         % With three outputs the order is [V, X, Y] (not R). Documented contract.
         xs = [0 1 2 0 1 2 0 1 2].'; ys = [0 0 0 1 1 1 2 2 2].'; vs = (1:9).';
         [V, X, Y] = gridxyz(xs, ys, vs);
         testCase.verifyEqual(size(V), [3 3]);
         testCase.verifyEqual(size(X), [3 3]);
         testCase.verifyEqual(size(Y), [3 3]);
         testCase.verifyEqual(sort(unique(X(:))), [0 1 2].');
      end

      function testReorientedGridInputAlignsV(testCase)
         % A 2D grid input with Y ascending (S-N) is reoriented N-S inside
         % prepareMapGrid; V must stay aligned with X,Y (regression for the
         % orientation/V-flip fix).
         [Xg, Yg] = meshgrid(0:3, 0:3);
         Zg = 10 * Xg + Yg;
         [V, ~, X, Y] = gridxyz(Xg, Yg, Zg);
         testCase.verifyEqual(V, 10 * X + Y);
      end

      function testSecondOutputIsReferenceObject(testCase)
         % With two outputs the order is [V, R].
         xs = [0 1 2 0 1 2 0 1 2].'; ys = [0 0 0 1 1 1 2 2 2].'; vs = (1:9).';
         [~, R] = gridxyz(xs, ys, vs);
         testCase.verifyTrue(isobject(R));
         testCase.verifyTrue(isprop(R, 'RasterSize'));
      end
   end
end
