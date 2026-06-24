classdef testApplyGridTransform < matlab.unittest.TestCase
   %TESTAPPLYGRIDTRANSFORM Replay a prepareMapGrid transform record on an array.
   %
   % applyGridTransform is the primitive shared by gridxyz, rasterize,
   % orientValueToGrid, and exactremap's parseGridData. It must (a) replay
   % transpose-then-flips in the documented order, (b) work for N-D arrays and
   % logicals, and (c) map over a CELL stack element-wise (the exactremap caller).

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture
         testFolder = fileparts(mfilename("fullpath"));
         projectFolder = fileparts(fileparts(testFolder));
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (Static)
      function t = tform(tr, lr, ud)
         t = struct('didTranspose', tr, 'didFlipLR', lr, 'didFlipUD', ud, ...
            'orientationAmbiguous', false);
      end
   end

   methods (Test)
      function testIdentityIsNoOp(testCase)
         V = magic(5);
         testCase.verifyEqual(applyGridTransform(V, ...
            testApplyGridTransform.tform(false, false, false)), V);
      end

      function testTransposeOnly(testCase)
         V = reshape(1:12, 3, 4);
         testCase.verifyEqual(applyGridTransform(V, ...
            testApplyGridTransform.tform(true, false, false)), V.');
      end

      function testFlipLROnly(testCase)
         V = reshape(1:12, 3, 4);
         testCase.verifyEqual(applyGridTransform(V, ...
            testApplyGridTransform.tform(false, true, false)), fliplr(V));
      end

      function testFlipUDOnly(testCase)
         V = reshape(1:12, 3, 4);
         testCase.verifyEqual(applyGridTransform(V, ...
            testApplyGridTransform.tform(false, false, true)), flipud(V));
      end

      function testAllThreeInDocumentedOrder(testCase)
         % Order is transpose, THEN fliplr, THEN flipud.
         V = reshape(1:12, 3, 4);
         expected = V.';
         expected = fliplr(expected);
         expected = flipud(expected);
         testCase.verifyEqual(applyGridTransform(V, ...
            testApplyGridTransform.tform(true, true, true)), expected);
      end

      function testNDArrayTransposesFirstTwoDims(testCase)
         V = reshape(1:24, 3, 4, 2);
         out = applyGridTransform(V, ...
            testApplyGridTransform.tform(true, false, false));
         testCase.verifyEqual(size(out), [4 3 2]);
         testCase.verifyEqual(out(:, :, 2), V(:, :, 2).');
      end

      function testLogicalArray(testCase)
         V = logical([1 0 0; 0 1 1]);
         testCase.verifyEqual(applyGridTransform(V, ...
            testApplyGridTransform.tform(false, false, true)), flipud(V));
      end

      function testCellStackMapsPerElementNotLayout(testCase)
         % The exactremap contract: a cell stack transforms each grid, and the
         % cell layout (a column of layers) is preserved.
         A = reshape(1:12, 3, 4); B = 100 + A;
         V = {A; B};
         out = applyGridTransform(V, ...
            testApplyGridTransform.tform(true, false, true));
         testCase.verifyEqual(size(out), [2 1]);          % layout preserved
         testCase.verifyEqual(out{1}, flipud(A.'));
         testCase.verifyEqual(out{2}, flipud(B.'));
      end

      function testMatchesOrientValueToGridForArrayInput(testCase)
         % applyGridTransform(V, tform-from-prepareMapGrid) must equal what
         % orientValueToGrid produces for the same V,X,Y (2-D array path).
         [Xn, Yn] = ndgrid(1:4, 10:10:60);
         Vn = 10 * Xn + Yn;
         [~, ~, ~, ~, ~, ~, ~, ~, ~, ~, tform] = prepareMapGrid(Xn, Yn, 'fullgrids');
         testCase.verifyEqual(applyGridTransform(Vn, tform), ...
            orientValueToGrid(Vn, Xn, Yn));
      end
   end
end
