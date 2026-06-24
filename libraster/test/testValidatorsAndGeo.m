classdef testValidatorsAndGeo < matlab.unittest.TestCase
   %TESTVALIDATORSANDGEO libraster validators + geo helpers that had NO tests.
   %
   % Covers the util/ validator family (islatlon, isRasterReference,
   % validateRasterReference, validateGridCoordinates, validateGridData,
   % validateGridFormat, validateInterpMethod, validateScatteredData),
   % parseGeoCoordsChoice, and the mapraster plot wrapper.
   %
   % Regression guard: validateInterpMethod was fixed (nargin<1 -> nargin<2) so
   % the default method list now applies when called with a single argument
   % (testInterpMethodOneArgUsesDefaultList).

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
      function R = planarRef()
         [X, Y] = meshgrid(0:10:100, 50:-10:0);
         R = rasterref(X, Y, 'UseGeoCoords', false, 'silent', true);
      end
      function R = geoRef()
         [X, Y] = meshgrid(-50:0.5:-40, 60:-0.5:50);
         R = rasterref(X, Y, 'UseGeoCoords', true, 'silent', true);
      end
   end

   methods (Test)

      % ---- islatlon ----
      function testIsLatLonTrueInRange(testCase)
         [lon, lat] = meshgrid(-180:180, 90:-1:-90);
         testCase.verifyTrue(islatlon(lat, lon));
      end
      function testIsLatLonFalseLatOutOfRange(testCase)
         % Docstring example: 110 is outside the latitude bounds.
         testCase.verifyFalse(islatlon(110, 30));
      end
      function testIsLatLonFalseLonOutOfRange(testCase)
         % lon is bounded to [-180, 360]; 400 is out of range.
         testCase.verifyFalse(islatlon(45, 400));
      end

      % ---- isRasterReference ----
      function testIsRasterReferenceTrueForR(testCase)
         R = testValidatorsAndGeo.planarRef();
         testCase.verifyTrue(isRasterReference(R));
      end
      function testIsRasterReferenceFalseForMatrix(testCase)
         testCase.verifyFalse(isRasterReference(magic(4)));
      end
      function testIsRasterReferenceGeographicOption(testCase)
         R = testValidatorsAndGeo.geoRef();
         testCase.verifyTrue(isRasterReference(R, 'geographic'));
         testCase.verifyFalse(isRasterReference(R, 'planar'));
      end

      % ---- validateRasterReference ----
      function testValidateRasterReferenceAcceptsR(testCase)
         % Valid R passes validation; the 2-output form echoes R back.
         R = testValidatorsAndGeo.planarRef();
         [~, Rout] = validateRasterReference([], R, 'testValidatorsAndGeo');
         testCase.verifyTrue(isRasterReference(Rout));
      end
      function testValidateRasterReferenceValidatesData(testCase)
         R = testValidatorsAndGeo.planarRef();
         V = zeros(R.RasterSize);
         [Vout, Rout] = validateRasterReference(V, R, 'testValidatorsAndGeo');
         testCase.verifyEqual(size(Vout), R.RasterSize);
         testCase.verifyTrue(isRasterReference(Rout));
      end
      function testValidateRasterReferenceErrorsForMatrix(testCase)
         testCase.verifyError(...
            @() validateRasterReference([], magic(4), 'tc'), ...
            'MATLAB:tc:invalidType');
      end

      % ---- validateGridCoordinates ----
      function testValidateGridCoordinatesAcceptsFullGrids(testCase)
         [X, Y] = meshgrid(1:5, 1:4);
         [Xo, Yo] = validateGridCoordinates(X, Y, 'tc', 'X', 'Y', 'fullgrids');
         testCase.verifyEqual(Xo, X);
         testCase.verifyEqual(Yo, Y);
      end
      function testValidateGridCoordinatesErrorsOnComplex(testCase)
         testCase.verifyError(...
            @() validateGridCoordinates(1 + 2i, 3, 'tc'), ...
            'MATLAB:tc:expectedReal');
      end

      % ---- validateGridData ----
      function testValidateGridDataAcceptsMatchingGrid(testCase)
         [X, Y] = meshgrid(1:5, 1:4);
         V = rand(size(X));
         [Vout, Xout, Yout] = validateGridData(V, X, Y, 'tc');
         testCase.verifyEqual(size(Vout), size(V));
         testCase.verifyEqual(size(Xout), size(X));
         testCase.verifyEqual(size(Yout), size(Y));
      end
      function testValidateGridDataErrorsOnMismatch(testCase)
         [X, Y] = meshgrid(1:5, 1:4);
         V = rand(3, 3); % does not match X,Y size
         testCase.verifyError(...
            @() validateGridData(V, X, Y, 'tc'), ...
            'custom:tc:inconsistentXYV');
      end

      % ---- validateGridFormat ----
      function testValidateGridFormatAcceptsKnown(testCase)
         % Default validFormats is a string array, so output is a string scalar.
         testCase.verifyEqual(validateGridFormat('fullgrids'), "fullgrids");
      end
      function testValidateGridFormatErrorsOnUnknown(testCase)
         testCase.verifyError(...
            @() validateGridFormat('bogusformat'), ...
            'MATLAB:unrecognizedStringChoice');
      end

      % ---- validateInterpMethod (regression: nargin<1 -> nargin<2) ----
      function testInterpMethodOneArgUsesDefaultList(testCase)
         % One argument must now fall through to the default valid-method list.
         testCase.verifyEqual(validateInterpMethod('linear'), 'linear');
      end
      function testInterpMethodTwoArgUsesProvidedList(testCase)
         testCase.verifyEqual(...
            validateInterpMethod('nearest', {'nearest', 'linear'}), 'nearest');
      end
      function testInterpMethodBranchesOnFunctionName(testCase)
         % A function NAME selects that function's method set: griddata allows
         % 'natural', interp2 does not allow 'pchip', mapinterp allows 'cubic'.
         testCase.verifyEqual(validateInterpMethod('natural', 'griddata'), 'natural');
         testCase.verifyEqual(validateInterpMethod('cubic', 'mapinterp'), 'cubic');
         testCase.verifyError(@() validateInterpMethod('pchip', 'interp2'), ...
            'MATLAB:unrecognizedStringChoice');
         testCase.verifyError(@() validateInterpMethod('linear', 'notafunc'), ...
            'matfunclib:validateInterpMethod:unknownFunction');
      end
      function testInterpMethodErrorsOnInvalid(testCase)
         testCase.verifyError(...
            @() validateInterpMethod('notamethod'), ...
            'MATLAB:unrecognizedStringChoice');
      end

      % ---- validateScatteredData ----
      function testValidateScatteredDataReturnsColumns(testCase)
         X = 1:6;
         Y = (1:6) * 2;
         V = rand(1, 6);
         [Vout, Xout, Yout] = validateScatteredData(V, X, Y, 'tc');
         testCase.verifyEqual(size(Xout), [6, 1]);
         testCase.verifyEqual(size(Yout), [6, 1]);
         testCase.verifyEqual(size(Vout), [6, 1]);
      end
      function testValidateScatteredDataErrorsOnMismatch(testCase)
         testCase.verifyError(...
            @() validateScatteredData(rand(4, 1), 1:6, 1:6, 'tc'), ...
            'custom:tc:inconsistentXYV');
      end

      % ---- parseGeoCoordsChoice ----
      function testParseGeoNoConflictReturnsValue(testCase)
         % Detected == requested: no conflict, value passes through.
         UseGeo = parseGeoCoordsChoice(true, true, true, true, 'silent', true);
         testCase.verifyTrue(UseGeo);
      end
      function testParseGeoOverridesDefaultFalse(testCase)
         % Detected geographic; UseGeoCoords false only because it is the
         % default -> detection overrides to true.
         UseGeo = parseGeoCoordsChoice(true, false, false, true, 'silent', true);
         testCase.verifyTrue(UseGeo);
      end
      function testParseGeoRespectsExplicitFalse(testCase)
         % Detected geographic but user explicitly set false -> honored.
         UseGeo = parseGeoCoordsChoice(true, false, false, false, 'silent', true);
         testCase.verifyFalse(UseGeo);
      end

      % ---- mapraster (plot wrapper) ----
      function testMaprasterRunsOnGeoRef(testCase)
         R = testValidatorsAndGeo.geoRef();
         Z = rand(R.RasterSize);
         fig = figure('Visible', 'off');
         closer = onCleanup(@() close(fig));
         try
            mapraster(Z, 'RasterReference', R);
         catch err
            % Skip if optional plotting dependencies are unavailable.
            if any(strcmp(err.identifier, {'MATLAB:UndefinedFunction'})) ...
                  || contains(err.message, 'brewermap') ...
                  || contains(err.message, 'rgb') ...
                  || contains(err.message, 'geomap')
               testCase.assumeFail( ...
                  "mapraster plotting dependency unavailable: " + err.message);
            end
            rethrow(err);
         end
         testCase.verifyTrue(isgraphics(fig));
      end
   end
end
