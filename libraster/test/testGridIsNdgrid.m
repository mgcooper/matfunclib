classdef testGridIsNdgrid < matlab.unittest.TestCase
   %TESTGRIDISNDGRID Orientation detection for the ndgrid->meshgrid canonicalizer.

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
      function testMeshgridIsNotNdgrid(testCase)
         [X, Y] = meshgrid(1:4, 1:7);
         testCase.verifyFalse(gridIsNdgrid(X, Y));
      end

      function testNdgridIsNdgrid(testCase)
         [X, Y] = ndgrid(1:4, 1:7);
         testCase.verifyTrue(gridIsNdgrid(X, Y));
      end

      function testSquareGridsResolvedByGradientNotShape(testCase)
         % a 4x4 meshgrid and a 4x4 ndgrid have the same size; orientation must
         % still be resolved from the gradients.
         [Xm, Ym] = meshgrid(1:4, 1:4);
         [Xn, Yn] = ndgrid(1:4, 1:4);
         testCase.verifyFalse(gridIsNdgrid(Xm, Ym));
         testCase.verifyTrue(gridIsNdgrid(Xn, Yn));
      end

      function testNanBordersIgnored(testCase)
         % RCM-style NaN border must not flip the verdict (omitnan).
         [X, Y] = ndgrid(1:5, 1:8);
         X([1 end], :) = NaN; Y([1 end], :) = NaN;
         testCase.verifyTrue(gridIsNdgrid(X, Y));
      end

      function testVectorsAndScalarsAreNotNdgrid(testCase)
         testCase.verifyFalse(gridIsNdgrid(1:5, (1:5).'));   % vectors
         testCase.verifyFalse(gridIsNdgrid(3, 4));           % scalars
      end

      function testRotated45IsAmbiguousSoDefaultsMeshgrid(testCase)
         % a ~45-degree-rotated uniform grid has equal row/col gradients -> tie ->
         % left as meshgrid (the safe default), not transposed.
         [Xm, Ym] = meshgrid(1:5, 1:5);
         th = pi / 4;
         Xr = Xm * cos(th) - Ym * sin(th);
         Yr = Xm * sin(th) + Ym * cos(th);
         testCase.verifyFalse(gridIsNdgrid(Xr, Yr));
      end
   end
end
