classdef testProjectFile < matlab.unittest.TestCase
   %TESTPROJECTFILE Tests for the matfunclib hub entry point (juq.32).
   %
   % The repository root's projectfile.m lists the sub-libraries and
   % calls createhubproject. Generation itself is covered by
   % testCreateHubProject against a fixture tree. These tests cover
   % projectfile's own interface and the Project state its roster
   % produced. They open the repository's own Project, which converges
   % and changes no file.
   %
   % Closing a Project removes its Project path entries, and the hub's
   % references cover manager itself, so each test restores the path it
   % started with. The path fixture applies per test method for the
   % same reason: a class-level fixture applied before the first open
   % cannot survive the closes.

   properties
      % The repository root, which is also the hub project folder.
      repoRoot string

      % The MATLAB path each test starts from, restored after the
      % closes that strip Project path entries.
      entryPath char
   end

   methods (TestMethodSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         testCase.repoRoot = string(fileparts(libraryFolder));
         testCase.applyFixture(PathFixture(testCase.repoRoot, ...
            "IncludingSubfolders", true));
         testCase.entryPath = path();

         % Close whatever a failing test leaves open, then give the
         % session back the path it had. Teardown runs last in, first
         % out, so the fixture's own restore follows this one.
         testCase.addTeardown(@() path(testCase.entryPath));
         testCase.addTeardown(@() closeprojectunder(testCase.repoRoot));
      end
   end

   methods (Test)
      function testRootFileWinsOverTemplateCopy(testCase)
         % The toolbox template ships its own projectfile.m, so both
         % are on the path here. A bare call must resolve to the
         % repository root's copy. The template's copy would run its
         % toolbox-scoped import over the whole metarepo.
         returned = string(which("projectfile"));
         expected = fullfile(testCase.repoRoot, "projectfile.m");
         testCase.verifyEqual(returned, expected)
      end

      function testUnsupportedOptionErrors(testCase)
         % "create" is the only operation, so anything else fails at
         % the arguments block instead of reaching the generator.
         testCase.verifyError(@() projectfile("delete"), ...
            "MATLAB:validators:mustBeMember")
      end

      function testCreateConvergesOnTheRepository(testCase)
         % The supported operation, run against the repository itself.
         % It converges, so this changes no file: it opens the 20
         % sub-library Projects and the hub and adds nothing. Both call
         % forms run here, which covers the branch that returns the
         % Project and the branch that suppresses it.
         %
         % The hub opens first, which is how a session reaches this
         % call, and it is the demanding case: closing the hub drops
         % manager from the path, so the generator has to restore the
         % path it started from before generating anything.
         openProject(testCase.repoRoot);
         proj = projectfile("create");

         returned = string(proj.RootFolder);
         expected = testCase.repoRoot;
         testCase.verifyEqual(returned, expected)

         returned = numel(proj.ProjectReferences);
         expected = 20;
         testCase.verifyEqual(returned, expected)

         close(proj)
         path(testCase.entryPath);

         % The no-output form suppresses the returned Project instead
         % of echoing it, and converges the same way.
         projectfile("create");
         reopened = matlab.project.rootProject();

         returned = string(reopened.RootFolder);
         expected = testCase.repoRoot;
         testCase.verifyEqual(returned, expected)

         returned = numel(reopened.ProjectReferences);
         expected = 20;
         testCase.verifyEqual(returned, expected)
      end

      function testHubReferencesEveryLibraryProject(testCase)
         % The delivered state: the hub's references are exactly the
         % direct subfolders that are Projects. Two changes break this
         % equality: a sub-library dropped from the roster, and a
         % Project generated in a folder the roster omits. toolbox/
         % must stay free of Project state.
         proj = openProject(testCase.repoRoot);

         nrefs = numel(proj.ProjectReferences);
         referenced = strings(nrefs, 1);
         for k = 1:nrefs
            [~, referenced(k)] = fileparts( ...
               string(proj.ProjectReferences(k).Project.RootFolder));
         end

         listing = dir(testCase.repoRoot);
         listing = listing([listing.isdir]);
         listing = listing(~startsWith({listing.name}, "."));
         candidates = string({listing.name}).';
         isproj = false(numel(candidates), 1);
         for k = 1:numel(candidates)
            isproj(k) = projectstate( ...
               fullfile(testCase.repoRoot, candidates(k))) == "project";
         end

         returned = sort(referenced);
         expected = sort(candidates(isproj));
         testCase.verifyEqual(returned, expected)
      end

      function testEveryReferenceHoldsItsFiles(testCase)
         % A Project member whose file is gone is a broken reference
         % target: the hub opens, but the sub-library reports missing
         % files. The nested .gitignore and .gitattributes MATLAB
         % writes at creation are members, so deleting them from disk
         % would break this.
         proj = openProject(testCase.repoRoot);

         nrefs = numel(proj.ProjectReferences);
         absent = cell(nrefs, 1);
         for k = 1:nrefs
            files = listprojectfiles(proj.ProjectReferences(k).Project);
            absent{k} = files(~isfile(files) & ~isfolder(files));
         end

         returned = vertcat(absent{:});
         expected = strings(0, 1);
         testCase.verifyEqual(returned, expected)
      end
   end
end
