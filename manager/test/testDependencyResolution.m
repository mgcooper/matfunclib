classdef testDependencyResolution < matlab.unittest.TestCase
   %TESTDEPENDENCYRESOLUTION Unit tests for manifest resolution (juq.5).
   %
   % Every test redirects the registry, project, and toolbox path env vars
   % to a fresh temp fixture, so the real registries and path state in
   % $HOME/MATLAB are never touched. The fixture declares:
   %
   %   alpha  -> projects [beta], toolboxes [tbfix]
   %   beta   -> projects [gamma]        (exercises transitive resolution)
   %   gamma  -> no manifest
   %   cycA   -> projects [cycB]; cycB -> projects [cycA]   (cycle)
   %   ghosttb / ghostprj -> manifests naming unregistered deps

   properties
      regDir string
      savedEnv struct = struct()
      savedPath char = ''
   end

   properties (Constant)
      % Env vars every test saves, redirects or mutates, and restores.
      envNames = ["PROJECTDIRECTORYPATH", "TBDIRECTORYPATH", ...
         "MATLAB_PROJECT_PATH", "MATLAB_TOOLBOX_PATH", ...
         "MATLAB_ACTIVE_PROJECT", "MATLAB_ACTIVE_PROJECT_PATH", ...
         "MATLAB_ACTIVE_PROJECT_DATA_PATH"]
      projNames = ["alpha", "beta", "gamma", "cycA", "cycB", ...
         "ghosttb", "ghostprj", "default"]
   end

   methods (TestClassSetup)
      function addProjectToPath(testCase)
         import matlab.unittest.fixtures.PathFixture

         % Put matfunclib on the path so the manager functions resolve
         % from the repo root.
         testFile = mfilename("fullpath");
         testFolder = fileparts(testFile);
         libraryFolder = fileparts(testFolder);
         projectFolder = fileparts(libraryFolder);
         testCase.applyFixture(PathFixture(projectFolder, ...
            "IncludingSubfolders", true));
      end
   end

   methods (TestMethodSetup)
      function buildFixtureWorld(testCase)
         import matlab.unittest.fixtures.TemporaryFolderFixture

         % Save and later restore env vars, the MATLAB path (resolution
         % adds fixture folders to it), and the depledger's persistent
         % state (cleared fresh per test).
         for name = testCase.envNames
            testCase.savedEnv.(matlab.lang.makeValidName(name)) = getenv(name);
         end
         testCase.savedPath = path();
         testCase.addTeardown(@() testCase.restoreEnvAndPath())
         clear('depledger')

         tmp = testCase.applyFixture(TemporaryFolderFixture);
         testCase.regDir = string(tmp.Folder);
         setenv('PROJECTDIRECTORYPATH', testCase.regDir);
         setenv('TBDIRECTORYPATH', testCase.regDir);
         setenv('MATLAB_PROJECT_PATH', testCase.regDir);
         setenv('MATLAB_TOOLBOX_PATH', fullfile(testCase.regDir, "toolboxes"));

         % Project folders and registry.
         folders = cell(numel(testCase.projNames), 1);
         for k = 1:numel(testCase.projNames)
            folders{k} = char(fullfile(testCase.regDir, testCase.projNames(k)));
            mkdir(folders{k})
         end
         projectlist = table( ...
            cellstr(testCase.projNames(:)), ...
            folders, ...
            repmat({{}}, numel(folders), 1), ...
            [true; false(numel(folders) - 1, 1)], ...
            folders, ...
            VariableNames={'name', 'folder', 'activefiles', ...
            'activeproject', 'activefolder'});
         writeprjdirectory(projectlist)

         % Toolbox folder and registry (source layout with library="" so
         % activate's parent-repair check matches MATLAB_TOOLBOX_PATH).
         tbfixPath = fullfile(testCase.regDir, "toolboxes", "tbfix");
         mkdir(tbfixPath)
         toolboxes = table({'tbfix'}, {char(tbfixPath)}, false, "", ...
            VariableNames={'name', 'source', 'active', 'library'});
         writetbdirectory(toolboxes)

         % Manifests.
         writelines([ ...
            "[project]"; "name = ""alpha"""; ...
            "[dependencies]"; ...
            "projects = [""beta""]"; ...
            "toolboxes = [""tbfix""]"], ...
            fullfile(testCase.regDir, "alpha", "mproject.toml"))
         writelines(["[dependencies]"; "projects = [""gamma""]"], ...
            fullfile(testCase.regDir, "beta", "mproject.toml"))
         writelines(["[dependencies]"; "projects = [""cycB""]"], ...
            fullfile(testCase.regDir, "cycA", "mproject.toml"))
         writelines(["[dependencies]"; "projects = [""cycA""]"], ...
            fullfile(testCase.regDir, "cycB", "mproject.toml"))
         writelines(["[dependencies]"; "toolboxes = [""nosuchtb""]"], ...
            fullfile(testCase.regDir, "ghosttb", "mproject.toml"))
         writelines(["[dependencies]"; "projects = [""nosuchprj""]"], ...
            fullfile(testCase.regDir, "ghostprj", "mproject.toml"))
      end
   end

   methods (Access = private)
      function restoreEnvAndPath(testCase)
         for name = testCase.envNames
            setenv(name, testCase.savedEnv.(matlab.lang.makeValidName(name)));
         end
         path(testCase.savedPath)
      end

      function tf = fixtureOnPath(testCase, name)
         folder = char(fullfile(testCase.regDir, name));
         tf = any(strcmp(strsplit(path(), pathsep()), folder));
      end

      function tf = tbfixActive(~)
         % logical() because the CSV round trip types the column double.
         toolboxes = readtbdirectory(gettbdirectorypath());
         tf = logical(toolboxes.active(findtbentry(toolboxes, 'tbfix')));
      end
   end

   methods (Test)
      function testResolveActivatesDeclaredDeps(testCase)
         % Toolbox dep activated, project dep and its transitive dep on
         % path, all three recorded newest-first under the top project.
         resolveprojectdeps('alpha')
         testCase.verifyTrue(testCase.tbfixActive())
         testCase.verifyTrue(testCase.fixtureOnPath("beta"))
         testCase.verifyTrue(testCase.fixtureOnPath("gamma"))
         returned = depledger('list', 'alpha');
         expected = {'gamma'; 'beta'; 'tbfix'};
         testCase.verifyEqual({returned.name}', expected)
      end

      function testTeardownReversesResolution(testCase)
         resolveprojectdeps('alpha')
         teardownprojectdeps('alpha')
         testCase.verifyFalse(testCase.tbfixActive())
         testCase.verifyFalse(testCase.fixtureOnPath("beta"))
         testCase.verifyFalse(testCase.fixtureOnPath("gamma"))
         testCase.verifyEmpty(depledger('list', 'alpha'))
      end

      function testAlreadyActiveSkippedAndUntouched(testCase)
         % A manually activated toolbox is not recorded, so teardown
         % leaves it active.
         activate('tbfix', 'silent', true)
         resolveprojectdeps('alpha')
         returned = depledger('list', 'alpha');
         testCase.verifyFalse(any(strcmp({returned.name}, 'tbfix')))
         teardownprojectdeps('alpha')
         testCase.verifyTrue(testCase.tbfixActive())
      end

      function testCycleFailsFast(testCase)
         try
            resolveprojectdeps('cycA')
            testCase.verifyFail('expected a dependency-cycle error')
         catch returnedErr
            testCase.verifyEqual(returnedErr.identifier, ...
               'matfunclib:resolveprojectdeps:dependencyCycle')
            testCase.verifySubstring(returnedErr.message, ...
               'cycA -> cycB -> cycA')
         end
      end

      function testUnknownToolboxFailsFast(testCase)
         testCase.verifyError(@() resolveprojectdeps('ghosttb'), ...
            'matfunclib:resolveprojectdeps:unknownToolbox')
      end

      function testUnknownProjectFailsFast(testCase)
         testCase.verifyError(@() resolveprojectdeps('ghostprj'), ...
            'matfunclib:resolveprojectdeps:unknownProject')
      end

      function testNoManifestIsNoop(testCase)
         resolveprojectdeps('gamma')
         testCase.verifyEmpty(depledger('list', 'gamma'))
      end

      function testRequiretoolboxIdempotentAndUnknownErrors(testCase)
         requiretoolbox('tbfix')
         testCase.verifyTrue(testCase.tbfixActive())
         requiretoolbox('tbfix')   % second call is a no-op
         testCase.verifyTrue(testCase.tbfixActive())
         testCase.verifyError(@() requiretoolbox('nosuchtb'), ...
            'matfunclib:requiretoolbox:unknownToolbox')
      end

      function testCycleLeavesNoResidue(testCase)
         % A detected cycle must not strand partial activations: the
         % top-level rollback reverses everything recorded, and the
         % cycle-closing edge itself errors before its side effect.
         pathBefore = path();
         try
            resolveprojectdeps('cycA')
         catch
         end
         testCase.verifyEmpty(depledger('list', 'cycA'))
         testCase.verifyEqual(path(), pathBefore)
      end

      function testMidwayFailureRollsBack(testCase)
         % A manifest whose second entry is unknown must roll back the
         % first entry's activation on the way out.
         writelines([ ...
            "[dependencies]"; ...
            "toolboxes = [""tbfix"", ""nosuchtb""]"], ...
            fullfile(testCase.regDir, "gamma", "mproject.toml"))
         testCase.verifyError(@() resolveprojectdeps('gamma'), ...
            'matfunclib:resolveprojectdeps:unknownToolbox')
         testCase.verifyFalse(testCase.tbfixActive())
         testCase.verifyEmpty(depledger('list', 'gamma'))
      end

      function testProjectDepAlreadyOnPathSkipped(testCase)
         % A project dependency whose folder is already on the path is
         % not recorded, so teardown leaves it there; its own manifest
         % still resolves transitively.
         addpath(char(fullfile(testCase.regDir, "beta")))
         resolveprojectdeps('alpha')
         returned = depledger('list', 'alpha');
         testCase.verifyFalse(any(strcmp({returned.name}, 'beta')))
         testCase.verifyTrue(testCase.fixtureOnPath("gamma"))
         teardownprojectdeps('alpha')
         testCase.verifyTrue(testCase.fixtureOnPath("beta"))
      end

      function testLedgerRejectsBadInputs(testCase)
         testCase.verifyError(@() depledger('record', 'x', 'neither', 'y'), ...
            'matfunclib:depledger:badKind')
         testCase.verifyError(@() depledger('frobnicate', 'x'), ...
            'matfunclib:depledger:badOp')
      end

      function testTeardownWarnsAndContinuesOnFailure(testCase)
         % A ledger entry that cannot be reversed (a project absent from
         % the registry) warns, and the remaining entries still tear
         % down; the ledger ends empty either way.
         resolveprojectdeps('alpha')
         depledger('record', 'alpha', 'project', 'vanishedproject')
         testCase.verifyWarning(@() teardownprojectdeps('alpha'), ...
            'matfunclib:teardownprojectdeps:deactivateFailed')
         testCase.verifyFalse(testCase.tbfixActive())
         testCase.verifyEmpty(depledger('list', 'alpha'))
      end

      function testWorkonUnwindsOnResolutionFailure(testCase)
         % A cycle hit through the real workon entry point must not leave
         % the failed project marked active or on the path.
         testCase.verifyError( ...
            @() workon('cycA', 'updatefiles', false), ...
            'matfunclib:resolveprojectdeps:dependencyCycle')
         testCase.verifyFalse(strcmpi(getactiveproject('name'), 'cycA'))
         testCase.verifyFalse(testCase.fixtureOnPath("cycA"))
         testCase.verifyEmpty(depledger('list', 'cycA'))
      end

      function testMixedCaseOwnerTearsDown(testCase)
         % Registry lookups are case-insensitive, so resolution recorded
         % under 'ALPHA' must tear down under the canonical 'alpha'.
         resolveprojectdeps('ALPHA')
         teardownprojectdeps('alpha')
         testCase.verifyFalse(testCase.tbfixActive())
         testCase.verifyFalse(testCase.fixtureOnPath("beta"))
         testCase.verifyEmpty(depledger('list', 'ALPHA'))
      end

      function testStaleActiveFlagRepaired(testCase)
         % A persisted active flag with the toolbox absent from the path
         % (headless exit, crash) counts as inactive: requiretoolbox
         % activates and reports the transition, and the resolver records
         % it for teardown.
         toolboxes = readtbdirectory(gettbdirectorypath());
         toolboxes.active(findtbentry(toolboxes, 'tbfix')) = true;
         writetbdirectory(toolboxes)
         tbfixFolder = char(fullfile(testCase.regDir, "toolboxes", "tbfix"));
         testCase.verifyFalse( ...
            any(strcmp(strsplit(path(), pathsep()), tbfixFolder)))

         returned = requiretoolbox('tbfix');
         testCase.verifyTrue(returned)
         testCase.verifyTrue( ...
            any(strcmp(strsplit(path(), pathsep()), tbfixFolder)))

         % And through the resolver: reset to the stale state, resolve,
         % and confirm the repair is ledger-recorded.
         path(testCase.savedPath)
         toolboxes.active(findtbentry(toolboxes, 'tbfix')) = true;
         writetbdirectory(toolboxes)
         resolveprojectdeps('alpha')
         returned = depledger('list', 'alpha');
         testCase.verifyTrue(any(strcmp({returned.name}, 'tbfix')))
      end

      function testWorkonWorkoffIntegration(testCase)
         % Full lifecycle: workon resolves the manifest; workoff tears
         % down exactly what resolution activated. updatefiles=false keeps
         % the flow clear of editor state in headless runs.
         workon('alpha', 'updatefiles', false)
         testCase.verifyTrue(testCase.tbfixActive())
         testCase.verifyTrue(testCase.fixtureOnPath("beta"))
         testCase.verifyTrue(testCase.fixtureOnPath("gamma"))

         workoff('alpha', 'updatefiles', false)
         testCase.verifyFalse(testCase.tbfixActive())
         testCase.verifyFalse(testCase.fixtureOnPath("beta"))
         testCase.verifyFalse(testCase.fixtureOnPath("gamma"))
         testCase.verifyEmpty(depledger('list', 'alpha'))
      end
   end
end
