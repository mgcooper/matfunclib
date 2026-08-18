classdef testProjectState < matlab.unittest.TestCase
   %TESTPROJECTSTATE Unit tests for the Project state classifier.
   %
   % Every case builds its markers as plain files and folders inside a
   % TemporaryFolderFixture. No Project is opened, so no path or
   % Project state leaks between tests. The classifier reads the marker
   % files, which is what makes that possible.

   properties
      % Root of the per-test fixture tree holding the classified folder.
      base string

      % The folder each test classifies.
      folder string
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so projectstate resolves from the
         % repo root without a startup file.
         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (TestMethodSetup)
      function buildFixtureTree(testCase)
         import matlab.unittest.fixtures.TemporaryFolderFixture

         tmp = testCase.applyFixture(TemporaryFolderFixture);
         testCase.base = string(tmp.Folder);
         testCase.folder = fullfile(testCase.base, "fixtureproj");
         mkdir(testCase.folder)
      end
   end

   methods (Test)
      function testMissingFolder(testCase)
         % A directory entry whose folder was deleted or moved is a
         % state, not an error, so callers keep their own diagnostic.
         returned = projectstate(fullfile(testCase.base, "nosuchfolder"));
         expected = "missing";
         testCase.verifyEqual(returned, expected)
      end

      function testNeitherMarker(testCase)
         % An ordinary folder is creatable Project state.
         returned = projectstate(testCase.folder);
         expected = "none";
         testCase.verifyEqual(returned, expected)
      end

      function testBothMarkers(testCase)
         % Both markers present: openProject can open the folder.
         testCase.writeProjectFile("FixtureProj.prj");
         mkdir(fullfile(testCase.folder, "resources", "project"))

         returned = projectstate(testCase.folder);
         expected = "project";
         testCase.verifyEqual(returned, expected)
      end

      function testProjectFileWithoutResources(testCase)
         % The 107-byte .prj stubs matfunclib carried: a Project file
         % with no resources tree cannot be opened.
         testCase.writeProjectFile("FixtureProj.prj");

         returned = projectstate(testCase.folder);
         expected = "orphaned";
         testCase.verifyEqual(returned, expected)
      end

      function testResourcesWithoutProjectFile(testCase)
         % The hydrobasins breakage: a committed resources tree with no
         % .prj beside it.
         mkdir(fullfile(testCase.folder, "resources", "project"))

         returned = projectstate(testCase.folder);
         expected = "orphaned";
         testCase.verifyEqual(returned, expected)
      end

      function testForeignPrjIsNotProjectState(testCase)
         % templates/geoprojtemplate.prj is an ESRI coordinate-system
         % file, and icom-msd's toolboxPackaging.prj is a Deployment
         % configuration. Neither is Project state, so a folder holding
         % one is still creatable rather than orphaned.
         writelines("GEOGCS[""GCS_WGS_1984""]", ...
            fullfile(testCase.folder, "geoprojtemplate.prj"));
         writelines(["<?xml version=""1.0"" encoding=""UTF-8""?>"; ...
            "<deployment-project plugin=""plugin.toolbox"">"; ...
            "</deployment-project>"], ...
            fullfile(testCase.folder, "toolboxPackaging.prj"));

         returned = projectstate(testCase.folder);
         expected = "none";
         testCase.verifyEqual(returned, expected)
      end

      function testRootElementMustMatchExactly(testCase)
         % The classifier compares the root element name, not a
         % substring, so a longer element name and a comment that
         % mentions MATLABProject are both foreign.
         writelines(["<?xml version=""1.0"" encoding=""UTF-8""?>"; ...
            "<MATLABProjectBackup/>"], ...
            fullfile(testCase.folder, "backup.prj"));
         writelines(["<?xml version=""1.0"" encoding=""UTF-8""?>"; ...
            "<!-- exported from <MATLABProject/> on 01-Jan-2024 -->"; ...
            "<deployment-project/>"], ...
            fullfile(testCase.folder, "packaging.prj"));

         returned = projectstate(testCase.folder);
         expected = "none";
         testCase.verifyEqual(returned, expected)
      end

      function testByteOrderMarkIsIgnored(testCase)
         % A UTF-8 byte order mark reaches the read as one character
         % ahead of the XML declaration. It must not hide the root
         % element from the anchored match.
         writelines([string(char(65279)) + ...
            "<?xml version=""1.0"" encoding=""UTF-8""?>"; ...
            "<MATLABProject xmlns=""http://www.mathworks.com/" + ...
            "MATLABProjectFile""/>"], ...
            fullfile(testCase.folder, "FixtureProj.prj"));
         mkdir(fullfile(testCase.folder, "resources", "project"))

         returned = projectstate(testCase.folder);
         expected = "project";
         testCase.verifyEqual(returned, expected)
      end

      function testMarkupAfterTextIsNotARoot(testCase)
         % The root element must open the document. A text file that
         % mentions the markup further down, or leaves a comment
         % unterminated around it, is foreign either way.
         writelines(["GEOGCS[""GCS_WGS_1984""]"; ...
            "<MATLABProject/>"], ...
            fullfile(testCase.folder, "wkt.prj"));
         writelines(["<!-- unterminated"; "<MATLABProject/>"], ...
            fullfile(testCase.folder, "truncated.prj"));

         returned = projectstate(testCase.folder);
         expected = "none";
         testCase.verifyEqual(returned, expected)
      end

      function testRootElementFoundAfterALongProlog(testCase)
         % An XML prolog has no length limit, so the classifier reads
         % the whole file: a comment that runs past any fixed header
         % size must not hide the root element behind it.
         filler = repmat('x', 1, 4096);
         writelines(["<?xml version=""1.0"" encoding=""UTF-8""?>"; ...
            "<!-- " + string(filler) + " -->"; ...
            "<MATLABProject xmlns=""http://www.mathworks.com/" + ...
            "MATLABProjectFile""/>"], ...
            fullfile(testCase.folder, "FixtureProj.prj"));
         mkdir(fullfile(testCase.folder, "resources", "project"))

         returned = projectstate(testCase.folder);
         expected = "project";
         testCase.verifyEqual(returned, expected)
      end

      function testUnreadablePrjIsNotProjectState(testCase)
         % A folder named *.prj appears in the listing but cannot be
         % opened for reading, so the classifier skips it instead of
         % erroring.
         mkdir(fullfile(testCase.folder, "blocked.prj"))

         returned = projectstate(testCase.folder);
         expected = "none";
         testCase.verifyEqual(returned, expected)
      end

      function testProjectFileBesideForeignPrj(testCase)
         % A real Project file is found even when a foreign .prj sorts
         % ahead of it in the folder listing.
         writelines("GEOGCS[""GCS_WGS_1984""]", ...
            fullfile(testCase.folder, "aaageoproj.prj"));
         testCase.writeProjectFile("FixtureProj.prj");
         mkdir(fullfile(testCase.folder, "resources", "project"))

         returned = projectstate(testCase.folder);
         expected = "project";
         testCase.verifyEqual(returned, expected)
      end
   end

   methods (Access = private)
      function writeProjectFile(testCase, name)
         %WRITEPROJECTFILE Write a MATLAB Project file marker.
         %
         % The two lines are what matlab.project.createProject writes:
         % an XML declaration and a MATLABProject root element.

         writelines(["<?xml version=""1.0"" encoding=""UTF-8""?>"; ...
            "<MATLABProject xmlns=""http://www.mathworks.com/" + ...
            "MATLABProjectFile""/>"], ...
            fullfile(testCase.folder, name));
      end
   end
end
