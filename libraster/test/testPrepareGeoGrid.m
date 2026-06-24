classdef testPrepareGeoGrid < matlab.unittest.TestCase
   %TESTPREPAREGEOGRID prepareGeoGrid runs on geographic grids without crashing.
   %
   % Regression for the `~silent` crash: `silent` defaulted to the char 'verbose',
   % so `~tfLonLatOrder && ~silent` evaluated `~'verbose'` (a 1x7 logical array)
   % and `&&` threw on the normal (default-flag) path. silent is now normalized to
   % a logical scalar.
   %
   % NOTE: prepareGeoGrid is an unfinished WIP (see its header and matfunclib bead
   % for the remaining issues: the 'silent'/'verbose' positional flag is rejected
   % by inputParser, and the planar fallback transposes). These tests only cover
   % what is meant to work; they do not assert the WIP behaviors.

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
      function testGeographicGridReturnsGrids(testCase)
         lat = (60:-0.5:50).';
         lon = (-50:0.5:-40).';
         [LAT, LON, dLat, dLon, gridType] = prepareGeoGrid(lat, lon);
         testCase.verifyTrue(ismatrix(LAT) && isequal(size(LAT), size(LON)));
         testCase.verifyEqual(abs(dLat), 0.5, 'AbsTol', 1e-9);
         testCase.verifyEqual(abs(dLon), 0.5, 'AbsTol', 1e-9);
         testCase.verifyTrue(ismember(gridType, {'uniform','regular'}));
      end

      function testDelegatesToPrepareMapGrid(testCase)
         % Outputs (in lat-first order) match prepareMapGrid (in X=lon,Y=lat).
         lat = (60:-0.5:50).'; lon = (-50:0.5:-40).';
         [LAT, LON] = prepareGeoGrid(lat, lon);
         [LONm, LATm] = prepareMapGrid(lon, lat);
         testCase.verifyEqual(LAT, LATm);
         testCase.verifyEqual(LON, LONm);
      end

      function testWarnsAndSwapsOnLonLatOrder(testCase)
         % An UNAMBIGUOUS lon,lat-order input (longitudes > 90 in the lat slot)
         % is detected, swapped to lat,lon, and warns.
         lonFirst = (100:5:170).';      % longitudes passed in the lat position
         latSecond = (-40:5:40).';
         f = @() prepareGeoGrid(lonFirst, latSecond);
         testCase.verifyWarning(f, 'prepareGeoGrid:swappedLonLatOrder');
         [LAT, LON] = prepareGeoGrid(lonFirst, latSecond, 'silent', true);
         % After the swap, LAT holds the [-40,40] values and LON the [100,170].
         testCase.verifyLessThanOrEqual(max(abs(LAT(:))), 90);
         testCase.verifyGreaterThan(max(LON(:)), 90);
      end

      function testSilentSuppressesSwapWarning(testCase)
         lonFirst = (100:5:170).'; latSecond = (-40:5:40).';
         testCase.verifyWarningFree(...
            @() prepareGeoGrid(lonFirst, latSecond, 'silent', true));
      end
   end
end
