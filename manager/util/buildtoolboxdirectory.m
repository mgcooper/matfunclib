function varargout = buildtoolboxdirectory(varargin)
   %BUILDTOOLBOXDIRECTORY Rebuild toolbox directory from filesystem.
   %
   % buildtoolboxdirectory()
   % buildtoolboxdirectory('dryrun')
   % buildtoolboxdirectory('rebuild')
   % buildtoolboxdirectory('rebuild', 'dryrun')
   % toolboxes = buildtoolboxdirectory(...)
   %
   % Description
   %
   %  Scans MATLAB_TOOLBOX_PATH to reconstruct the canonical toolbox
   %  directory (toolboxdirectory.csv) from the actual filesystem. Use this
   %  when toolboxdirectory.csv is missing, empty, or corrupted.
   %
   %  The scan uses a two-level walk:
   %    Level 1 — each direct child of MATLAB_TOOLBOX_PATH is added as a
   %              top-level entry with library = its own name. This covers
   %              both stand-alone toolboxes (e.g. CDT/) and library folders
   %              (e.g. plotting/) that contain sub-toolboxes.
   %    Level 2 — subdirectories within each level-1 folder are added with
   %              library = the parent folder name (e.g. BrewerMap inside
   %              plotting/ → library = 'plotting').
   %
   %  This matches the structure in toolboxdirectory_old.csv and the path
   %  detection logic in updatetbdirectory.
   %
   %  All entries are initialized with active = false. Use 'rebuild' to
   %  preserve the active state of toolboxes that exist in the current
   %  (possibly backup) directory before saving.
   %
   % Options
   %
   %  'dryrun'  — Return the rebuilt table without writing to disk.
   %  'rebuild' — Before finalizing, read the current toolbox directory (via
   %              readtbdirectory, which falls back to MAT backups if the CSV
   %              is corrupted) and copy the active state for matching names.
   %
   % CANONICAL SOURCE: $TBDIRECTORYPATH/toolboxdirectory.csv
   % REBUILD SOURCE:   $MATLAB_TOOLBOX_PATH filesystem scan
   % BACKUP FORMAT:    $TBDIRECTORYPATH/tbd_*.mat (written by writetbdirectory)
   %
   % See also: readtbdirectory, writetbdirectory, updatetbdirectory, buildprojectdirectory

   % Parse and validate options.
   switch nargin
      case 0
         % interactive mode — no validation needed
      case 1
         validatestring(varargin{1}, {'rebuild', 'dryrun'}, mfilename, 'option', 1);
      case 2
         validatestring(varargin{1}, {'rebuild'}, mfilename, 'option', 1);
         validatestring(varargin{2}, {'dryrun'}, mfilename, 'option', 2);
      otherwise
         error('matfunclib:buildtoolboxdirectory:tooManyInputs', ...
            'Too many input arguments.');
   end

   opts = optionParser({'rebuild', 'dryrun'}, varargin(:));

   % Warn and prompt in interactive (no-argument) mode.
   if nargin == 0
      opts = buildwarning(opts);
   end

   % Build the toolbox list from the filesystem.
   toolboxes = buildtoolboxlist(opts);

   % Save unless dry run.
   tbDirectoryPath = gettbdirectorypath();
   if ~opts.dryrun
      writetbdirectory(toolboxes, tbDirectoryPath);
   end

   if nargout > 0
      varargout{1} = toolboxes;
   end
end

% -------------------------------------------------------------------------
function opts = buildwarning(opts)
   msg = [ ...
      newline 'Building toolbox directory from filesystem.' ...
      newline 'Warning: this will overwrite the existing toolboxdirectory.csv if it exists.' ...
      newline 'Use option ''rebuild'' to preserve the active state of existing toolboxes.' ...
      newline 'Press ''y'' to save, or any other key to return without saving.' newline];
   commandwindow;
   str = input(msg, 's');
   if string(str) ~= "y"
      opts.dryrun = true;
   end
end

% -------------------------------------------------------------------------
function toolboxes = buildtoolboxlist(opts)
   %BUILDTOOLBOXLIST Scan MATLAB_TOOLBOX_PATH and build the toolbox table.
   %
   % Filesystem layout:
   %   MATLAB_TOOLBOX_PATH/
   %     <name>/            <- Zone 1: stand-alone toolbox
   %     libraries/
   %       <libname>/       <- Zone 2a: library folder (also a toolbox entry)
   %         <name>/        <- Zone 2b: toolbox within library
   %
   % The 'libraries' folder itself is not added as a toolbox entry.
   % No subdirectory descent is performed within Zone 1 or Zone 2b — only
   % the named directory is registered, not its internal layout.

   tbroot = getenv('MATLAB_TOOLBOX_PATH');
   if isempty(tbroot)
      error('matfunclib:buildtoolboxdirectory:noTbPath', ...
         'MATLAB_TOOLBOX_PATH environment variable is not set.');
   end
   if ~isfolder(tbroot)
      error('matfunclib:buildtoolboxdirectory:badTbPath', ...
         'MATLAB_TOOLBOX_PATH does not exist: %s', tbroot);
   end

   names     = {};
   sources   = {};
   actives   = logical([]);
   libraries = {};

   % --- Zone 1: stand-alone toolboxes directly under MATLAB_TOOLBOX_PATH ---
   % Each immediate child directory (except 'libraries') is one toolbox.
   % Do NOT descend into its subfolders.
   zone1 = rmdotfolders(dir(tbroot));
   zone1 = zone1([zone1.isdir]);
   for k = 1:numel(zone1)
      if strcmp(zone1(k).name, 'libraries')
         continue   % handled in Zone 2
      end
      tbName = zone1(k).name;
      names{end+1}     = tbName;                   %#ok<AGROW>
      sources{end+1}   = fullfile(tbroot, tbName); %#ok<AGROW>
      actives(end+1)   = false;                    %#ok<AGROW>
      libraries{end+1} = tbName;                   %#ok<AGROW>
   end

   % --- Zone 2: library toolboxes under MATLAB_TOOLBOX_PATH/libraries/ ---
   librariesDir = fullfile(tbroot, 'libraries');
   if isfolder(librariesDir)
      libFolders = rmdotfolders(dir(librariesDir));
      libFolders = libFolders([libFolders.isdir]);
      for k = 1:numel(libFolders)
         libName = libFolders(k).name;
         libPath = fullfile(librariesDir, libName);

         % Zone 2a: the library folder itself as a meta-toolbox entry.
         % Activating it activates the library root on the path.
         names{end+1}     = libName;    %#ok<AGROW>
         sources{end+1}   = libPath;    %#ok<AGROW>
         actives(end+1)   = false;      %#ok<AGROW>
         libraries{end+1} = libName;    %#ok<AGROW>

         % Zone 2b: individual toolboxes inside the library folder.
         % Add each immediate subdirectory only — no deeper descent.
         tbFolders = rmdotfolders(dir(libPath));
         tbFolders = tbFolders([tbFolders.isdir]);
         for j = 1:numel(tbFolders)
            tbName = tbFolders(j).name;
            names{end+1}     = tbName;                      %#ok<AGROW>
            sources{end+1}   = fullfile(libPath, tbName);   %#ok<AGROW>
            actives(end+1)   = false;                       %#ok<AGROW>
            libraries{end+1} = libName;                     %#ok<AGROW>
         end
      end
   end

   toolboxes = table(names(:), sources(:), actives(:), libraries(:), ...
      'VariableNames', {'name', 'source', 'active', 'library'});
   toolboxes.library = string(toolboxes.library);

   % 'rebuild' mode: preserve active state from the existing directory.
   if opts.rebuild
      toolboxes = preserveActiveState(toolboxes);
   end
end

% -------------------------------------------------------------------------
function newlist = preserveActiveState(newlist)
   %PRESERVEACTIVESTATE Copy active=true entries from the current directory.
   %
   % Uses readtbdirectory which falls back to MAT backups if the CSV is
   % corrupted. Only the active column is transferred; source paths are
   % taken from the fresh filesystem scan.

   try
      [oldlist, oldsource] = readtbdirectory();
   catch
      warning(['matfunclib:buildtoolboxdirectory:rebuildReadFailed', ...
         'Could not read existing toolbox directory to preserve active state. ' ...
         'All entries will be inactive.']);
      return
   end

   if strcmp(oldsource, 'empty') || height(oldlist) == 0
      warning(['matfunclib:buildtoolboxdirectory:rebuildEmptyOld', ...
         'Existing toolbox directory is empty; active state cannot be preserved.']);
      return
   end

   % Transfer active = true for names present in both lists.
   oldNames  = string(oldlist.name);
   newNames  = string(newlist.name);
   wasActive = oldlist.active;

   for k = 1:height(newlist)
      idx = find(oldNames == newNames(k), 1);
      if ~isempty(idx) && wasActive(idx)
         newlist.active(k) = true;
      end
   end
end

% -------------------------------------------------------------------------
function entries = rmdotfolders(entries)
   %RMDOTFOLDERS Remove hidden and dot entries from a dir() result.
   % Removes . and .. as well as any entry whose name starts with '.' (e.g.
   % .git, .empty, .DS_Store). Such entries are never valid toolbox names.
   hidden = strncmp({entries.name}, '.', 1);
   entries = entries(~hidden);
end
