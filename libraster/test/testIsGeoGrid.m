classdef testIsGeoGrid < matlab.unittest.TestCase
   %TESTISGEOGRID Tests for the tightened geographic-vs-planar heuristic.
   %
   % isGeoGrid(Lat, Lon): a grid is geographic only when in geographic bounds AND
   % carrying a geographic signature (fractional degrees, negative lon/lat, or
   % lon > 180). Small all-integer non-negative grids are ambiguous -> planar.

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
      function testSmallIntegerPlanarGridIsNotGeographic(testCase)
         % The reported false positive: 0..100 / 0..50 integer grid -> planar.
         x = (0:10:100).'; y = (0:10:50).';
         testCase.verifyFalse(isGeoGrid(y, x));
      end

      function testFractionalInRangeIsGeographic(testCase)
         % A MERRA-like fractional-degree grid is geographic.
         x = (-180:0.625:179.375).'; y = (-90:0.5:90).';
         testCase.verifyTrue(isGeoGrid(y, x));
      end

      function testNegativeLongitudeIntegerGridIsGeographic(testCase)
         % Integer degrees, but negative longitudes are a geographic signature.
         x = (-180:10:170).'; y = (90:-10:-90).';
         testCase.verifyTrue(isGeoGrid(y, x));
      end

      function testLongitudeOver180IsGeographic(testCase)
         % [0,360] convention: max longitude > 180 is a geographic signature.
         x = (0:10:350).'; y = (-80:10:80).';
         testCase.verifyTrue(isGeoGrid(y, x));
      end

      function testProjectedMetersOutOfRangeIsNotGeographic(testCase)
         % Large projected coordinates fall outside geographic bounds -> planar.
         x = (5e5:1e3:5.1e5).'; y = (4.0e6:1e3:4.05e6).';
         testCase.verifyFalse(isGeoGrid(y, x));
      end
   end
end
