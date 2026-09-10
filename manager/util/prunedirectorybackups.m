function pruned = prunedirectorybackups(folder, pattern, keep)
   %PRUNEDIRECTORYBACKUPS Delete all but the newest registry backup files.
   %
   %  pruned = prunedirectorybackups(folder, pattern) keeps the newest 25
   %  files in FOLDER matching PATTERN and deletes the rest, returning the
   %  deleted file names as a cell array of char, not a string array, so
   %  Octave can run the writers that call this.
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

   % narginchk and validators stand in for an arguments block, because
   % Octave does not parse arguments blocks and the writers that call this
   % after every registry write must be able to run under Octave.
   narginchk(2, 3)
   folder = char(folder);
   pattern = char(pattern);
   if ~isfolder(folder)
      error('matfunclib:prunedirectorybackups:notAFolder', ...
         'prunedirectorybackups: %s is not a folder', folder);
   end
   if nargin < 3
      % Default retention count. juq.7's choke-point config may later expose
      % this as a configurable setting; until then this is the single source.
      keep = 25;
   end
   mustBeInteger(keep)
   mustBeNonnegative(keep)

   backups = dir(fullfile(folder, pattern));
   pruned = cell(0, 1);
   if numel(backups) <= keep
      return
   end

   % Newest first, then delete everything past the retention count. The
   % deletion count is known up front; trim the preallocation afterward to
   % drop slots left empty by failed deletions.
   [~, order] = sort([backups.datenum], 'descend');
   backups = backups(order);
   pruned = cell(numel(backups) - keep, 1);
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
         pruned{ndeleted} = backups(n).name;
      end
   end
   pruned = pruned(1:ndeleted);
end
