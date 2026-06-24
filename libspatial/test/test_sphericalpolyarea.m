classdef test_sphericalpolyarea < matlab.unittest.TestCase
   %TEST_SPHERICALPOLYAREA Toolbox-free spherical polygon area.
   %
   % Validates against analytic oracles (no toolbox), the exactremap-kv1
   % regression (equator+prime-meridian straddling), holes, and -- when the
   % Mapping Toolbox is present -- against areaint on NON-straddling polygons.

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
      function [lat, lon] = box(lat1, lat2, lon1, lon2)
         lat = [lat1; lat1; lat2; lat2];
         lon = [lon1; lon2; lon2; lon1];
      end
      function A = boxArea(lat1, lat2, lon1, lon2)   % unit sphere, exact
         A = deg2rad(lon2 - lon1) * (sind(lat2) - sind(lat1));
      end
   end

   methods (Test)
      % ---- analytic: lat/lon boxes on the unit sphere ----
      function testBoxMidLatitude(testCase)
         [la, lo] = test_sphericalpolyarea.box(10, 30, 20, 50);
         A = sphericalpolyarea(la, lo, [1 0]);
         testCase.verifyEqual(abs(A), ...
            abs(test_sphericalpolyarea.boxArea(10, 30, 20, 50)), 'RelTol', 1e-9);
      end
      function testBoxHighLatitude(testCase)
         [la, lo] = test_sphericalpolyarea.box(70, 80, 0, 30);
         A = sphericalpolyarea(la, lo, [1 0]);
         testCase.verifyEqual(abs(A), ...
            abs(test_sphericalpolyarea.boxArea(70, 80, 0, 30)), 'RelTol', 1e-9);
      end

      % ---- kv1 regression: equator + prime-meridian straddling ----
      function testStraddlingBoxIsCorrectNotInflated(testCase)
         [la, lo] = test_sphericalpolyarea.box(-10, 10, -10, 10);
         A = abs(sphericalpolyarea(la, lo, [1 0]));
         exact = abs(test_sphericalpolyarea.boxArea(-10, 10, -10, 10));
         testCase.verifyEqual(A, exact, 'RelTol', 1e-9);
         % The old fixed-origin line integral (areaint) inflated this ~1.58x.
         testCase.verifyLessThan(A, 1.1 * exact, ...
            'straddling area must not be inflated as the old areaint was');
      end

      % ---- pole-enclosing ring (constant-latitude circle) ----
      function testPoleEnclosingCircle(testCase)
         lat = 80 * ones(72, 1);
         lon = (0:5:355).';                  % eastward loop around lat 80
         A = sphericalpolyarea(lat, lon, [1 0]);
         % Chamberlain-Duquette: eastward around a northern parallel -> the
         % southern region, 2*pi*(1+sin phi) on the unit sphere.
         testCase.verifyEqual(A, 2*pi*(1 + sind(80)), 'RelTol', 1e-6);
      end

      % ---- hemisphere (equatorial ring) ----
      function testEquatorialRingIsHemisphere(testCase)
         lat = zeros(4, 1);
         lon = [0; 90; 180; 270];
         A = sphericalpolyarea(lat, lon, [1 0]);
         testCase.verifyEqual(abs(A), 2*pi, 'RelTol', 1e-9);
      end

      % ---- holes: outer ring minus opposite-wound inner ring ----
      function testHoleIsSubtracted(testCase)
         [oLa, oLo] = test_sphericalpolyarea.box(0, 10, 0, 10);      % outer
         [iLa, iLo] = test_sphericalpolyarea.box(2, 8, 2, 8);        % inner
         % opposite winding for the hole
         iLa = flipud(iLa); iLo = flipud(iLo);
         lat = [oLa; NaN; iLa];
         lon = [oLo; NaN; iLo];
         [A, Aparts] = sphericalpolyarea(lat, lon, [1 0]);
         outer = abs(test_sphericalpolyarea.boxArea(0, 10, 0, 10));
         inner = abs(test_sphericalpolyarea.boxArea(2, 8, 2, 8));
         testCase.verifyEqual(abs(A), outer - inner, 'RelTol', 1e-9);
         testCase.verifyEqual(numel(Aparts), 2);
         testCase.verifyNotEqual(sign(Aparts(1)), sign(Aparts(2)));  % opposite
      end

      % ---- cell input parity with NaN-delimited input ----
      function testCellInputMatchesNanDelimited(testCase)
         [oLa, oLo] = test_sphericalpolyarea.box(0, 10, 0, 10);
         [iLa, iLo] = test_sphericalpolyarea.box(20, 30, 20, 30);
         Anan  = sphericalpolyarea([oLa; NaN; iLa], [oLo; NaN; iLo], [1 0]);
         Acell = sphericalpolyarea({oLa, iLa}, {oLo, iLo}, [1 0]);
         testCase.verifyEqual(Acell, Anan, 'RelTol', 1e-12);
      end

      % ---- ellipsoid: wgs84 box area is positive and near the spherical value
      %      (the authalic-latitude correction shifts it < ~0.3% off the
      %      geodetic-latitude box on the authalic-radius sphere) ----
      function testWgs84BoxPositiveAndReasonable(testCase)
         [la, lo] = test_sphericalpolyarea.box(10, 30, 20, 50);
         A = abs(sphericalpolyarea(la, lo, 'wgs84'));
         Rauth = 6371007.181;                     % WGS84 authalic radius (m)
         approx = Rauth^2 * abs(test_sphericalpolyarea.boxArea(10, 30, 20, 50));
         testCase.verifyGreaterThan(A, 0);
         testCase.verifyEqual(A, approx, 'RelTol', 1e-2);
      end

      % ---- Mapping Toolbox oracle (guarded; NON-straddling only) ----
      % The edges are densified so areaint's geodesic segments approximate the
      % parallels/meridians of the lat/lon box (a 4-corner box differs because
      % areaint connects corners with geodesics, not parallels).
      function testMatchesAreaintWhereToolboxIsCorrect(testCase)
         testCase.assumeTrue(license('test', 'map_toolbox') == 1 ...
            && exist('areaint', 'file') == 2, 'Mapping Toolbox not available');
         n = 200;
         la = [repmat(10, n, 1); linspace(10, 30, n)'; ...
               repmat(30, n, 1); linspace(30, 10, n)'];
         lo = [linspace(20, 50, n)'; repmat(50, n, 1); ...
               linspace(50, 20, n)'; repmat(20, n, 1)];
         A = abs(sphericalpolyarea(la, lo, 'wgs84'));
         Aref = areaint(la, lo, wgs84Ellipsoid);
         testCase.verifyEqual(A, Aref, 'RelTol', 1e-4);
      end
   end
end
