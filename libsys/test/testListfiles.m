classdef testListfiles < matlab.unittest.TestCase
   %TESTLISTFILES Unit tests for the listfiles folder-listing helper.
   %
   % The tests build a small tree in a temporary folder. They cover the
   % positional folder input, the default dir-style struct, the mfiles,
   % aslist, asstring, and subfolders options, the arguments-block
   % conversion of numeric 1 to logical, and the error for an unknown
   % option.

   properties (TestParameter)
      % The listing scope and the sorted .m file names it returns. The
      % subfolders option adds the file in the +pkg folder.
      scope = struct( ...
         'topfolder', struct('subfolders', false, 'expected', "file1.m"), ...
         'subfolders', struct('subfolders', true, ...
         'expected', ["file1.m"; "pkgfun.m"]))

      % The value passed to the true options: a logical, and the numeric 1
      % that the arguments block converts to logical.
      truevalue = struct('logical', true, 'numeric', 1)
   end

   properties (Access = private)
      % Full path of the temporary folder that holds the test tree.
      target
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so listfiles and its helpers resolve
         % from the repo root without a manual addpath.
         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end

      function setupTree(testCase)
         import matlab.unittest.fixtures.TemporaryFolderFixture

         % Build a small tree in a temporary folder so no test lists or
         % writes inside the repository: target/file1.m,
         % target/notes.txt, and target/+pkg/pkgfun.m.
         folder = testCase.applyFixture(TemporaryFolderFixture);
         testCase.target = folder.Folder;
         fclose(fopen(fullfile(testCase.target, 'file1.m'), 'w'));
         fclose(fopen(fullfile(testCase.target, 'notes.txt'), 'w'));
         mkdir(fullfile(testCase.target, '+pkg'));
         fclose(fopen(fullfile(testCase.target, '+pkg', 'pkgfun.m'), 'w'));
      end
   end

   methods (Test)
      function testStructDefault(testCase)
         % The default returns a dir-style struct of the folder's files,
         % without the +pkg folder or its file.
         returned = listfiles(testCase.target);
         testCase.verifyClass(returned, 'struct')
         expected = {'file1.m', 'notes.txt'};
         testCase.verifyEqual(sort({returned.name}), expected)
      end

      function testMfilesAsStringList(testCase, scope, truevalue)
         % The mfiles filter with aslist and asstring returns only .m
         % names, for each listing scope and each form of the true value.
         returned = listfiles(testCase.target, ...
            'subfolders', scope.subfolders, 'aslist', truevalue, ...
            'asstring', truevalue, 'mfiles', truevalue);
         testCase.verifyEqual(sort(returned), scope.expected)
      end

      function testRejectsAnUnknownOption(testCase)
         % An unknown name-value option raises the arguments-block error,
         % which MATLAB reports as too many inputs.
         expected = 'MATLAB:TooManyInputs';
         testCase.verifyError(@() listfiles(testCase.target, ...
            'nosuchoption', true), expected)
      end
   end
end
