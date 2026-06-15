function writetbdirectory(toolboxes, tbDirectoryPath)
   %WRITETBDIRECTORY Write toolbox directory to canonical CSV.
   %
   % writetbdirectory(toolboxes)
   % writetbdirectory(toolboxes, tbDirectoryPath)
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
   %   in TBDIRECTORYPATH before every successful write. This mirrors the
   %   backup behavior in writeprjdirectory and allows readtbdirectory to
   %   fall back to the most recent backup if the CSV becomes corrupted.
   %
   % See also: readtbdirectory, buildtoolboxdirectory, gettbbackuppath

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
   if isfile(tbDirectoryPath)
      try
         info = dir(tbDirectoryPath);
         if info.bytes > 0
            toolboxes_backup = readtable(tbDirectoryPath, ...
               'Delimiter', ',', 'ReadVariableNames', true); %#ok<NASGU>
            if height(toolboxes_backup) > 0
               backuppath = gettbbackuppath();
               save(backuppath, 'toolboxes_backup');
            end
         end
      catch backupErr
         warning('matfunclib:writetbdirectory:backupFailed', ...
            'writetbdirectory: could not create backup before writing (%s).', ...
            backupErr.message);
      end
   end

   writetable(toolboxes, tbDirectoryPath);
end
