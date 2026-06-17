classdef testRastersurf < matlab.unittest.TestCase
   %TESTRASTERSURF Smoke tests for the rastersurf display wrapper.

   properties
      R
      Z
      Fig
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture
         testFolder = fileparts(mfilename("fullpath"));
         projectFolder = fileparts(fileparts(testFolder));
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
         testCase.assumeTrue(license('test', 'map_toolbox') == 1, ...
            'Mapping Toolbox required.');
      end
   end

   methods (TestMethodSetup)
      function makeData(testCase)
         [Xg, Yg] = meshgrid(0:10:100, 50:-10:0);
         testCase.R = rasterref(Xg, Yg, 'UseGeoCoords', false, 'silent', true);
         testCase.Z = Xg + Yg;
         testCase.Fig = figure('Visible', 'off');
         testCase.addTeardown(@close, testCase.Fig);
         axes('Parent', testCase.Fig);
      end
   end

   methods (Test)
      function testReturnsGraphicsAxesColorbar(testCase)
         [h, ax, cb] = rastersurf(testCase.Z, testCase.R);
         testCase.verifyTrue(isgraphics(h));
         testCase.verifyClass(ax, 'matlab.graphics.axis.Axes');
         testCase.verifyClass(cb, 'matlab.graphics.illustration.ColorBar');
      end

      function testRunsWithNameValue(testCase)
         h = rastersurf(testCase.Z, testCase.R, 'DisplayType', 'mesh');
         testCase.verifyTrue(isgraphics(h));
      end

      function testColormapNameValue(testCase)
         cmap = parula(8);
         [h, ax] = rastersurf(testCase.Z, testCase.R, 'Colormap', cmap);
         testCase.verifyTrue(isgraphics(h));
         testCase.verifyEqual(colormap(ax), cmap);
      end

      function testColormapPositionalForm(testCase)
         % colormap as the third positional argument: rastersurf(Z, R, cmap)
         cmap = parula(8);
         [h, ax] = rastersurf(testCase.Z, testCase.R, cmap);
         testCase.verifyTrue(isgraphics(h));
         testCase.verifyEqual(colormap(ax), cmap);
      end

      function testTransparentFlagWithNaN(testCase)
         Zn = testCase.Z;
         Zn(1, 1) = NaN;
         h = rastersurf(Zn, testCase.R, 'transparent');
         testCase.verifyTrue(isgraphics(h));
         testCase.verifyEqual(h.FaceAlpha, 'texturemap');
         % only the NaN cell is transparent: AlphaData is 0 there, 1 elsewhere
         testCase.verifyEqual(h.AlphaData(1, 1), 0);
         testCase.verifyEqual(nnz(h.AlphaData == 0), 1);
      end

      function testCoordinateListForm(testCase)
         % geolocated lat,lon,Z arrays passed straight through to geoshow
         [Xg, Yg] = meshgrid(0:10:100, 50:-10:0);
         Zg = Xg + Yg;
         h = rastersurf(Yg, Xg, Zg);
         testCase.verifyTrue(isgraphics(h));
      end
   end
end
