classdef testSiUnitsToTex < matlab.unittest.TestCase
   %TESTSIUNITSTOTEX Unit tests for siUnitsToTex.
   %
   % siUnitsToTex wraps each exponent in one pair of braces, then texlabel
   % wraps each letter group and each exponent digit group. The expected
   % strings follow that texlabel brace style.

   properties (TestParameter)
      % Each case holds one SI unit and its expected TeX label.
      unitcase = struct( ...
         'positiveExponent', {{'m2', '{m}^{{2}}'}}, ...
         'negativeExponent', {{'s-1', '{s}^{-{1}}'}}, ...
         'noExponent', {{'mm', '{mm}'}}, ...
         'unitless', {{'-', '-'}})
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so siUnitsToTex resolves from the
         % repo root without a manual addpath.
         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (Test)
      function testSingleUnit(testCase, unitcase)
         % siUnitsToTex converts one unit in a cell to one TeX label.
         [unit, label_expected] = unitcase{:};

         returned = siUnitsToTex({unit});
         expected = {label_expected};
         testCase.verifyEqual(returned, expected)
      end

      function testCellArrayInput(testCase)
         % siUnitsToTex converts each unit of a cell array of compound
         % units and keeps the input size.
         units = {'m3 s-1', 'mm d-1', 'm2'};

         returned = siUnitsToTex(units);
         expected = {'{m}^{{3}} {s}^{-{1}}', '{mm} {d}^{-{1}}', '{m}^{{2}}'};
         testCase.verifyEqual(returned, expected)
      end
   end
end
