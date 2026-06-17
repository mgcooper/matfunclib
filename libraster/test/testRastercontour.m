classdef testRastercontour < matlab.unittest.TestCase
   %TESTRASTERCONTOUR Smoke tests for the rastercontour display wrapper.

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
      function testReturnsGraphicsHandle(testCase)
         h = rastercontour(testCase.Z, testCase.R);
         testCase.verifyTrue(isgraphics(h));
      end

      function testReturnsAxesAndColorbar(testCase)
         % the [H,AX] / [H,AX,C] output forms previously referenced an undefined
         % 'ax' and errored; verify they now return the axes and colorbar.
         [h, ax, cb] = rastercontour(testCase.Z, testCase.R);
         testCase.verifyTrue(isgraphics(h));
         testCase.verifyClass(ax, 'matlab.graphics.axis.Axes');
         testCase.verifyClass(cb, 'matlab.graphics.illustration.ColorBar');
      end
   end
end
