classdef testManifest < matlab.unittest.TestCase
   %TESTMANIFEST Unit tests for the mproject.toml manifest reader.

   properties
      projDir string
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so readmanifest resolves from the
         % repo root.
         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (TestMethodSetup)
      function makeProjDir(testCase)
         import matlab.unittest.fixtures.TemporaryFolderFixture
         tmp = testCase.applyFixture(TemporaryFolderFixture);
         testCase.projDir = string(tmp.Folder);
      end
   end

   methods (Access = private)
      function writeManifest(testCase, lines)
         writelines(lines, fullfile(testCase.projDir, "mproject.toml"))
      end
   end

   methods (Test)
      function testMissingManifestMeansNoDeps(testCase)
         % No mproject.toml is not an error: empty lists come back.
         returned = readmanifest(testCase.projDir);
         testCase.verifyEmpty(returned.projects)
         testCase.verifyEmpty(returned.toolboxes)
         testCase.verifyEmpty(returned.file)
      end

      function testFullSchema(testCase)
         testCase.writeManifest([ ...
            "[project]"; ...
            "name = ""alpha"""; ...
            "[dependencies]"; ...
            "projects = [""beta"", ""gamma""]"; ...
            "toolboxes = [""tbfix""]"]);
         returned = readmanifest(testCase.projDir);
         testCase.verifyEqual(returned.name, 'alpha')
         testCase.verifyEqual(returned.projects, {'beta', 'gamma'})
         testCase.verifyEqual(returned.toolboxes, {'tbfix'})
         testCase.verifyEqual(returned.file, ...
            char(fullfile(testCase.projDir, "mproject.toml")))
      end

      function testLoneStringNormalizesToCellstr(testCase)
         % A scalar dependency written without array brackets still works.
         testCase.writeManifest([ ...
            "[dependencies]"; ...
            "toolboxes = ""tbfix"""]);
         returned = readmanifest(testCase.projDir);
         expected = {'tbfix'};
         testCase.verifyEqual(returned.toolboxes, expected)
      end

      function testNoDependenciesSection(testCase)
         testCase.writeManifest(["[project]"; "name = ""alpha"""]);
         returned = readmanifest(testCase.projDir);
         testCase.verifyEqual(returned.name, 'alpha')
         testCase.verifyEmpty(returned.projects)
      end

      function testUnknownDependencyTypeErrors(testCase)
         % A typo like "toolbox" must fail fast rather than declare
         % nothing.
         testCase.writeManifest([ ...
            "[dependencies]"; ...
            "toolbox = [""tbfix""]"]);
         testCase.verifyError(@() readmanifest(testCase.projDir), ...
            'matfunclib:readmanifest:unknownDependencyType')
      end

      function testNonStringListErrors(testCase)
         testCase.writeManifest([ ...
            "[dependencies]"; ...
            "projects = 3"]);
         testCase.verifyError(@() readmanifest(testCase.projDir), ...
            'matfunclib:readmanifest:badDependencyList')
      end
   end
end
