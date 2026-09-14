classdef testRunlength < matlab.unittest.TestCase
   %TESTRUNLENGTH Unit tests for runlength.
   %
   % runlength counts each NaN as its own run of length 1, because NaN
   % never equals NaN. Callers such as isminlength use NaN to break runs,
   % so these tests keep a cleanup from merging consecutive NaNs.
   %
   % ISTART and ISTOP are linear indices into a padded array with
   % size(M,1)+1 rows, so ISTOP - ISTART is the length of each run.

   properties (TestParameter)
      % Each case holds an input M and its expected RL, ISTART, and ISTOP.
      % The vector case has three consecutive NaNs, which give three runs.
      % The matrix case counts each column on its own: the 5-row padded
      % array puts column 2 at linear indices 6 to 10.
      runcase = struct( ...
         'nanRuns', {{[1; 1; NaN; NaN; NaN; 2; 2], ...
         [2; 2; 1; 1; 1; 2; 2], [1; 3; 4; 5; 6], [3; 4; 5; 6; 8]}}, ...
         'columns', {{[1, 5; 1, 5; NaN, 5; NaN, 6], ...
         [2, 3; 2, 3; 1, 3; 1, 1], [1; 3; 4; 6; 9], [3; 4; 5; 9; 10]}})
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so runlength resolves from the repo
         % root without a manual addpath.
         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (Test)
      function testRunsAndIndices(testCase, runcase)
         % runlength returns the run length of each element and one start
         % and stop index per run, with one run per NaN.
         [M, RL_expected, istart_expected, istop_expected] = runcase{:};
         [RL_returned, istart_returned, istop_returned] = runlength(M);
         testCase.verifyEqual(RL_returned, RL_expected)
         testCase.verifyEqual(istart_returned, istart_expected)
         testCase.verifyEqual(istop_returned, istop_expected)
      end
   end
end
