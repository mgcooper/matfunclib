function writeprjdirectory(projectlist)
   %WRITEPRJDIRECTORY Write the project directory to canonical MAT file.
   %
   % writeprjdirectory(projectlist)
   % writeprjdirectory()   % re-writes the current directory (no-op refresh)
   %
   % Invariants enforced (mirroring writetbdirectory):
   %
   %   EMPTY-WRITE PROTECTION: A 0-row table is refused. This prevents a
   %   caller that read an already-corrupted directory from silently
   %   destroying the canonical registry by writing the empty result back.
   %   Run buildprojectdirectory to rebuild if the directory is legitimately
   %   empty.
   %
   %   REQUIRED FIELDS: name, folder, activefiles, activeproject,
   %   activefolder must all be present.
   %
   %   BACKUP BEFORE WRITE: The current canonical MAT file is copied to a
   %   tp*.mat backup before every successful write. A missing or empty
   %   canonical file skips the backup instead of erroring, so a first
   %   write into a fresh directory folder works. Backups rotate through
   %   prunedirectorybackups so the pool stops growing without bound.
   %
   % See also: readprjdirectory, writetbdirectory, prunedirectorybackups

   if isoctave
      error('writeprjdirectory is not supported in Octave.')
   end

   if nargin < 1
      % will be struct in octave, table in matlab
      projectlist = readprjdirectory();
   end

   % get the full path to projectdirectory.mat
   projectdirectorypath = getprjdirectorypath();

   % Guard: reject empty writes.
   % An empty table most likely means the directory was already corrupted or
   % missing on the preceding read, not that every project should be removed.
   if height(projectlist) == 0
      warning('matfunclib:writeprjdirectory:emptyWrite', ...
         ['writeprjdirectory: refusing to write empty project table to\n' ...
         '  %s\nRun buildprojectdirectory to rebuild from the filesystem.'], ...
         projectdirectorypath);
      return
   end

   % Guard: required fields must be present.
   requiredFields = {'name', 'folder', 'activefiles', 'activeproject', ...
      'activefolder'};
   missingFields = requiredFields(~ismember(requiredFields, ...
      projectlist.Properties.VariableNames));
   if ~isempty(missingFields)
      error('matfunclib:writeprjdirectory:missingFields', ...
         'writeprjdirectory: table is missing required fields: %s', ...
         strjoin(missingFields, ', '));
   end

   % Backup: copy the current canonical file before overwriting. A missing
   % or zero-byte canonical file is skipped, not an error, so the first
   % write into a fresh directory folder succeeds. Non-fatal: a backup
   % failure warns but does not block the write.
   if isfile(projectdirectorypath)
      try
         info = dir(projectdirectorypath);
         if info.bytes > 0
            tmpfile = gettmpdirectorypath();
            copyfile(projectdirectorypath, tmpfile);
         end
      catch backupErr
         warning('matfunclib:writeprjdirectory:backupFailed', ...
            'writeprjdirectory: could not create backup before writing (%s).', ...
            backupErr.message);
      end
   end

   % If struct2table works in Octave, then this could be used to allow updating
   % in Octave, but test it first.
   % if isstruct(projectlist)
   %    projectstruct = projectlist;
   %    projectlist = struct2table(projectlist);
   % else
   %    projectstruct = table2struct(projectlist);
   % end

   % Save it
   save(projectdirectorypath, 'projectlist')

   % Rotate the backup pool (project backups use the tp*.mat prefix).
   prunedirectorybackups(fileparts(projectdirectorypath), "tp*.mat");

   % % old method that saved the directory as a table
   % writetable(projectlist,projectdirectorypath);
end
