function [toolboxes, source] = readtbdirectory(dbpath, allowempty)
   %READTBDIRECTORY Read toolbox directory from canonical CSV.
   %
   % toolboxes = readtbdirectory()
   % toolboxes = readtbdirectory(dbpath)
   % toolboxes = readtbdirectory(dbpath, allowempty)
   % [toolboxes, source] = readtbdirectory(...)
   %
   % Returns:
   %   toolboxes - table with columns: name, source, active, library
   %   source    - where the data came from: 'canonical' | 'backup' | 'empty'
   %
   % Recovery order (the same as readprjdirectory):
   %   1. Canonical CSV at dbpath (if non-empty and readable)
   %   2. Most recent MAT backup (tbd_*.mat) in MATLAB_DIRECTORY_PATH
   %   3. Error matfunclib:readtbdirectory:noUsableDirectory with rebuild
   %      guidance. By default the function returns no empty table. A
   %      caller that reads a table and writes it back (addtoolbox,
   %      deactivate, rmtoolbox, renametoolbox) would otherwise erase a
   %      good registry with the empty result (matfunclib-b7u item 2).
   %
   % readtbdirectory(dbpath, true) opts in to the empty table with the
   % correct schema (source = 'empty') as the last resort in place of the
   % error. The one caller is buildtoolboxdirectory's 'rebuild' mode,
   % whose first run on a machine has no registry to preserve. Pass []
   % as dbpath to keep the default path. No caller writes the 'empty'
   % table back to disk.
   %
   % See also: writetbdirectory, buildtoolboxdirectory, gettbdirectorypath

   if nargin < 1 || isempty(dbpath)
      dbpath = gettbdirectorypath();
   end
   % Only a logical scalar true opts in. An empty, numeric, or non-scalar
   % second argument must not count as permission for the empty table
   % (isequal(1, true) would).
   allowempty = nargin > 1 && islogical(allowempty) && ...
      isscalar(allowempty) && allowempty;

   source = 'canonical';

   % --- Attempt 1: canonical CSV ---
   try
      % Treat missing or zero-byte file as unreadable.
      if ~isfile(dbpath)
         error('matfunclib:readtbdirectory:notFound', ...
            'Canonical CSV not found: %s', dbpath);
      end
      info = dir(dbpath);
      if info.bytes == 0
         error('matfunclib:readtbdirectory:emptyFile', ...
            'Canonical CSV is 0 bytes: %s', dbpath);
      end

      toolboxes = readtable(dbpath, 'Delimiter', ',', 'ReadVariableNames', true);

      % A file with none of the registry columns is not a registry (a
      % corrupt or foreign CSV) and goes to the backup fallback. A file
      % with some of them is a registry whose schema drifted, a writer
      % defect that a backup would hide (audit MEDIUM 29 and 30).
      expected = {'name', 'source', 'active', 'library'};
      found = ismember(expected, toolboxes.Properties.VariableNames);
      if ~any(found)
         error('matfunclib:readtbdirectory:notARegistry', ...
            'CSV holds none of the registry columns: %s', dbpath);
      elseif ~all(found)
         error('matfunclib:readtbdirectory:schemaDrift', ...
            'CSV is missing registry columns (%s): %s', ...
            strjoin(expected(~found), ', '), dbpath);
      end
      toolboxes.library = string(toolboxes.library);

      if height(toolboxes) == 0
         error('matfunclib:readtbdirectory:emptyTable', ...
            'CSV contains only headers (0 data rows): %s', dbpath);
      end

      return   % success — source is already 'canonical'

   catch readErr
      % Reading an existing file never throws UndefinedFunction, and a
      % CSV the writer produced always holds the library column. Either
      % class is a code or schema defect, and a backup fallback would hide
      % it behind stale data (isreaderdefect lists the classes).
      if isreaderdefect(readErr)
         rethrow(readErr)
      end
      warning('matfunclib:readtbdirectory:canonicalFailed', ...
         'readtbdirectory: canonical CSV unreadable (%s). Trying MAT backup.', ...
         readErr.message);
   end

   % --- Attempt 2: most recent MAT backup in MATLAB_DIRECTORY_PATH ---
   % Toolbox backups use the prefix 'tbd_' (set by gettbbackuppath) so they
   % can be found without scanning the project-directory backups (tp*.mat).
   source = 'backup';
   try
      % mgetenv keeps the folder absolute when the variable is unset,
      % so the backup scan never resolves against cwd (matfunclib-47r).
      tbdir = mgetenv('MATLAB_DIRECTORY_PATH');
      backups = dir(fullfile(tbdir, 'tbd_*.mat'));

      if isempty(backups)
         error('matfunclib:readtbdirectory:noValidBackup', ...
            'No toolbox-directory MAT backups (tbd_*.mat) found in %s.', tbdir);
      end

      [~, idx] = max([backups.datenum]);
      bkfile = fullfile(tbdir, backups(idx).name);
      loaded = load(bkfile, 'toolboxes_backup');
      toolboxes = loaded.toolboxes_backup;

      % A backup missing any registry column is no restore target either.
      % Returning it would defer the failure to the caller's first column
      % access rather than report the backup here.
      missingcols = setdiff({'name', 'source', 'active', 'library'}, ...
         toolboxes.Properties.VariableNames);
      if ~isempty(missingcols)
         error('matfunclib:readtbdirectory:badBackup', ...
            'Toolbox-directory backup lacks columns (%s): %s', ...
            strjoin(missingcols, ', '), bkfile);
      end
      toolboxes.library = string(toolboxes.library);

      % A zero-row backup is no restore target: returning it would hand a
      % write-back caller the empty table the default read refuses.
      if height(toolboxes) == 0
         error('matfunclib:readtbdirectory:emptyBackup', ...
            'Toolbox-directory backup holds no rows: %s', bkfile);
      end

      warning('matfunclib:readtbdirectory:restoredFromBackup', ...
         ['readtbdirectory: read the toolbox directory from backup ' ...
         '(canonical file left in place):\n  %s'], bkfile);
      return

   catch bkErr
      % Rethrow the same defect classes the canonical catch rethrows: a
      % missing helper or a schema fault is not a bad backup file.
      if isreaderdefect(bkErr)
         rethrow(bkErr)
      end
      warning('matfunclib:readtbdirectory:backupFailed', ...
         'readtbdirectory: MAT backup read failed (%s).', bkErr.message);
   end

   % --- Last resort: error with rebuild guidance, or the opt-in empty ---
   % table with the correct schema for the bootstrap that asked for it.
   if ~allowempty
      error('matfunclib:readtbdirectory:noUsableDirectory', ...
         ['readtbdirectory: no usable toolbox directory found at\n  %s\n' ...
         'Run buildtoolboxdirectory to rebuild from the filesystem.'], dbpath);
   end
   source = 'empty';
   warning('matfunclib:readtbdirectory:returnedEmpty', ...
      ['readtbdirectory: no usable toolbox directory found. ' ...
      'Returning empty table.\nRun buildtoolboxdirectory to rebuild from the filesystem.']);
   toolboxes = table( ...
      'Size', [0 4], ...
      'VariableTypes', {'cellstr', 'cellstr', 'logical', 'string'}, ...
      'VariableNames', {'name', 'source', 'active', 'library'});
end
