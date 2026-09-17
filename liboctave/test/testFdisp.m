classdef testFdisp < matlab.unittest.TestCase
   %TESTFDISP Unit tests for fdisp, the MATLAB version of Octave's fdisp.
   %
   % The output tests write to a file in a temporary folder and compare the
   % file text with the expected text. In the cell branch, fdisp prints one
   % line per scalar element and one line per row of a larger element.

   properties
      % The file each test writes, inside a TemporaryFolderFixture folder.
      outFile string
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so fdisp resolves from the repo root.
         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (TestMethodSetup)
      function makeOutputFile(testCase)
         import matlab.unittest.fixtures.TemporaryFolderFixture

         folder = testCase.applyFixture(TemporaryFolderFixture).Folder;
         testCase.outFile = fullfile(folder, "out.txt");
      end
   end

   methods (Test)
      function testCellOfScalarsPrintsOneValuePerLine(testCase)
         % A scalar numeric or logical element prints as one value on its
         % own line.
         returned = testCase.write({1, 2.5, true});
         expected = sprintf('1\n2.5\n1\n');
         testCase.verifyEqual(returned, expected)
      end

      function testCellWithMatrixPrintsEachRow(testCase)
         % A larger element prints one line per row, each value followed by
         % a space.
         returned = testCase.write({[1 2; 3 4]});
         expected = sprintf('1 2 \n3 4 \n');
         testCase.verifyEqual(returned, expected)
      end

      function testCellElementOverTheLimitPrintsItsSize(testCase)
         % fdisp does not print an element larger than the size limit. It
         % warns and writes the element's size and class instead. Teardown
         % puts back the warning state the test found.
         [savedMessage, savedId] = lastwarn;
         testCase.addTeardown(@() lastwarn(savedMessage, savedId));
         lastwarn('')
         returned = testCase.write({[1 2 3]}, 2);
         expected = sprintf('[[1 3] double]\n');
         testCase.verifyEqual(returned, expected)
         testCase.verifySubstring(lastwarn, 'exceeds the limit')
      end

      function testCellOfTextPrintsOneLinePerElement(testCase)
         % Character vectors and strings print one per line.
         returned = testCase.write({'a', "b"});
         expected = sprintf('a\nb\n');
         testCase.verifyEqual(returned, expected)
      end

      function testMixedCellErrors(testCase)
         % fdisp rejects a cell that mixes text and numbers.
         fid = fopen(testCase.outFile, 'w');
         testCase.addTeardown(@() fclose(fid));
         testCase.verifyError(@() fdisp(fid, {1, 'a'}), 'fdisp:InvalidInput')
      end
   end

   methods (Access = private)
      function text = write(testCase, x, varargin)
         %WRITE Call fdisp on a new file and return the file's text.
         fid = fopen(testCase.outFile, 'w');
         testCase.assertGreaterThan(fid, 0, 'could not open the output file')
         % The cleanup closes the file even when fdisp raises. Clearing it
         % closes the file before the read.
         closeFile = onCleanup(@() fclose(fid));
         fdisp(fid, x, varargin{:});
         clear closeFile
         text = fileread(testCase.outFile);
      end
   end
end
