function backedup = backupdirectoryfile(canonical, backuppath, caller, makebackup)
   %BACKUPDIRECTORYFILE Back up a registry file before a writer overwrites it.
   %
   %  backedup = backupdirectoryfile(canonical, backuppath, caller) copies
   %  CANONICAL to BACKUPPATH with copyfile and returns true. The function
   %  skips a missing or zero-byte CANONICAL and returns false, so a first
   %  write into a fresh directory folder works. A failed backup warns with
   %  matfunclib:<CALLER>:backupFailed and returns false. The writer then
   %  proceeds, because a backup failure must not block a registry write.
   %  The function rethrows an UndefinedFunction raised while it makes the
   %  backup. That error is a code or path defect, not a copy failure. It
   %  must surface before the writer overwrites the canonical file with no
   %  backup made.
   %
   %  backedup = backupdirectoryfile(canonical, backuppath, caller, makebackup)
   %  makes the backup with the function handle MAKEBACKUP(canonical,
   %  backuppath) in place of copyfile. writetbdirectory passes a CSV-to-MAT
   %  conversion so readtbdirectory's tbd_*.mat fallback keeps its format.
   %
   %  BACKUPPATH is an argument, like the folder and pattern arguments of
   %  prunedirectorybackups. A test can then direct the backup at an
   %  unwritable destination and drive the failure branch of both writers.
   %
   % See also: writeprjdirectory, writetbdirectory, prunedirectorybackups

   % narginchk and a default stand in for an arguments block, and char
   % paths stand in for string objects, so Octave can run the writers.
   % Octave parses no arguments block, and its isfile takes no string
   % object.
   narginchk(3, 4)
   canonical = char(canonical);
   backuppath = char(backuppath);
   caller = char(caller);
   if nargin < 4
      makebackup = @copyfile;
   end

   % Nothing to back up: the first write into a fresh directory folder,
   % or a file that was already truncated to nothing.
   backedup = false;
   if ~isfile(canonical)
      return
   end
   info = dir(canonical);
   if info.bytes == 0
      return
   end

   try
      makebackup(canonical, backuppath);
      backedup = true;
   catch backupErr
      if isundefinedfunction(backupErr)
         rethrow(backupErr)
      end
      warning(['matfunclib:' caller ':backupFailed'], ...
         '%s: could not create backup before writing (%s).', ...
         caller, backupErr.message);
   end
end
