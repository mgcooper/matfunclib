classdef testUndersource < matlab.unittest.TestCase
   %TESTUNDERSOURCE Unit tests for functools/undersource.
   %
   % Pure path arithmetic: nothing here touches the file system, so the
   % roots are strings, not real folders.

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so undersource resolves from the repo
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
      function testMatchesOnFolderBoundaries(testCase)
         % The root itself and a child are under it; a sibling whose name
         % starts with the root's name is not, and neither is another folder.
         root = "/tmp/src";
         returned = undersource([root; root + "/lib"; root + "-copy"; ...
            "/tmp/other"], root);
         expected = [true; true; false; false];
         testCase.verifyEqual(returned, expected)
      end

      function testTrailingSeparatorOnRootIsIgnored(testCase)
         % A root given with a trailing separator matches the same folders.
         root = "/tmp/src";
         returned = undersource([root; root + "/lib"; root + "-copy"], ...
            root + "/");
         expected = [true; true; false];
         testCase.verifyEqual(returned, expected)
      end

      function testDotAndDotDotSegmentsResolve(testCase)
         % A ".." that climbs out of the root is not under it; one that
         % climbs within it is; a "." segment is dropped.
         root = "/tmp/src";
         returned = undersource([root + "/../outside"; ...
            root + "/lib/../x"; root + "/./lib"], root);
         expected = [false; true; true];
         testCase.verifyEqual(returned, expected)
      end

      function testEitherSeparatorCounts(testCase)
         % Backslashes normalize to forward slashes on both sides.
         returned = undersource(["C:\src\lib"; "C:/src/lib"; "C:\srcx"], ...
            "C:\src");
         expected = [true; true; false];
         testCase.verifyEqual(returned, expected)
      end

      function testDriveRootClampsParentSegments(testCase)
         % A drive-rooted path is absolute, so ".." cannot climb above
         % "C:". "C:\..\src\lib" is under "C:\src", "C:/../x" is under
         % "C:/", and the drive segment itself is never popped.
         returned = undersource(["C:\..\src\lib"; "C:/../x"; "C:\..\.."], ...
            "C:\src");
         expected = [true; false; false];
         testCase.verifyEqual(returned, expected)

         returned = undersource(["C:/../x"; "C:\"; "D:\x"], "C:/");
         expected = [true; true; false];
         testCase.verifyEqual(returned, expected)
      end

      function testStringArrayInputKeepsShape(testCase)
         % TF has the shape of FOLDER, for a row and for a 2x2 array.
         root = "/r";
         returned = undersource(["/r/a", "/q"], root);
         expected = [true, false];
         testCase.verifyEqual(returned, expected)

         returned = undersource(["/r", "/r/a"; "/q", "/r-x"], root);
         expected = [true, true; false, false];
         testCase.verifyEqual(returned, expected)
      end

      function testEmptyInputReturnsEmptyLogical(testCase)
         % An empty string array answers itself with an empty logical of
         % the same size, not the empty double arrayfun would give.
         returned = undersource(strings(0, 1), "/r");
         expected = false(0, 1);
         testCase.verifyEqual(returned, expected)
      end

      function testUnmatchedParentOnRelativePathIsKept(testCase)
         % A relative path that climbs above its start is a sibling, not
         % the root: "../src/file" is not under "src". An absolute path
         % cannot climb above "/", so "/../src" still normalizes to "/src".
         returned = undersource(["../src/file"; "../../src"; "a/../../src"], "src");
         expected = [false; false; false];
         testCase.verifyEqual(returned, expected)

         returned = undersource("/../src/lib", "/src");
         expected = true;
         testCase.verifyEqual(returned, expected)
      end

      function testFileSystemRootIsAnAncestor(testCase)
         % Everything absolute lies below "/", and "/" is under itself; a
         % relative path is not under "/".
         returned = undersource(["/tmp"; "/"; "/a/b"; "tmp"], "/");
         expected = [true; true; true; false];
         testCase.verifyEqual(returned, expected)
      end

      function testDriveRootDiffersFromDriveRelativeLiteral(testCase)
         % "C:/" is the drive root. "C:" alone is drive-relative, so it
         % is not under "C:/".
         returned = undersource(["C:"; "C:/"; "C:/x"], "C:/");
         expected = [false; true; true];
         testCase.verifyEqual(returned, expected)
      end

      function testUncShareIsTheRoot(testCase)
         % On a UNC path the server and share form the root: ".." never
         % climbs above them, and a path on another share is not under.
         returned = undersource(["\\srv\share\..\lib"; ...
            "//srv/share/lib"; "\\srv\other\lib"], "\\srv\share");
         expected = [true; true; false];
         testCase.verifyEqual(returned, expected)
      end

      function testDotRootIsTheCurrentFolder(testCase)
         % "." (or "") as the root is the current folder: every relative
         % folder is under it, including "." itself, and no absolute one.
         returned = undersource(["src"; "src/lib"; "."; "/abs"; "C:/x"], ".");
         expected = [true; true; true; false; false];
         testCase.verifyEqual(returned, expected)
      end

      function testEscapeDepthMustMatch(testCase)
         % A relative folder is under a relative root only when both climb
         % the same number of ".." above their start, and a drive-rooted
         % folder is never under the drive-relative "C:".
         returned = undersource(["../../x"; "../x"; "../.."; "x"], "..");
         expected = [false; true; false; false];
         testCase.verifyEqual(returned, expected)

         returned = undersource(["C:/x"; "C:x"; "C:"], "C:");
         expected = [false; false; true];
         testCase.verifyEqual(returned, expected)
      end

      function testRelativePathsCompare(testCase)
         % Relative paths normalize the same way; only an absolute root
         % gains the leading separator back.
         returned = undersource(["src/lib"; "src"; "srcx"; "./src/./a"], ...
            "src/");
         expected = [true; true; false; true];
         testCase.verifyEqual(returned, expected)
      end
   end
end
