classdef testIsproject < matlab.unittest.TestCase
   %TESTISPROJECT Tests for the project folder check in isproject,
   %verifyproject and workon.
   %
   % A registry entry can outlive its folder: the folder is moved or
   % deleted. workon must refuse that entry before it changes the active
   % project. Every test redirects the registry environment (the
   % testRegistrySafety pattern), so no test touches the real registries.

   properties
      regDir string
      savedEnv struct = struct()
      % The saved names that were not set, which restoreEnv unsets.
      unsetNames string = string.empty
   end

   properties (Constant)
      envNames = ["MATLAB_DIRECTORY_PATH", "MATLAB_PROJECT_PATH", ...
         "MATLAB_TOOLBOX_PATH", "MATLAB_ACTIVE_PROJECT", ...
         "MATLAB_ACTIVE_PROJECT_PATH", "MATLAB_ACTIVE_PROJECT_DATA_PATH"]
   end

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

   methods (TestMethodSetup)
      function buildRegistry(testCase)
         import matlab.unittest.fixtures.TemporaryFolderFixture

         for name = testCase.envNames
            testCase.savedEnv.(matlab.lang.makeValidName(name)) = getenv(name);
         end
         testCase.unsetNames = testCase.envNames(~isenv(testCase.envNames));
         testCase.addTeardown(@() testCase.restoreEnv())

         tmp = testCase.applyFixture(TemporaryFolderFixture);
         testCase.regDir = string(tmp.Folder);
         setenv('MATLAB_DIRECTORY_PATH', testCase.regDir);
         setenv('MATLAB_PROJECT_PATH', testCase.regDir);
         setenv('MATLAB_TOOLBOX_PATH', fullfile(testCase.regDir, "toolboxes"));

         % Three entries. alpha is active and its folder exists, but not
         % at MATLAB_PROJECT_PATH/alpha, so a folder test that guesses the
         % folder from the name fails. gone is a stale entry: its folder
         % was deleted. default is what workoff activates.
         folders = {char(fullfile(testCase.regDir, "elsewhere", "alpha")); ...
            char(fullfile(testCase.regDir, "gone")); ...
            char(fullfile(testCase.regDir, "default"))};
         mkdir(folders{1})
         mkdir(folders{3})
         projectlist = table({'alpha'; 'gone'; 'default'}, folders, ...
            {{}; {}; {}}, [true; false; false], folders, ...
            VariableNames={'name', 'folder', 'activefiles', ...
            'activeproject', 'activefolder'});
         writeprjdirectory(projectlist)
         setenv('MATLAB_ACTIVE_PROJECT', 'alpha')
      end
   end

   methods (Access = private)
      function restoreEnv(testCase)
         %RESTOREENV Put back the saved env values.
         for name = testCase.envNames
            if ismember(name, testCase.unsetNames)
               % getenv returns '' for an unset name and for a name set to
               % '', so isenv, saved in setup, tells the two apart.
               unsetenv(name);
            else
               setenv(name, ...
                  testCase.savedEnv.(matlab.lang.makeValidName(name)));
            end
         end
      end
   end

   methods (Test)
      function testRegisteredProjectWithFolder(testCase)
         % The folder is the one the entry records, not one built from
         % the name.
         [returned, hasfolder] = isproject('alpha');
         testCase.verifyTrue(returned)
         testCase.verifyTrue(hasfolder)
         testCase.verifyTrue( ...
            isproject('alpha', 'require_project_folder_exists'))
      end

      function testRegisteredProjectWithoutFolder(testCase)
         % Without the option the entry alone counts. With it, the missing
         % folder makes tf false.
         [returned, hasfolder] = isproject('gone');
         testCase.verifyTrue(returned)
         testCase.verifyFalse(hasfolder)
         testCase.verifyFalse( ...
            isproject('gone', 'require_project_folder_exists'))
      end

      function testUnregisteredProject(testCase)
         % A name with no entry has no folder to test.
         [returned, hasfolder] = isproject('nosuchproject');
         testCase.verifyFalse(returned)
         testCase.verifyFalse(hasfolder)
         testCase.verifyFalse( ...
            isproject('nosuchproject', 'require_project_folder_exists'))
      end

      function testVerifyprojectWarnsOnMissingFolder(testCase)
         % The entry exists, so there is no prompt to add it. The missing
         % folder gives a named warning and ok false.
         returned = testCase.verifyWarning(@() verifyproject('gone'), ...
            'matfunclib:verifyproject:missingFolder');
         testCase.verifyFalse(returned)
         testCase.verifyTrue(verifyproject('alpha'))
      end

      function testWorkonRefusesMissingFolderBeforeStateChanges(testCase)
         % workon returns before workoff, so alpha stays active in the
         % environment and in the registry, and the current folder does
         % not change.
         start = pwd;
         testCase.verifyWarning(@() workon('gone', 'updatefiles', false), ...
            'matfunclib:verifyproject:missingFolder')

         testCase.verifyEqual(getenv('MATLAB_ACTIVE_PROJECT'), 'alpha')
         projectlist = readprjdirectory();
         returned = projectlist.name(projectlist.activeproject);
         expected = {'alpha'};
         testCase.verifyEqual(returned, expected)
         testCase.verifyEqual(pwd, start)
      end
   end
end
