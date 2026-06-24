classdef testIsxyregular < matlab.unittest.TestCase
   %TESTISXYREGULAR isxyregular delegates to the canonical mapGridCellSize estimator.

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
      function testUniformGridIsRegular(testCase)
         [X, Y] = meshgrid(0:5:50, 0:5:30);
         testCase.verifyTrue(isxyregular(X, Y));
      end

      function testRegularNonUniformIsRegular(testCase)
         % uniform per axis, different X and Y steps -> still "regular"
         [X, Y] = meshgrid(0:10:100, 0:5:50);
         testCase.verifyTrue(isxyregular(X, Y));
      end

      function testIrregularAxisIsNotRegular(testCase)
         x = [0 1 2 5 6];                 % non-uniform spacing
         y = 0:5;
         [X, Y] = meshgrid(x, y);
         testCase.verifyFalse(isxyregular(X, Y));
      end

      function testCoordinateListInput(testCase)
         [X, Y] = meshgrid(0:5:50, 0:5:30);
         testCase.verifyTrue(isxyregular(X(:), Y(:)));
      end

      function testFloatNoiseAcceptedViaRelativeTolerance(testCase)
         % float32-style storage jitter must NOT flip a uniform grid to irregular
         % (the whole reason for the relative-tolerance estimator).
         x = single(0:0.15:15); y = single(0:0.15:9);
         [X, Y] = meshgrid(double(x), double(y));
         testCase.verifyTrue(isxyregular(X, Y));
      end

      function testGeographicFlag(testCase)
         [LON, LAT] = meshgrid(-100:0.5:-90, 30.5:0.5:40.5);
         [tf, tflatlon] = isxyregular(LON, LAT);
         testCase.verifyTrue(tf);
         testCase.verifyTrue(tflatlon);
      end

      function testPlanarFlag(testCase)
         [X, Y] = meshgrid(5e5:1e3:5.1e5, 4e6:1e3:4.05e6);
         [~, tflatlon] = isxyregular(X, Y);
         testCase.verifyFalse(tflatlon);
      end
   end
end
