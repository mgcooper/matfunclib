function pruned = prunedirectorybackups(folder, pattern, keep)
   %PRUNEDIRECTORYBACKUPS Delete all but the newest registry backup files.
   %
   %  pruned = prunedirectorybackups(folder, pattern) keeps the newest 25
   %  files in FOLDER matching PATTERN and deletes the rest, returning the
   %  deleted file names.
   %
   %  pruned = prunedirectorybackups(folder, pattern, keep) keeps KEEP files.
   %
   %  This is the one place the backup retention count is defined. Both
   %  registry writers (writeprjdirectory with tp*.mat, writetbdirectory
   %  with tbd_*.mat) call this after a successful write, so the backup
   %  pools stop growing without bound. Deletion failures warn rather than
   %  error: rotation must never block a registry write.
   %
   % See also: writeprjdirectory, writetbdirectory

   arguments
      folder (1, 1) string {mustBeFolder}
      pattern (1, 1) string
      % Default retention count. juq.7's choke-point config may later expose
      % this as a configurable setting; until then this is the single source.
      keep (1, 1) double {mustBeInteger, mustBeNonnegative} = 25
   end

   backups = dir(fullfile(folder, pattern));
   pruned = strings(0, 1);
   if numel(backups) <= keep
      return
   end

   % Newest first, then delete everything past the retention count. The
   % deletion count is known up front; trim the preallocation afterward to
   % drop slots left empty by failed deletions.
   [~, order] = sort([backups.datenum], 'descend');
   backups = backups(order);
   pruned = strings(numel(backups) - keep, 1);
   ndeleted = 0;
   for n = keep+1:numel(backups)
      target = fullfile(folder, backups(n).name);
      try
         delete(target)
      catch pruneErr
         warning('matfunclib:prunedirectorybackups:deleteFailed', ...
            'Could not delete backup %s (%s).', target, pruneErr.message);
         continue
      end
      % delete warns rather than throws on permission failures, so confirm
      % the file is actually gone before counting it as pruned.
      if isfile(target)
         warning('matfunclib:prunedirectorybackups:deleteFailed', ...
            'Could not delete backup %s.', target);
      else
         ndeleted = ndeleted + 1;
         pruned(ndeleted) = string(backups(n).name);
      end
   end
   pruned = pruned(1:ndeleted);
end
