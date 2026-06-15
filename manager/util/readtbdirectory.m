function [toolboxes, source] = readtbdirectory(dbpath)
   %READTBDIRECTORY Read toolbox directory from canonical CSV.
   %
   % toolboxes = readtbdirectory()
   % toolboxes = readtbdirectory(dbpath)
   % [toolboxes, source] = readtbdirectory(...)
   %
   % Returns:
   %   toolboxes - table with columns: name, source, active, library
   %   source    - where the data came from: 'canonical' | 'backup' | 'empty'
   %
   % Recovery order:
   %   1. Canonical CSV at dbpath (if non-empty and readable)
   %   2. Most recent MAT backup (tbd_*.mat) in TBDIRECTORYPATH
   %   3. Empty table with correct schema (source = 'empty')
   %
   % The 'empty' case is intentionally NOT written back to disk. Callers
   % that check source == 'empty' should call buildtoolboxdirectory to
   % rebuild from the filesystem rather than proceeding with an empty table.
   %
   % See also: writetbdirectory, buildtoolboxdirectory, gettbdirectorypath

   if nargin < 1
      dbpath = gettbdirectorypath();
   end

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
      toolboxes.library = string(toolboxes.library);

      if height(toolboxes) == 0
         error('matfunclib:readtbdirectory:emptyTable', ...
            'CSV contains only headers (0 data rows): %s', dbpath);
      end

      return   % success — source is already 'canonical'

   catch readErr
      warning('matfunclib:readtbdirectory:canonicalFailed', ...
         'readtbdirectory: canonical CSV unreadable (%s). Trying MAT backup.', ...
         readErr.message);
   end

   % --- Attempt 2: most recent MAT backup in TBDIRECTORYPATH ---
   % Toolbox backups use the prefix 'tbd_' (set by gettbbackuppath) so they
   % can be found without scanning the project-directory backups (tp*.mat).
   source = 'backup';
   try
      tbdir = getenv('TBDIRECTORYPATH');
      backups = dir(fullfile(tbdir, 'tbd_*.mat'));

      if isempty(backups)
         error('matfunclib:readtbdirectory:noValidBackup', ...
            'No toolbox-directory MAT backups (tbd_*.mat) found in %s.', tbdir);
      end

      [~, idx] = max([backups.datenum]);
      bkfile = fullfile(tbdir, backups(idx).name);
      loaded = load(bkfile, 'toolboxes_backup');
      toolboxes = loaded.toolboxes_backup;
      toolboxes.library = string(toolboxes.library);

      warning('matfunclib:readtbdirectory:restoredFromBackup', ...
         'readtbdirectory: toolbox directory restored from backup:\n  %s', bkfile);
      return

   catch bkErr
      warning('matfunclib:readtbdirectory:backupFailed', ...
         'readtbdirectory: MAT backup restore failed (%s).', bkErr.message);
   end

   % --- Last resort: empty table with correct schema ---
   source = 'empty';
   warning('matfunclib:readtbdirectory:returnedEmpty', ...
      ['readtbdirectory: no usable toolbox directory found. ' ...
      'Returning empty table.\nRun buildtoolboxdirectory to rebuild from the filesystem.']);
   toolboxes = table( ...
      'Size', [0 4], ...
      'VariableTypes', {'cellstr', 'cellstr', 'logical', 'string'}, ...
      'VariableNames', {'name', 'source', 'active', 'library'});
end
