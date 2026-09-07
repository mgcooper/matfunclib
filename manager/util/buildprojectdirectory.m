function varargout = buildprojectdirectory(varargin)
   %BUILDPROJECTDIRECTORY Build or rebuild the project directory file.
   %
   %  projectlist = buildprojectdirectory()
   %  projectlist = buildprojectdirectory('rebuild')
   %  projectlist = buildprojectdirectory('fresh')
   %  projectlist = buildprojectdirectory(..., 'dryrun')
   %
   % Description
   %
   %  The project directory is the registry (projectdirectory.mat in
   %  MATLAB_DIRECTORY_PATH) of projects manager tracks. Each row is one
   %  project. The filesystem scan of MATLAB_PROJECT_PATH sets the name, folder,
   %  and dir() attributes. Four columns hold custom attributes: activefiles
   %  (files open when the project was last active), activeproject (which
   %  project is active), activefolder (the project root, normally folder/name),
   %  and linkedproject.
   %
   %  Two modes:
   %
   %  REBUILD (the default) scans the project path for current names and
   %  folders, then carries each project's saved attributes forward by name from
   %  the current registry. Use it after a project moves or after
   %  MATLAB_PROJECT_PATH changes: the folders update while activefiles and
   %  the active project are kept. addproject calls this, so every new
   %  project rebuilds the directory.
   %
   %  FRESH rebuilds from the filesystem alone and discards all saved attributes
   %  (every project starts with empty activefiles and inactive). It is the
   %  explicit, destructive build; ask for it by name.
   %
   %  DRYRUN returns the list that would be saved without writing it. It
   %  combines with either mode.
   %
   %  One project is one name. Every project lives under MATLAB_PROJECT_PATH,
   %  so folder names are unique and a duplicate name is a defect, not a
   %  layout: both modes fail loud on one (the check runs on the scanned
   %  list before the mode branch). activefolder normally tracks
   %  folder/name (the single location the environment variable defines). A
   %  project whose saved activefolder extends past folder/name (a custom
   %  sub-root) keeps that trailing offset under the new parent, so a custom
   %  root survives a path change until the project moves to a normal layout.
   %
   %  A saved project missing from the scan is kept only when it still holds
   %  activefiles or a linked project. A missing project marked active does
   %  not block the rebuild: rebuild warns and clears its active flag.
   %
   % Updates
   % 06 Sep 2026 - remove custom logic for cross-machine rebuilds
   % 19 Jan 2023 - appended projname to projectlist.activefolder and renamed
   % projectlist.folder to projectlist.parentfolder
   % 19 Jan 2023 - added 'activefolder' attribute to allow projects associated
   % with folders other than their namesake
   % 23 Nov 2022 - add projects in USER_PROJECT_PATH using appendprojects
   % 23 Nov 2022 - remove entries that are not directories
   %
   % See also: readprjdirectory, writeprjdirectory, workon, addproject

   % Parse the flags and pick the mode. rebuild is the default; fresh is the
   % explicit destructive build; dryrun suppresses the write.
   opts = parseflags(varargin);

   % Build a fresh project list by scanning MATLAB_PROJECT_PATH: current names,
   % folders, and dir() attributes, with custom attribute columns empty.
   projectlist = initializeProjectList();

   % Require unique project names (project names are subfolders under
   % MATLAB_PROJECT_PATH). If a folder named 'default' exists, it will collide
   % with the synthetic 'default' project name which makes later name matches
   % ambiguous, so reject it here, before the fresh/rebuild branch.
   assertuniquenames(projectlist, 'scanned')

   % Rebuild retains saved attributes, fresh keeps the empty ones.
   if not(opts.fresh)
      projectlist = rebuildProjectList(projectlist);
   end

   % Save the project directory. writeprjdirectory applies the
   % backup-before-write, empty-write refusal, and required-field checks.
   if not(opts.dryrun)
      writeprjdirectory(projectlist);
   end

   % Return the list if requested.
   if nargout == 1
      varargout{1} = projectlist;
   end
end

%% local functions

function opts = parseflags(args)
   %PARSEFLAGS Resolve the option flags to a mode and a dryrun choice.

   arguments
      args (1,:) cell
   end

   % Reject any token that doesn't match a known flag, and keep validatestring's
   % return value: it accepts an unambiguous prefix, so 'dry' must
   % resolve to 'dryrun' here rather than pass validation and then be
   % silently ignored by the presence checks below (which would turn a
   % requested dry run into a real write).
   valid = {'rebuild', 'fresh', 'dryrun'};
   for k = 1:numel(args)
      args{k} = validatestring(args{k}, valid, mfilename, 'option', k);
   end

   % Flags are order-independent presence checks over the valid names.
   args = string(args);
   opts.fresh = ismember("fresh", args);
   opts.dryrun = ismember("dryrun", args);

   % rebuild is the default and needs no flag. Passing both fresh and
   % rebuild asks for opposite modes at once, so reject it.
   if opts.fresh && ismember("rebuild", args)
      error('matfunclib:buildprojectdirectory:conflictingOptions', ...
         '''fresh'' and ''rebuild'' are opposite modes; pass at most one.')
   end
end

function projectlist = initializeProjectList()
   %initializeProjectList List the project folders under MATLAB_PROJECT_PATH.
   %
   % Returns one row per subfolder with the dir() attributes and empty
   % attributes columns. activefolder defaults to folder/name, the single
   % project folder location defined by MATLAB_PROJECT_PATH.

   % Get the project parent folder and list all project subfolders.
   projectpath = mgetenv('MATLAB_PROJECT_PATH');
   projectlist = struct2table(getlist(projectpath, '*'));
   projectlist = projectlist(logical(projectlist.isdir), :);

   % The 'default' project folder is MATLAB_HOME_PATH (not matfunclib), so
   % a usable list exists even with an empty project path. Copy a scanned
   % row for its schema, then override name and folder.
   defaultproj = projectlist(end, :);
   defaultproj.name = {'default'};
   defaultproj.folder = mgetenv('MATLAB_HOME_PATH');
   projectlist = [projectlist; defaultproj];

   % Add empty custom attributes: 'activefiles', 'activeproject',
   % 'activefolder', and 'linkedproject'. The others are created by dir()
   n = height(projectlist);
   projectlist.activefiles(1:n) = {''};
   projectlist.activeproject(1:n) = false;
   projectlist.activefolder = fullfile(projectlist.folder, projectlist.name);
   projectlist.linkedproject(1:n) = {''};
end

function newlist = rebuildProjectList(newlist)
   %rebuildProjectList Rebuild the list carrying saved attributes forward.

   arguments
      newlist table
   end

   % Read the current project directory.
   oldlist = readprjdirectory();

   % Require the saved list to have unique project names, otherwise the name
   % match below will be ambiguous. The scanned list was checked in main.
   assertuniquenames(oldlist, 'saved')

   % Define the custom attributes which are transferred from oldlist to newlist.
   % activefolder is handled separately so it's updated when a path changes.
   keepattrs = {'activefiles', 'activeproject', 'linkedproject'};

   % Find projects in both the old and new directories and merge the attributes.
   for m = 1:height(newlist)

      % Check if this project name exists in the old list.
      n = find(strcmp(oldlist.name, newlist.name{m}), 1);
      if isempty(n)
         continue
      end

      % Assign the attributes.
      for c = 1:numel(keepattrs)
         newlist.(keepattrs{c})(m) = oldlist.(keepattrs{c})(n);
      end

      % newlist.activefolder is MATLAB_PROJECT_PATH/<project-name> by default.
      % This function repairs a saved sub-folder for projects with custom
      % sub-folder roots such as icom-msd/project.
      newlist.activefolder{m} = repairProjectSubfolder( ...
         oldlist.activefolder{n}, oldlist.folder{n}, oldlist.name{n}, ...
         newlist.activefolder{m});
   end

   % Don't let a saved project that wasn't found in the fresh directory scan
   % block the rebuild. If a missing project is active, warn and deactivate it
   % so a machine that lacks the folder still rebuilds the directory.
   missing = ~ismember(oldlist.name, newlist.name);
   for m = reshape(find(missing), 1, [])
      if oldlist.activeproject(m)
         warning('matfunclib:buildprojectdirectory:activeProjectMissing', ...
            ['Active project "%s" is not under the project path; ' ...
            'clearing its active flag.'], oldlist.name{m})
         oldlist.activeproject(m) = false;
      end
   end

   % Keep a missing project only when it still holds attributes worth saving,
   % so its activefiles survive until its folder reappears.
   carry = missing ...
      & ( ~cellfun(@isempty, oldlist.activefiles) ...
      | ~cellfun(@isempty, oldlist.linkedproject) );
   newlist = [newlist; oldlist(carry, :)];
end

function assertuniquenames(list, which)
   %ASSERTUNIQUENAMES Error when a name repeats in the project list.

   arguments
      list table
      which (1,:) char
   end

   names = list.name;
   [uniquenames, ~, ic] = unique(names);
   if numel(uniquenames) < numel(names)
      duplicated = uniquenames(accumarray(ic, 1) > 1);
      error('matfunclib:buildprojectdirectory:duplicateName', ...
         ['Duplicate project name(s) in the %s list: %s. ' ...
         'One project is one name under MATLAB_PROJECT_PATH.'], ...
         which, strjoin(string(duplicated), ', '))
   end
end

function newfolder = repairProjectSubfolder(oldactivefolder, oldfolder, oldname, ...
      defaultfolder)
   %repairProjectSubfolder Re-apply a saved activefolder sub-root under the new parent.
   %
   % defaultfolder is the scanned folder/name (the enforced location). When
   % the saved activefolder extended past the old folder/name by a trailing
   % offset (a custom sub-root), re-apply that offset under defaultfolder.
   % Otherwise use defaultfolder.

   arguments
      oldactivefolder (1,:) char
      oldfolder (1,:) char
      oldname (1,:) char
      defaultfolder (1,:) char
   end

   % Normalize a trailing separator so the offset, and the rebuilt path,
   % match fullfile output (which never ends in a separator).
   if ~isempty(oldactivefolder) && oldactivefolder(end) == filesep
      oldactivefolder(end) = [];
   end

   oldbase = fullfile(oldfolder, oldname);
   if startsWith(oldactivefolder, [oldbase filesep])
      offset = oldactivefolder(numel(oldbase) + 2:end);
      newfolder = fullfile(defaultfolder, offset);
   else
      newfolder = defaultfolder;
   end
end
