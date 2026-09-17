function writetbdirectory(toolboxes, tbDirectoryPath, backuppath)
   %WRITETBDIRECTORY Write toolbox directory to canonical CSV.
   %
   % writetbdirectory(toolboxes)
   % writetbdirectory(toolboxes, tbDirectoryPath)
   % writetbdirectory(toolboxes, tbDirectoryPath, backuppath)
   %
   % Invariants enforced:
   %
   %   EMPTY-WRITE PROTECTION: A 0-row table is refused. This prevents
   %   deactivate('all') and other callers from silently destroying the
   %   canonical registry when they read an already-corrupted CSV and write
   %   the empty result back. Use buildtoolboxdirectory to rebuild from
   %   the filesystem if the CSV is legitimately empty.
   %
   %   REQUIRED FIELDS: name, source, active, library must all be present.
   %
   %   BACKUP BEFORE WRITE: The current canonical CSV is saved to a MAT file
   %   in MATLAB_DIRECTORY_PATH before every successful write. This mirrors the
   %   backup behavior in writeprjdirectory and allows readtbdirectory to
   %   fall back to the most recent backup if the CSV becomes corrupted.
   %   backupdirectoryfile makes the backup with the CSV-to-MAT conversion
   %   below. BACKUPPATH overrides the tbd_*.mat destination so a test can
   %   drive the backup-failure branch.
   %
   % See also: readtbdirectory, buildtoolboxdirectory, gettbbackuppath,
   %   backupdirectoryfile

   if nargin < 2
      tbDirectoryPath = gettbdirectorypath();
   end

   % Guard: reject empty writes.
   % An empty table most likely means the CSV was already corrupted/missing
   % on the preceding read, not that all toolboxes should be removed.
   if height(toolboxes) == 0
      warning('matfunclib:writetbdirectory:emptyWrite', ...
         ['writetbdirectory: refusing to write empty toolbox table to\n  %s\n' ...
         'Run buildtoolboxdirectory to rebuild from the filesystem.'], ...
         tbDirectoryPath);
      return
   end

   % Guard: required fields must be present.
   requiredFields = {'name', 'source', 'active', 'library'};
   missingFields = requiredFields(~ismember(requiredFields, ...
      toolboxes.Properties.VariableNames));
   if ~isempty(missingFields)
      error('matfunclib:writetbdirectory:missingFields', ...
         'writetbdirectory: table is missing required fields: %s', ...
         strjoin(missingFields, ', '));
   end

   % Backup: save current canonical CSV as a MAT file before overwriting.
   % Only back up if the existing file is non-empty (no point keeping a
   % zero-byte or header-only file as a restore target).
   % Non-fatal: backup failure is warned about but does not block the write.
   % gettbbackuppath runs outside backupdirectoryfile's try, so a missing
   % helper raises its own error before the write overwrites the canonical
   % file with no backup made.
   if nargin < 3
      backuppath = gettbbackuppath();
   end
   backupdirectoryfile(tbDirectoryPath, backuppath, mfilename, @csvtomat);

   writetable(toolboxes, tbDirectoryPath);

   % Rotate the backup pool (toolbox backups use the tbd_*.mat prefix).
   prunedirectorybackups(fileparts(tbDirectoryPath), "tbd_*.mat");
end

function csvtomat(csvpath, matpath)
   %CSVTOMAT Save the CSV's rows as toolboxes_backup in a MAT file.
   %
   % readtbdirectory's fallback loads the variable toolboxes_backup from
   % the newest tbd_*.mat file, so the backup keeps that format. A
   % header-only CSV is no restore target, so the function writes no file
   % for it.
   toolboxes_backup = readtable(csvpath, ...
      'Delimiter', ',', 'ReadVariableNames', true);
   if height(toolboxes_backup) > 0
      save(matpath, 'toolboxes_backup');
   end
end
