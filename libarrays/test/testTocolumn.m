classdef testTocolumn < matlab.unittest.TestCase
   %TESTTOCOLUMN Unit tests for tocolumn.
   %
   % tocolumn returns Array(:), so each expected column lists the input
   % elements in column-major order.

   properties (TestParameter)
      % Each case holds an input and its expected column. A row becomes a
      % column; a column and a scalar are unchanged. Matrices and N-D arrays
      % unroll in column-major order. Empty inputs return a 0-by-1 column of
      % the same class. Cell, char, and logical rows keep their class.
      arraycase = struct( ...
         'row', {{[1, 2, 3], [1; 2; 3]}}, ...
         'column', {{[4; 5; 6], [4; 5; 6]}}, ...
         'scalar', {{7, 7}}, ...
         'matrix', {{[1, 3; 2, 4], [1; 2; 3; 4]}}, ...
         'ndArray', {{cat(3, [1, 3; 2, 4], [5, 7; 6, 8]), ...
         [1; 2; 3; 4; 5; 6; 7; 8]}}, ...
         'empty', {{[], zeros(0, 1)}}, ...
         'rowEmpty', {{zeros(1, 0), zeros(0, 1)}}, ...
         'cellRow', {{{'a', 'b'}, {'a'; 'b'}}}, ...
         'charRow', {{'ab', ['a'; 'b']}}, ...
         'logicalRow', {{[true, false], [true; false]}})
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so tocolumn resolves from the repo
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
      function testColumn(testCase, arraycase)
         % tocolumn returns the input elements as a column.
         [array, expected] = arraycase{:};
         returned = tocolumn(array);
         testCase.verifyEqual(returned, expected)
      end

      function testMissingInput(testCase)
         % tocolumn requires one input.
         errid = 'MATLAB:minrhs';
         testCase.verifyError(@() tocolumn(), errid)
      end
   end
end
