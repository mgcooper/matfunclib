classdef testIsundefinedfunction < matlab.unittest.TestCase
   %TESTISUNDEFINEDFUNCTION Unit tests for functools/isundefinedfunction.

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (Test)
      function testBothIdentifiersAreRecognized(testCase)
         % A real undefined call and Octave's identifier both count. The
         % Octave forms are given as structs with the two fields the
         % function reads, because MException rejects Octave's hyphenated
         % identifier and an empty one.
         try
            no_such_function_xyz_123();
         catch raised
         end
         returned = isundefinedfunction(raised);
         expected = true;
         testCase.verifyEqual(returned, expected)
         returned = isundefinedfunction(struct( ...
            'identifier', 'Octave:undefined-function', 'message', 'undefined'));
         testCase.verifyEqual(returned, expected)
         % Octave's feval and call forms carry no identifier.
         returned = isundefinedfunction(struct('identifier', '', ...
            'message', "feval: function 'x' not found"));
         testCase.verifyEqual(returned, expected)
         returned = isundefinedfunction(struct('identifier', '', ...
            'message', "'x' undefined near line 2, column 3"));
         testCase.verifyEqual(returned, expected)
      end

      function testOtherErrorsAreNot(testCase)
         % Any other identifier, including none, is not an undefined call.
         returned = isundefinedfunction(MException('a:b', 'other'));
         expected = false;
         testCase.verifyEqual(returned, expected)
         returned = isundefinedfunction(struct('identifier', '', ...
            'message', 'no identifier'));
         testCase.verifyEqual(returned, expected)
      end
   end
end
