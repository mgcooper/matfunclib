function varargout = createMatlabProject(projectFolder, opts)
   %CREATEMATLABPROJECT Create or open a MATLAB Project and import its files.
   %
   %    proj = createMatlabProject()
   %    proj = createMatlabProject(projectFolder)
   %    proj = createMatlabProject(projectFolder, Name, Value)
   %
   % Description
   %
   %  Creates a MATLAB Project in PROJECTFOLDER, or opens the one already
   %  there, then imports the requested files and folders. Re-running the
   %  function on an existing Project converges: files already in the
   %  Project are never re-added, so a double run changes nothing. The
   %  Project is left open and returned; the caller closes it.
   %
   %  With "references" true (the default), Referenced Projects are
   %  generated from the project's mproject.toml through addprojectrefs.
   %  With "sync" true, missing required files are imported and the
   %  dependency cache refreshed through syncprojectfiles.
   %
   % Inputs
   %
   %  PROJECTFOLDER - The project root folder (scalar text). Either a full
   %  path or a bare name resolved against the MATLAB_PROJECT_PATH
   %  environment variable. The default is pwd().
   %
   % Name-value options
   %
   %  projectName - Scalar text for the Project name at creation time. An
   %  existing Project keeps its name. The default is the PROJECTFOLDER
   %  folder name. Note: matlab.project.createProject derives the .prj
   %  filename from the name with only the first letter capitalized, so
   %  pass CamelCase text for a CamelCase .prj filename.
   %
   %  addProjectFiles - Import the top-level *.m files. Default false.
   %
   %  addProjectFolders - Import the project subfolders (their trees when
   %  addChildFiles is true, the bare folder nodes otherwise). Default
   %  false.
   %
   %  addChildFiles - Import files inside the imported subfolders
   %  recursively. Default false.
   %
   %  projectSubfolders - Folder names restricting which subfolders are
   %  imported (for example "toolbox" to keep the Project scoped to a
   %  shipped folder). The filter refines an enabled import: passing it
   %  without addProjectFolders is an error, because there would be no
   %  import for it to restrict. Empty means every subfolder not
   %  ignored. Default empty.
   %
   %  ignoredSubFolders - Folder names excluded from the import wherever
   %  they appear, appended to the built-in ignore set [".git" ".svn"].
   %  The root resources/ folder (Project metadata) is always excluded
   %  by position; nested resources folders are ordinary content and
   %  import normally. Default empty.
   %
   %  references - Generate Referenced Projects from mproject.toml via
   %  addprojectrefs. Default true. A missing manifest declares nothing
   %  and is not an error.
   %
   %  sync - Import missing required files and refresh the dependency
   %  cache via syncprojectfiles. Default false because the dependency
   %  walk is slow on large projects.
   %
   % Outputs
   %
   %  PROJ - The open matlab.project.Project object.
   %
   % See also: addprojectrefs, syncprojectfiles, projectfile, mkproject

   arguments
      projectFolder (1,1) string = pwd()
      opts.projectName (1,1) string = string(NaN)
      opts.addProjectFiles (1,1) logical = false
      opts.addProjectFolders (1,1) logical = false
      opts.addChildFiles (1,1) logical = false
      opts.projectSubfolders (:,1) string = string.empty()
      opts.ignoredSubFolders (1,:) string = string.empty()
      opts.references (1,1) logical = true
      opts.sync (1,1) logical = false
   end

   % The subfolder filter refines the folder import; without an import
   % it would select nothing without a message, so make that misuse an
   % error instead.
   if ~isempty(opts.projectSubfolders) && ~opts.addProjectFolders
      error("matfunclib:createMatlabProject:filterWithoutImport", ...
         "projectSubfolders was passed but addProjectFolders is " + ...
         "false, so there is no folder import for it to restrict.")
   end

   % Resolve a bare project name against MATLAB_PROJECT_PATH, so
   % callers can name projects the way the project directory does,
   % without building paths.
   projectFolder = resolveProjectFolder(projectFolder);

   % An existing Project keeps its name; missing means "use the folder
   % name" at creation time. fileparts treats a dot in a folder name as
   % an extension separator, so rejoin the parts to keep dotted folder
   % names whole.
   if ismissing(opts.projectName)
      [~, folderBase, folderExt] = fileparts(projectFolder);
      projectName = string(folderBase) + string(folderExt);
   else
      projectName = opts.projectName;
   end

   % .git and .svn are version-control state, excluded wherever they
   % appear. The ROOT resources/ folder holds Project metadata and is
   % excluded inside collectImports by position, not by name, so nested
   % resource folders shipping product assets stay importable.
   ignoredSubFolders = [opts.ignoredSubFolders, ".git", ".svn"];

   % Create-or-open, classified by projectstate (the check
   % addprojectrefs also applies to reference targets): a folder with
   % both markers opens, a folder with neither is created, and a folder
   % with one marker but not the other (for example an orphaned
   % resources/project tree with no .prj) fails fast with the repair
   % named, because openProject cannot open it and creating over it
   % would mix stale state into the new Project.
   switch projectstate(projectFolder)
      case "project"
         proj = openProject(projectFolder);
      case "none"
         proj = matlab.project.createProject( ...
            "Name", projectName, "Folder", projectFolder);
      otherwise
         % resolveProjectFolder already rejected missing folders, so
         % this branch reports orphaned (partial) Project state.
         error("matfunclib:createMatlabProject:orphanedProjectState", ...
            "Folder ""%s"" has Project state ""%s"" (a root .prj or " + ...
            "a resources/project tree, but not both). Delete the " + ...
            "stale remnant, then re-run to generate a fresh Project.", ...
            projectFolder, projectstate(projectFolder))
   end

   % The root path the Project reports, used for all containment checks
   % so macOS /var vs /private/var aliases cannot break them.
   projectRoot = string(proj.RootFolder);

   % Everything the options select, as one deterministic list of folders
   % and files. Filtering against the Project's current file set is what
   % makes a re-run a no-op.
   toImport = collectImports(projectRoot, opts.addProjectFiles, ...
      opts.addProjectFolders, opts.addChildFiles, ...
      opts.projectSubfolders, ignoredSubFolders);

   existing = listprojectfiles(proj);
   for entry = toImport(~ismember(toImport, existing)).'
      proj.addFile(entry);
   end

   % addFile tracks membership only; folders reach the MATLAB path in a
   % clean session only through the Project path, and the path is not
   % recursive. Register every imported folder's path root (pathrootof
   % strips +package/@class/private segments, so a special folder
   % contributes its ordinary ancestor), plus the project root itself
   % when its top-level files were imported, idempotently, so
   % openProject exposes all the code and Referenced Projects
   % contribute their folders.
   importedFolders = toImport(isfolder(toImport));
   pathRoots = strings(numel(importedFolders), 1);
   for k = 1:numel(importedFolders)
      pathRoots(k) = pathrootof(importedFolders(k));
   end
   if opts.addProjectFiles
      pathRoots = [projectRoot; pathRoots];
   end
   pathRoots = unique(pathRoots, "stable");
   heldPath = listprojectpath(proj);
   for entry = pathRoots(~ismember(pathRoots, heldPath)).'
      proj.addPath(entry);
   end

   % Referenced Projects come from mproject.toml, the one place project
   % dependencies are declared; the .prj reference set is derived from
   % it, never hand-maintained.
   if opts.references
      addprojectrefs(projectRoot);
   end

   % The sync pass imports missing required files and refreshes the
   % dependency cache; it is opt-in because the walk is slow.
   if opts.sync
      syncprojectfiles(projectRoot);
   end

   % Return the open Project only when asked, so scripted calls do not
   % echo the object.
   if nargout
      varargout{1} = proj;
   end
end

%% local functions

function projectFolder = resolveProjectFolder(projectFolder)
   %RESOLVEPROJECTFOLDER Resolve a path or bare name to an existing folder.

   arguments
      projectFolder (1,1) string
   end

   if isfolder(projectFolder)
      return
   end

   % A bare name resolves under MATLAB_PROJECT_PATH, matching how the
   % project directory (readprjdirectory) addresses projects.
   candidate = fullfile(getenv("MATLAB_PROJECT_PATH"), projectFolder);
   if isfolder(candidate)
      projectFolder = string(candidate);
      return
   end

   error("matfunclib:createMatlabProject:folderNotFound", ...
      "Project folder ""%s"" is not a folder and does not resolve " + ...
      "under MATLAB_PROJECT_PATH.", projectFolder)
end

function toImport = collectImports(projectRoot, addProjectFiles, ...
      addProjectFolders, addChildFiles, projectSubfolders, ignoredSubFolders)
   %COLLECTIMPORTS List the folders and files the options select.
   %
   % Returns a string column of full paths: top-level *.m files when
   % addProjectFiles is set, then each selected subfolder and (with
   % addChildFiles) every file under it. Explicit enumeration with one
   % addFile call per entry is what makes the import idempotent, because
   % the caller can filter this list against the Project's file set.

   arguments
      projectRoot (1,1) string
      addProjectFiles (1,1) logical
      addProjectFolders (1,1) logical
      addChildFiles (1,1) logical
      projectSubfolders (:,1) string
      ignoredSubFolders (1,:) string
   end

   parts = {};

   % Top-level *.m files.
   if addProjectFiles
      found = dir(fullfile(projectRoot, "*.m"));
      parts{end + 1} = compose(found);
   end

   if addProjectFolders
      % Every directory under the root, minus dotfolders and the ignore
      % set. Matching prunes by path segment so an ignored name excludes
      % its whole subtree.
      found = dir(fullfile(projectRoot, "**", "*"));
      found = found([found.isdir]);
      found = found(~startsWith({found.name}, "."));
      folders = compose(found);
      folders = folders(~ignoredPath(folders, projectRoot, ignoredSubFolders));

      % A dot-prefixed segment anywhere in the relative path excludes
      % the whole subtree, so .github/workflows goes with .github
      % rather than surviving the basename filter above.
      dotted = false(numel(folders), 1);
      for k = 1:numel(folders)
         segments = split(erase(folders(k), projectRoot + filesep), ...
            filesep);
         dotted(k) = any(startsWith(segments, "."));
      end
      folders = folders(~dotted);

      % Only the ROOT resources/ folder is Project metadata; a nested
      % resources folder is ordinary product content and stays.
      rootResources = fullfile(projectRoot, "resources");
      folders = folders(folders ~= rootResources ...
         & ~startsWith(folders, rootResources + filesep));

      % An explicit projectSubfolders list keeps only trees rooted at a
      % matching folder name, so "toolbox" selects toolbox/ and its
      % descendants.
      if ~isempty(projectSubfolders)
         keep = false(size(folders));
         for name = projectSubfolders.'
            base = fullfile(projectRoot, name);
            keep = keep | folders == base ...
               | startsWith(folders, base + filesep);
         end
         folders = folders(keep);
         if isempty(folders)
            error("matfunclib:createMatlabProject:subfolderNotFound", ...
               "No subfolder of ""%s"" matches projectSubfolders [%s].", ...
               projectRoot, strjoin(projectSubfolders, ", "))
         end
      end
      parts{end + 1} = folders;

      % Files inside the selected folders, when requested. Dotfiles stay
      % out so .DS_Store and friends never enter the Project.
      if addChildFiles
         perFolder = cell(numel(folders), 1);
         for k = 1:numel(folders)
            found = dir(fullfile(folders(k), "*"));
            found = found(~[found.isdir]);
            found = found(~startsWith({found.name}, "."));
            perFolder{k} = compose(found);
         end
         parts{end + 1} = vertcat(strings(0, 1), perFolder{:});
      end
   end

   toImport = unique(vertcat(strings(0, 1), parts{:}), "stable");
end

function ignored = ignoredPath(paths, projectRoot, ignoredSubFolders)
   %IGNOREDPATH True where a path contains an ignored folder name segment.

   % Compare per-path segments so an ignored name anywhere in the path
   % excludes the whole subtree beneath it.

   arguments
      paths (:,1) string
      projectRoot (1,1) string
      ignoredSubFolders (1,:) string
   end
   relative = erase(paths, projectRoot + filesep);
   ignored = false(numel(paths), 1);
   for k = 1:numel(paths)
      ignored(k) = any(ismember(split(relative(k), filesep), ...
         ignoredSubFolders));
   end
end

function paths = compose(found)
   %COMPOSE Convert a dir() struct to a string column of full paths.

   arguments
      found struct
   end

   if isempty(found)
      paths = strings(0, 1);
   else
      paths = string(fullfile({found.folder}, {found.name})).';
   end
end
