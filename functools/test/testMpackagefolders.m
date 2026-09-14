classdef testMpackagefolders < matlab.unittest.TestCase
   %TESTMPACKAGEFOLDERS Unit tests for the mpackagefolders package lister.
   %
   % The tests build a temporary folder that holds one package folder. They
   % cover the aspathlist and asstring options. A toolbox's makecontents
   % calls mpackagefolders with both options to find its package folders.

   properties (Access = private)
      % Full path of the temporary folder that holds the test tree.
      target
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so mpackagefolders resolves from the
         % repo root without a manual addpath.
         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end

      function setupTree(testCase)
         import matlab.unittest.fixtures.TemporaryFolderFixture

         % Build target/file1.m and target/+pkg/pkgfun.m in a temporary
         % folder so no test lists or writes inside the repository.
         folder = testCase.applyFixture(TemporaryFolderFixture);
         testCase.target = folder.Folder;
         fclose(fopen(fullfile(testCase.target, 'file1.m'), 'w'));
         mkdir(fullfile(testCase.target, '+pkg'));
         fclose(fopen(fullfile(testCase.target, '+pkg', 'pkgfun.m'), 'w'));
      end
   end

   methods (Test)
      function testPathlistAsString(testCase)
         % The aspathlist and asstring options return the full path of the
         % +pkg folder as a string.
         returned = mpackagefolders(testCase.target, ...
            'aspathlist', true, 'asstring', true);
         expected = string(fullfile(testCase.target, '+pkg'));
         testCase.verifyEqual(returned, expected)
      end
   end
end
