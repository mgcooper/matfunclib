classdef testOrientValueToGrid < matlab.unittest.TestCase
   %TESTORIENTVALUETOGRID Orient a value array V to libraster's meshgrid grid.

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
      function testVectorNdgridVtransposedToMeshgrid(testCase)
         x = 1:4; y = 1:6;             % non-square
         f = @(X, Y) 10 * X + Y;
         [Xm, Ym] = meshgrid(x, y); Vmesh = f(Xm, Ym);   % [ny x nx]
         [Xn, Yn] = ndgrid(x, y);   Vnd = f(Xn, Yn);     % [nx x ny]
         [Vout, ambiguous] = orientValueToGrid(Vnd, x, y);
         testCase.verifyEqual(Vout, Vmesh);
         testCase.verifyFalse(ambiguous);
      end

      function testVectorMeshgridVisNoOp(testCase)
         x = 1:4; y = 1:6;
         [Xm, Ym] = meshgrid(x, y); Vmesh = 10 * Xm + Ym;
         [Vout, ambiguous] = orientValueToGrid(Vmesh, x, y);
         testCase.verifyEqual(Vout, Vmesh);
         testCase.verifyFalse(ambiguous);
      end

      function testSquareVectorGridIsAmbiguousAndUnchanged(testCase)
         x = 1:4; y = 1:4;             % square -> undeterminable
         V = magic(4);
         [Vout, ambiguous] = orientValueToGrid(V, x, y);
         testCase.verifyEqual(Vout, V);     % left unchanged
         testCase.verifyTrue(ambiguous);
      end

      function testVector3dValueTransposesFirstTwoDims(testCase)
         x = 1:4; y = 1:6;
         Vnd = reshape(1:48, 4, 6, 2);   % [nx x ny x nt] ndgrid-oriented
         [Vout, ambiguous] = orientValueToGrid(Vnd, x, y);
         testCase.verifyEqual(size(Vout), [6 4 2]);
         testCase.verifyEqual(Vout(:, :, 1), permute(Vnd(:, :, 1), [2 1]));
         testCase.verifyFalse(ambiguous);
      end

      function testArrayNdgridAlignsToCanonicalGrid(testCase)
         % 2-D array input: V is replayed through prepareMapGrid's transform.
         [Xn, Yn] = ndgrid(1:4, 10:10:60);
         Vn = 10 * Xn + Yn;
         [X2, Y2] = prepareMapGrid(Xn, Yn, 'fullgrids');
         [Vout, ambiguous] = orientValueToGrid(Vn, Xn, Yn);
         testCase.verifyEqual(Vout, 10 * X2 + Y2);
         testCase.verifyFalse(ambiguous);
      end

      function testArrayMeshgridIsConsistent(testCase)
         [Xm, Ym] = meshgrid(1:4, 10:10:60);
         Vm = 10 * Xm + Ym;
         [X2, Y2] = prepareMapGrid(Xm, Ym, 'fullgrids');
         Vout = orientValueToGrid(Vm, Xm, Ym);
         testCase.verifyEqual(Vout, 10 * X2 + Y2);
      end

      function testEmptyValuePassesThrough(testCase)
         [Vout, ambiguous] = orientValueToGrid([], 1:4, 1:6);
         testCase.verifyEmpty(Vout);
         testCase.verifyFalse(ambiguous);
      end
   end
end
