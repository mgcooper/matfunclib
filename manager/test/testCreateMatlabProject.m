classdef testCreateMatlabProject < matlab.unittest.TestCase
   %TESTCREATEMATLABPROJECT Unit tests for the Project generator core (juq.29).
   %
   % Every test builds its Project inside a TemporaryFolderFixture and
   % closes it before the fixture folder is destroyed, so no Project or
   % path state leaks between tests and the real environment is never
   % touched. The fixture projects carry no mproject.toml, so the
   % default references pass declares nothing and never reads the
   % project directory.

   properties
      % Root of the per-test fixture tree holding the project folder.
      base string

      % The project folder the tests generate into.
      projDir string

      % MATLAB_PROJECT_PATH value saved for restoration in teardown.
      savedProjectPath char = ''
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so createMatlabProject and its
         % manager helpers resolve from the repo root.
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
         testCase.projDir = fullfile(testCase.base, "fixtureproj");

         % A project tree with top-level code, a shipped subfolder, and
         % a scratch subfolder the ignore option excludes.
         mkdir(fullfile(testCase.projDir, "toolbox"))
         mkdir(fullfile(testCase.projDir, "sandbox"))
         writelines(["function y = topfun(x)"; "y = x;"; "end"], ...
            fullfile(testCase.projDir, "topfun.m"));
         writelines(["function y = shipped(x)"; "y = x;"; "end"], ...
            fullfile(testCase.projDir, "toolbox", "shipped.m"));
         writelines(["function y = scratch(x)"; "y = x;"; "end"], ...
            fullfile(testCase.projDir, "sandbox", "scratch.m"));

         % The generator resolves bare names against MATLAB_PROJECT_PATH;
         % save it here and restore it after each test.
         testCase.savedProjectPath = getenv("MATLAB_PROJECT_PATH");
         testCase.addTeardown(@() setenv("MATLAB_PROJECT_PATH", ...
            testCase.savedProjectPath));

         % Close any Project the test leaves open before the fixture
         % folder is deleted out from under it (shared suite helper).
         testCase.addTeardown(@() closeprojectunder(testCase.base));
      end
   end

   methods (Test)
      function testCreateMakesAProject(testCase)
         % Creation writes the Project metadata and returns the open
         % Project rooted at the fixture folder.
         proj = createMatlabProject(testCase.projDir);

         returned = isfolder(fullfile(testCase.projDir, ...
            "resources", "project"));
         expected = true;
         testCase.verifyEqual(returned, expected)

         returned = endsWith(string(proj.RootFolder), "fixtureproj");
         testCase.verifyTrue(returned)
      end

      function testDoubleRunIsIdempotent(testCase)
         % The double-run proof: a second call opens the existing
         % Project and adds nothing, so the file set is unchanged.
         first = createMatlabProject(testCase.projDir, ...
            addProjectFiles=true, addProjectFolders=true, ...
            addChildFiles=true);
         expected = sort(listprojectfiles(first));
         close(first)

         second = createMatlabProject(testCase.projDir, ...
            addProjectFiles=true, addProjectFolders=true, ...
            addChildFiles=true);
         returned = sort(listprojectfiles(second));
         testCase.verifyEqual(returned, expected)
      end

      function testAddProjectFilesImportsTopLevel(testCase)
         % addProjectFiles imports the top-level *.m files and nothing
         % below the root.
         proj = createMatlabProject(testCase.projDir, ...
            addProjectFiles=true);
         files = listprojectfiles(proj);

         returned = any(endsWith(files, "topfun.m"));
         testCase.verifyTrue(returned)

         returned = any(endsWith(files, "shipped.m"));
         testCase.verifyFalse(returned)
      end

      function testProjectSubfoldersRestrictsImport(testCase)
         % projectSubfolders="toolbox" scopes the import to the shipped
         % folder; the sandbox tree stays out.
         proj = createMatlabProject(testCase.projDir, ...
            addProjectFolders=true, addChildFiles=true, ...
            projectSubfolders="toolbox");
         files = listprojectfiles(proj);

         returned = any(endsWith(files, "shipped.m"));
         testCase.verifyTrue(returned)

         returned = any(endsWith(files, "scratch.m"));
         testCase.verifyFalse(returned)
      end

      function testIgnoredSubFoldersExcludesTree(testCase)
         % An ignored folder name excludes its whole subtree from a full
         % import.
         proj = createMatlabProject(testCase.projDir, ...
            addProjectFolders=true, addChildFiles=true, ...
            ignoredSubFolders="sandbox");
         files = listprojectfiles(proj);

         returned = any(endsWith(files, "shipped.m"));
         testCase.verifyTrue(returned)

         returned = any(endsWith(files, "scratch.m"));
         testCase.verifyFalse(returned)
      end

      function testBareNameResolvesThroughEnv(testCase)
         % A bare project name resolves under MATLAB_PROJECT_PATH,
         % matching how the project directory addresses projects.
         setenv("MATLAB_PROJECT_PATH", char(testCase.base));
         proj = createMatlabProject("fixtureproj");

         returned = endsWith(string(proj.RootFolder), "fixtureproj");
         testCase.verifyTrue(returned)
      end

      function testMissingFolderErrors(testCase)
         % A name that is neither a folder nor resolvable under the env
         % var fails fast with the identified error.
         setenv("MATLAB_PROJECT_PATH", char(testCase.base));
         testCase.verifyError( ...
            @() createMatlabProject("no-such-project"), ...
            "matfunclib:createMatlabProject:folderNotFound")
      end

      function testUnmatchedSubfolderErrors(testCase)
         % A projectSubfolders name with no matching folder fails fast
         % rather than importing nothing without a message.
         testCase.verifyError( ...
            @() createMatlabProject(testCase.projDir, ...
            addProjectFolders=true, ...
            projectSubfolders="nosuchfolder"), ...
            "matfunclib:createMatlabProject:subfolderNotFound")
      end

      function testFilterWithoutImportErrors(testCase)
         % projectSubfolders refines the folder import; passing it with
         % the import disabled selects nothing, so it fails fast
         % instead.
         testCase.verifyError( ...
            @() createMatlabProject(testCase.projDir, ...
            projectSubfolders="toolbox"), ...
            "matfunclib:createMatlabProject:filterWithoutImport")
      end

      function testProjectPathExposesCodeRoots(testCase)
         % addFile tracks membership only; the selected code roots must
         % land on the Project path so a clean-session openProject
         % exposes the code.
         proj = createMatlabProject(testCase.projDir, ...
            addProjectFiles=true, addProjectFolders=true, ...
            addChildFiles=true);
         close(proj)

         reopened = openProject(testCase.projDir);
         held = string({reopened.ProjectPath.File}).';

         returned = any(held == string(reopened.RootFolder));
         testCase.verifyTrue(returned)

         returned = any(endsWith(held, filesep + "toolbox"));
         testCase.verifyTrue(returned)
      end

      function testSubprojectsAddsInternalReferences(testCase)
         % The hub layout in one call: a subfolder that is a Project of
         % its own becomes an internal Referenced Project. The
         % sub-library is generated first because addReference requires
         % an openable target (leaves-first).
         subDir = fullfile(testCase.projDir, "sublib");
         mkdir(subDir)
         writelines(["function y = subfun(x)"; "y = x;"; "end"], ...
            fullfile(subDir, "subfun.m"));
         sub = createMatlabProject(subDir, addProjectFiles=true);
         close(sub)

         proj = createMatlabProject(testCase.projDir, ...
            subprojects="sublib");

         returned = numel(proj.ProjectReferences);
         expected = 1;
         testCase.verifyEqual(returned, expected)

         returned = endsWith( ...
            string(proj.ProjectReferences(1).Project.RootFolder), ...
            "sublib");
         testCase.verifyTrue(returned)
      end

      function testEmptySubprojectsRemovesInternalReferences(testCase)
         % The option separates "omitted" from "explicitly empty": an
         % omitted option leaves held internal references alone, and an
         % empty list reconciles them down to none. Both forwarding
         % branches run here, in that order.
         subDir = fullfile(testCase.projDir, "sublib");
         mkdir(subDir)
         writelines(["function y = subfun(x)"; "y = x;"; "end"], ...
            fullfile(subDir, "subfun.m"));
         sub = createMatlabProject(subDir, addProjectFiles=true);
         close(sub)
         held = createMatlabProject(testCase.projDir, ...
            subprojects="sublib");
         close(held)

         kept = createMatlabProject(testCase.projDir);
         returned = numel(kept.ProjectReferences);
         expected = 1;
         testCase.verifyEqual(returned, expected)
         close(kept)

         emptied = createMatlabProject(testCase.projDir, ...
            subprojects=strings(0, 1));
         returned = numel(emptied.ProjectReferences);
         expected = 0;
         testCase.verifyEqual(returned, expected)
      end

      function testSubprojectsWithoutReferencesErrors(testCase)
         % The reference pass is what generates internal references, so
         % naming subprojects with it disabled fails fast instead of
         % dropping them without a message.
         testCase.verifyError( ...
            @() createMatlabProject(testCase.projDir, ...
            subprojects="sublib", references=false), ...
            "matfunclib:createMatlabProject:subprojectsWithoutReferences")
      end

      function testOrphanedProjectStateErrors(testCase)
         % A resources/project tree with no root .prj (the hydrobasins
         % breakage) is partial Project state: openProject cannot open
         % it and creating over it would mix stale state in, so the
         % generator fails fast naming the repair.
         mkdir(fullfile(testCase.projDir, "resources", "project"))
         testCase.verifyError( ...
            @() createMatlabProject(testCase.projDir), ...
            "matfunclib:createMatlabProject:orphanedProjectState")
      end
   end
end
