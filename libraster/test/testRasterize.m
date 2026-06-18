classdef testRasterize < matlab.unittest.TestCase
   %TESTRASTERIZE Tests for rasterize, incl. R consistency with rasterref.
   %
   % The scattered branch builds a cell-CENTER grid and calls rasterref, so the
   % returned X,Y and R must be self-consistent: R2grid(R) recovers the centers
   % (i.e. no half-cell offset between rasterize's grid and its R).

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
      function testScatteredRasterSizeRConsistentWithCenters(testCase)
         rng(0); n = 300;
         x = rand(n, 1) * 100; y = rand(n, 1) * 50; z = x + y;
         [Z, R, X, Y] = rasterize(x, y, z, [6 11]);
         testCase.verifyEqual(size(Z), [6 11]);
         [Xr, Yr] = R2grid(R);
         testCase.verifyEqual(Xr, X, 'AbsTol', 1e-6);
         testCase.verifyEqual(Yr, Y, 'AbsTol', 1e-6);
      end

      function testScatteredCellExtentRConsistentWithCenters(testCase)
         rng(0); n = 300;
         x = rand(n, 1) * 100; y = rand(n, 1) * 50; z = x + y;
         [~, R, X, Y] = rasterize(x, y, z, 10, 10);
         [Xr, Yr] = R2grid(R);
         testCase.verifyEqual(Xr, X, 'AbsTol', 1e-6);
         testCase.verifyEqual(Yr, Y, 'AbsTol', 1e-6);
      end

      function testProjectionOptionSetsProjectedCRS(testCase)
         % A projcrs passed anywhere in the optional args is applied to R.
         rng(0); n = 200;
         xp = 5e5 + rand(n,1)*1e4; yp = 4e6 + rand(n,1)*1e4; zp = xp + yp;
         [~, R] = rasterize(xp, yp, zp, [6 11], projcrs(3857));
         testCase.verifyNotEmpty(R.ProjectedCRS);
      end

      function testExistingPositionalApiPreserved(testCase)
         % The added options must not break the existing positional forms.
         rng(0); n = 200;
         xp = 5e5 + rand(n,1)*1e4; yp = 4e6 + rand(n,1)*1e4; zp = xp + yp;
         [Z1, ~] = rasterize(xp, yp, zp, [6 11]);
         [Z2, ~] = rasterize(xp, yp, zp, [6 11], 'natural', 'extrap');
         [Z3, ~] = rasterize(xp, yp, zp, 1000, 1000);
         testCase.verifyEqual(size(Z1), [6 11]);
         testCase.verifyEqual(size(Z2), [6 11]);
         testCase.verifyNotEmpty(Z3);
      end

      function testRegularGridInputStillWorks(testCase)
         [Xg, Yg] = meshgrid(0:10:100, 50:-10:0); zz = Xg + Yg;
         [Z, R] = rasterize(Xg(:), Yg(:), zz(:), [6 11]);
         testCase.verifyEqual(size(Z), [6 11]);
         testCase.verifyTrue(isobject(R));
      end
   end
end
