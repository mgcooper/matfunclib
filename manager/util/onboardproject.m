function projectFolder = onboardproject(projectName, opts)
   %ONBOARDPROJECT Onboard a registered project onto the Project workflow.
   %
   %    projectFolder = onboardproject(projectName)
   %    projectFolder = onboardproject(projectName, Name, Value)
   %
   % Description
   %
   %  Onboards one registered project. The call resolves PROJECTNAME to
   %  its folder through the project directory and writes a name-only
   %  mproject.toml stub when the folder has none. It generates the
   %  MATLAB Project with the standard import rule: top-level *.m files
   %  plus subfolders, no child files, membership follows git-tracked
   %  content. It appends the resources/project git policy to
   %  .gitignore when its patterns are missing. It closes the Project
   %  and restores the entry path.
   %
   %  A re-run converges: the generator adds nothing new, an existing
   %  manifest is never touched, and the policy block is appended only
   %  when its patterns are absent. Stale Project state must be cleaned
   %  first (fresh start: regenerate, do not migrate); the generator
   %  fails fast on an orphaned folder with the repair named.
   %
   % Inputs
   %
   %  PROJECTNAME - A name in the project directory (scalar text). The
   %  folder comes from the directory's activefolder column, the same
   %  resolution workon and addprojectrefs use.
   %
   % Name-value options
   %
   %  ignoredSubFolders - Folder names excluded from the import wherever
   %  they appear. Default ["sandbox", "testbed"], the sub-library import rule.
   %
   % Outputs
   %
   %  PROJECTFOLDER - The onboarded project root folder.
   %
   % See also: createMatlabProject, createhubproject, addprojectrefs

   arguments
      projectName (1,1) string
      opts.ignoredSubFolders (1,:) string = ["sandbox", "testbed"]
   end

   % Resolve through the project directory; an unregistered name fails
   % fast here instead of erroring inside the column indexing.
   projectlist = readprjdirectory();
   if ~any(getprjidx(char(projectName), projectlist))
      error("matfunclib:manager:onboardproject:unknownProject", ...
         "Project ""%s"" is not in the project directory. Register " + ...
         "it first, then onboard.", projectName)
   end
   projectFolder = string(getprojectfolder(char(projectName)));
   if ~isfolder(projectFolder)
      error("matfunclib:manager:onboardproject:folderNotFound", ...
         "Project ""%s"" resolves to ""%s"", which is not a folder.", ...
         projectName, projectFolder)
   end

   % Manifest: the stub declares the name only. Dependencies are added
   % by hand later; the manifest's presence is what opts the project
   % into reference reconciliation (see addprojectrefs).
   manifestFile = fullfile(projectFolder, "mproject.toml");
   if ~isfile(manifestFile)
      writelines([ ...
         "# mproject.toml - project dependency manifest, resolved by matfunclib"
         "# manager's workon via resolveprojectdeps. Entries are registry names."
         ""
         "[project]"
         "name = """ + projectName + """"], manifestFile);
   end

   % The folders holding this function and the generator, resolved while
   % they are on the path: closing an open Project below can take them
   % off it (the createhubproject pattern).
   generatorFolders = [ ...
      string(fileparts(mfilename("fullpath"))); ...
      string(fileparts(which("createMatlabProject")))];
   generatorFolders = unique(generatorFolders(isfolder(generatorFolders)));

   % MATLAB holds one root Project at a time, so close whatever is open
   % before generating, and put the generator folders back in case the
   % closed Project managed them.
   openroot = matlab.project.rootProject();
   if ~isempty(openroot)
      close(openroot)
      for k = 1:numel(generatorFolders)
         addpath(generatorFolders(k))
      end
   end

   % Capture the entry path after the close above, so the closed
   % Project contributes nothing. The onCleanup restore runs on success
   % and on error alike. A failed generation (for example a manifest
   % dependency that cannot open) must not leave a Project open or the
   % session path changed: a retry after the fix would then start from
   % a broken session.
   entryPath = path();
   restorer = onCleanup(@() restoreSession(entryPath));
   proj = createMatlabProject(projectFolder, ...
      addProjectFiles=true, ...
      addProjectFolders=true, ...
      addChildFiles=false, ...
      ignoredSubFolders=opts.ignoredSubFolders);
   close(proj)

   % Git policy: track resources/project, ignore the derived caches
   % MATLAB writes elsewhere under resources/. The stamp runs after
   % generation, so a .gitignore createProject wrote is appended to,
   % never replaced, and the members createProject recorded stay
   % verbatim.
   ensureGitPolicy(projectFolder)
end

%% local functions

function restoreSession(entryPath)
   %RESTORESESSION Close any open root Project and restore the path.
   %
   % Runs from onCleanup on success and on error. Closing an already
   % closed Project is a no-op here because rootProject is then empty.

   openroot = matlab.project.rootProject();
   if ~isempty(openroot)
      close(openroot)
   end
   path(entryPath);
end

function ensureGitPolicy(projectFolder)
   %ENSUREGITPOLICY Append the resources/project git policy when missing.
   %
   % The block matches matfunclib's .gitignore verbatim. Presence of
   % both patterns is the idempotence check, so a re-run appends
   % nothing.

   arguments
      projectFolder (1,1) string
   end

   policy = [ ...
      "# MATLAB Project state. Track resources/project, the project definition"
      "# openProject reads, so a fresh clone opens as a Project without running"
      "# the generator first. Ignore every other path under a resources/ folder:"
      "# MATLAB writes derived caches there, and a cached copy of another"
      "# project's state is machine-local, not source."
      "**/resources/*"
      "!**/resources/project/"];

   gitignoreFile = fullfile(projectFolder, ".gitignore");
   existing = strings(0, 1);
   if isfile(gitignoreFile)
      existing = readlines(gitignoreFile);
   end
   if any(existing == "**/resources/*") ...
         && any(existing == "!**/resources/project/")
      return
   end

   % Append with one separating blank line; writelines with append
   % keeps the existing content byte-for-byte.
   if isempty(existing)
      writelines(policy, gitignoreFile);
   else
      writelines([""; policy], gitignoreFile, WriteMode="append");
   end
end
