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

      % ---- data-CONTENT coverage (regression: the scattered branch silently
      % returned an all-NaN Z, which the size/geometry-only checks above missed) ----

      function testScatteredProducesValidSurface(testCase)
         % Interpolating a plane z = x + y must reproduce the plane (natural
         % neighbour is exact for linear fields) wherever Z is defined -- and Z
         % must NOT be entirely NaN.
         rng(0); n = 300;
         x = rand(n,1)*100; y = rand(n,1)*50; z = x + y;
         [Z, ~, X, Y] = rasterize(x, y, z, [12 20]);
         valid = ~isnan(Z);
         testCase.verifyTrue(any(valid(:)), 'Z is entirely NaN (all-NaN bug)');
         testCase.verifyEqual(Z(valid), X(valid) + Y(valid), 'AbsTol', 1e-6);
      end

      function testScatteredFootprintMaskTrimsExterior(testCase)
         % Points on a disk; with 'nearest' the whole box would fill, so the
         % concave-boundary mask must NaN the bounding-box corners (outside the
         % disk) while keeping the centre.
         rng(0); n = 500; r = 40;
         th = rand(n,1)*2*pi; rr = r*sqrt(rand(n,1));
         x = 50 + rr.*cos(th); y = 50 + rr.*sin(th); z = x + y;
         Z = rasterize(x, y, z, [21 21], 'nearest');
         testCase.verifyTrue(isnan(Z(1,1))   && isnan(Z(1,end)) && ...
                             isnan(Z(end,1)) && isnan(Z(end,end)), ...
            'corner cells outside the data footprint should be NaN');
         testCase.verifyFalse(isnan(Z(11,11)), 'centre cell should be filled');
      end

      function testRegularFullGridValuesCorrect(testCase)
         % Every cell value must equal the analytic field at its coordinate.
         [Xg, Yg] = meshgrid(0:5:20, 0:5:15); zz = Xg + 10*Yg;
         [Z, ~, X, Y] = rasterize(Xg, Yg, zz, size(Xg));
         testCase.verifyEqual(Z, X + 10*Y);
      end

      function testRegularGappedGridPlacesValues(testCase)
         [Xg, Yg] = meshgrid(0:5:20, 0:5:15); zz = Xg + 10*Yg;
         xl = Xg(:); yl = Yg(:); zl = zz(:);
         xl(5) = []; yl(5) = []; zl(5) = [];   % drop one node
         [Z, ~, X, Y] = rasterize(xl, yl, zl, size(Xg));
         testCase.verifyEqual(size(Z), size(Xg));
         testCase.verifyEqual(nnz(isnan(Z)), 1, 'exactly one gap cell');
         ok = ~isnan(Z);
         testCase.verifyEqual(Z(ok), X(ok) + 10*Y(ok), 'AbsTol', 1e-9);
      end

      function testNdgridOrientationValuesCorrect(testCase)
         % ndgrid-oriented input must be reoriented and its values placed right.
         [Xn, Yn] = ndgrid(0:5:20, 0:5:15); zn = Xn + 10*Yn;
         [Z, ~, X, Y] = rasterize(Xn, Yn, zn, size(Xn));
         testCase.verifyEqual(size(Z), [numel(0:5:15) numel(0:5:20)]);
         testCase.verifyEqual(Z, X + 10*Y);
      end

      function testGriddedInputNeedsNoSizeArg(testCase)
         % Already-gridded data grids without a rasterSize/cellextent argument.
         [Xg, Yg] = meshgrid(0:5:20, 0:5:15); zz = Xg + 10*Yg;
         [Z, ~, X, Y] = rasterize(Xg, Yg, zz);
         testCase.verifyEqual(Z, X + 10*Y);
      end

      function testScatteredWithoutSizeErrors(testCase)
         rng(0); x = rand(50,1)*100; y = rand(50,1)*100; z = x + y;
         testCase.verifyError(@() rasterize(x, y, z), ...
            'matfunclib:rasterize:missingGridSpec');
      end

      function testTooManyPositionalArgsErrors(testCase)
         rng(0); x = rand(50,1)*100; y = rand(50,1)*100; z = x + y;
         testCase.verifyError(@() rasterize(x, y, z, [6 11], 5, 6), ...
            'matfunclib:rasterize:tooManyPositionalArgs');
      end
   end
end
