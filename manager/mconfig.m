function cfg = mconfig()
   %MCONFIG Configure MATLAB path environment variables.
   %
   %  CFG = MCONFIG() sets the family of path environment variables relative to
   %  the $HOME/MATLAB root and returns them in struct CFG.
   %
   % Description
   %
   %  mconfig sets the path family variables used by manager and matfunclib.
   %  It's called by startup.m so the variables are set at boot. Functions read
   %  the variables with mgetenv, which falls back to this function when a
   %  variable is unset.
   %
   %  Do not setenv these names elsewhere. Test fixtures are the exception: they
   %  save the caller's values, redefine paths to temp folders as needed (e.g.,
   %  MATLAB_DIRECTORY_PATH, MATLAB_PROJECT_PATH, MATLAB_TOOLBOX_PATH), and then
   %  restore the original ones as a teardown step.
   %
   %  Variables set, one per CFG field:
   %
   %     - MATLAB_HOME_PATH $HOME/MATLAB
   %     - MATLAB_PROJECT_PATH $HOME/MATLAB/projects
   %     - MATLAB_TOOLBOX_PATH $HOME/MATLAB/toolboxes
   %     - MATLAB_DIRECTORY_PATH $HOME/MATLAB/directory
   %     - MATLAB_FUNCTION_PATH $HOME/MATLAB/projects/matfunclib
   %     - MATLAB_TEMPLATE_PATH $HOME/MATLAB/projects/matfunclib/templates
   %     - MATLAB_TOOLBOX_TEMPLATE_PATH $HOME/MATLAB/projects/matfunclib/toolbox
   %     - MATLAB_FEX_PATH $HOME/MATLAB/projects/fexlib
   %
   %  MATLAB_DIRECTORY_PATH holds both manager registries: the toolbox registry
   %  (toolboxdirectory.csv) and the project registry (projectdirectory.mat).
   %  MATLAB_FEX_PATH holds the file-exchange function library (fexlib).
   %
   %  Note: no arguments block and no string types. Octave runs startup.m and
   %  cannot parse arguments blocks, and startup.m calls this before the rest of
   %  matfunclib is on the path, so it must run without matfunclib on path.
   %
   % Outputs
   %
   %  CFG - A struct with one field per variable above, holding the value set.
   %
   % See also: startup getenvall

   % Derive paths from the configured $HOME/MATLAB root. Error on empty $HOME
   % variable, otherwise every derived path would be relative to 'MATLAB/...'.
   if isempty(getenv('HOME'))
      error('matfunclib:manager:mconfig:emptyHome', ...
         'HOME is unset or empty; the path family cannot be derived.')
   end
   homepath = fullfile(getenv('HOME'), 'MATLAB');

   cfg.MATLAB_HOME_PATH = homepath;
   cfg.MATLAB_PROJECT_PATH = fullfile(homepath, 'projects');
   cfg.MATLAB_TOOLBOX_PATH = fullfile(homepath, 'toolboxes');
   cfg.MATLAB_DIRECTORY_PATH = fullfile(homepath, 'directory');
   cfg.MATLAB_FUNCTION_PATH = fullfile(homepath, 'projects', 'matfunclib');
   cfg.MATLAB_TEMPLATE_PATH = fullfile( ...
      cfg.MATLAB_FUNCTION_PATH, 'templates');
   cfg.MATLAB_TOOLBOX_TEMPLATE_PATH = fullfile( ...
      cfg.MATLAB_FUNCTION_PATH, 'toolbox');
   cfg.MATLAB_FEX_PATH = fullfile(homepath, 'projects', 'fexlib');

   % Export every variable. Do it before bootstrapfunctionpath, because
   % octaveignorepaths reads MATLAB_FUNCTION_PATH and MATLAB_FEX_PATH.
   names = fieldnames(cfg);
   for n = 1:numel(names)
      setenv(names{n}, cfg.(names{n}));
   end

   bootstrapfunctionpath(cfg.MATLAB_FUNCTION_PATH);
end

function bootstrapfunctionpath(functionpath)
   %BOOTSTRAPFUNCTIONPATH Put matfunclib on the path before manager needs it.
   %
   % manager depends on matfunclib and bootstraps the path on startup, so it
   % needs matfunclib on path. manager declares matfunclib as a dependency,
   % matfunclib does not depend on manager.
   %
   % No arguments block and no string types, because mconfig must run under
   % Octave and without depending on matfunclib before it's on the path. Every
   % function called here is a MATLAB built-in or a manager function.

   % Error if matfunclib is missing.
   if ~isfolder(functionpath)
      error('matfunclib:manager:mconfig:missingFunctionPath', ...
         ['matfunclib is not at %s. manager needs it on the path at ' ...
         'boot. Put matfunclib there, or point HOME at the tree that ' ...
         'holds it.'], functionpath);
   end

   subpaths = strsplit(genpath(functionpath), pathsep);
   subpaths = subpaths(~cellfun('isempty', subpaths));

   % Remove hidden folders added by genpath (.git etc.) The check only covers
   % subfolders of functionpath, because the checkout itself can sit under a dot
   % folder such as /Users/x/.local/share/matfunclib. Testing the entire
   % absolute path would reject every entry.
   hidden = cellfun(@(f) ishiddenpath(f, functionpath), subpaths);
   subpaths = subpaths(~hidden);

   % Ignore paths Octave cannot load (some matfunclib functions shadow Octave
   % built-ins and some fail to parse). octaveignorepaths lists all known cases
   % and is shared with startup.m and funclibpath.
   if exist('OCTAVE_VERSION', 'builtin') > 0
      ignorepaths = octaveignorepaths();

      for n = 1:numel(ignorepaths)

         % Ignore the folder itself and everything under it. The second check
         % ensures that a path whose name starts with the ignored one (e.g.
         % liblogic/ifelseHelpers for ifelse) is not dropped, which a plain
         % strncmp would drop.
         ignored = strcmp(subpaths, ignorepaths{n}) | ...
            strncmp(subpaths, [ignorepaths{n} filesep], ...
            numel(ignorepaths{n}) + 1);
         subpaths = subpaths(~ignored);
      end

      % Use the resolved name of a symlinked checkout. Octave's path stores
      % that name and moves a folder re-added through the link to the end,
      % so the path test below needs it. octaveignorepaths uses the
      % unresolved name, so this step comes after the filter. MATLAB leaves a
      % folder re-added through a link in place, so it needs no step.
      resolved = canonicalize_file_name(functionpath);
      subpaths = cellfun(@(f) [resolved f(numel(functionpath) + 1:end)], ...
         subpaths, 'UniformOutput', false);
   end

   % Add only the folders not already on the path. addpath moves a folder that
   % is already on the path to the end, and mgetenv calls mconfig whenever a
   % variable is unset, so adding every folder would reorder the path each time.
   subpaths = subpaths(~ismember(subpaths, strsplit(path(), pathsep)));
   if isempty(subpaths)
      return
   end

   % Use '-end' so matfunclib never shadows a MATLAB built-in.
   addpath(strjoin(subpaths, pathsep), '-end');
end

function tf = ishiddenpath(folder, root)
   %ISHIDDENPATH True when FOLDER lies under a dot folder below ROOT.
   %
   % Only the part below ROOT is checked, so a checkout under a dot folder under
   % ROOT is not removed (e.g. /Users/x/.local/share/matfunclib). Check path
   % components rather than each substring so a folder like "v1.2" is not
   % dropped but an actual dotfolder like ".git" is dropped.
   relative = folder;
   if strncmp(folder, root, numel(root))
      relative = folder(numel(root) + 1:end);
   end
   parts = strsplit(relative, filesep);
   tf = any(~cellfun('isempty', parts) & strncmp(parts, '.', 1));
end
