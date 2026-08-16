classdef testIsvariable < matlab.unittest.TestCase
   %TESTISVARIABLE Unit tests for the reconciled multi-name isvariable.

   properties
      tbl table
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so isvariable resolves from the repo
         % root.
         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end

      function makeFixtureTable(testCase)
         testCase.tbl = table((1:3)', (4:6)', ...
            VariableNames=["alpha", "beta"]);
      end
   end

   methods (Test)
      function testPresentVariableChar(testCase)
         [returned_tf, returned_vi] = isvariable('beta', testCase.tbl);
         testCase.verifyTrue(returned_tf)
         expected = 2;
         testCase.verifyEqual(returned_vi, expected)
      end

      function testPresentVariableString(testCase)
         % String scalars are accepted via the char() conversion.
         [returned_tf, returned_vi] = isvariable("alpha", testCase.tbl);
         testCase.verifyTrue(returned_tf)
         expected = 1;
         testCase.verifyEqual(returned_vi, expected)
      end

      function testAbsentVariable(testCase)
         [returned_tf, returned_vi] = isvariable('gamma', testCase.tbl);
         testCase.verifyFalse(returned_tf)
         testCase.verifyEmpty(returned_vi)
      end

      function testNonTabularErrors(testCase)
         % The arguments-block tabular spec rejects non-tabular input; the
         % exact identifier is a MATLAB validation internal, so assert only
         % that an error is thrown.
         import matlab.unittest.constraints.Throws
         testCase.verifyThat( ...
            @() isvariable('alpha', 42), Throws(?MException))
      end

      function testMultipleNames(testCase)
         % Reconciled multi-name semantics: one logical per name, and vi
         % holds indices of the found names only.
         [returned_tf, returned_vi] = isvariable( ...
            ["alpha"; "gamma"; "beta"], testCase.tbl);
         expected_tf = [true; false; true];
         expected_vi = [1; 2];
         testCase.verifyEqual(returned_tf, expected_tf)
         testCase.verifyEqual(returned_vi, expected_vi)
      end

      function testEmptyTableIsGuardSafe(testCase)
         % Zero-row tables with defined variables must not error: callers
         % use isvariable as a boolean guard on possibly-empty tables.
         emptyTbl = table('Size', [0 2], ...
            VariableTypes=["double", "double"], ...
            VariableNames=["alpha", "beta"]);
         [returned_tf, returned_vi] = isvariable('alpha', emptyTbl);
         testCase.verifyTrue(returned_tf)
         expected = 1;
         testCase.verifyEqual(returned_vi, expected)
      end
   end
end
