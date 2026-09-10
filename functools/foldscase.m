function tf = foldscase(target)
   %FOLDSCASE True when the file system holding TARGET folds case.
   %
   %  tf = foldscase(target) probes the volume that holds TARGET, a file
   %  or folder path. The probe folder is the target's folder, or the
   %  target itself when it is a folder. When the target does not exist
   %  yet (an install destination that a dry run has not created), the
   %  probe folder is the nearest existing ancestor. foldscase creates a
   %  subfolder there under a name tempname reserves as unused, writes a
   %  probe file with a mixed-case name inside it, and looks the file up
   %  in the other case. It removes both before it returns. The fresh
   %  subfolder means the probe can collide with nothing the caller owns.
   %  Only a volume that ignores case (Windows, the default macOS volume)
   %  finds the other spelling. When no folder can be probed or written
   %  (no existing ancestor, a read-only folder), the host convention
   %  stands in: true on Windows and macOS, false elsewhere.
   %
   %  Two callers depend on this answer. installRequiredFiles decides
   %  whether two requirement names that differ only by case are one
   %  destination. setprojectfiles decides whether an editor path and a
   %  stored path spelled differently are one file. Case folding is a
   %  property of the volume, not the platform, so both probe it.
   %
   % See also: ispc, ismac, isfile, isfolder, tempname

   narginchk(1, 1)
   target = char(target);

   % The folder to probe: the target's own folder, or the nearest ancestor
   % that exists. A bare relative name has no folder part and lives in the
   % current folder. fileparts of a root returns the root, which ends the
   % walk.
   if isfolder(target)
      folder = target;
   else
      folder = fileparts(target);
      if isempty(folder)
         folder = pwd;
      end
   end
   while ~isfolder(folder) && ~isempty(folder) && ~strcmp(fileparts(folder), folder)
      folder = fileparts(folder);
   end
   % A relative path whose parts are all missing walks down to an empty
   % string. It lives under the current folder, so that folder is probed.
   if isempty(folder)
      folder = pwd;
   end
   if ~isfolder(folder)
      tf = ispc || ismac;
      return
   end

   % The probe lives in a folder tempname reserves as unused, so its
   % mixed-case name can collide with nothing already there. The cleanup
   % object exists before the first write and runs when this function
   % returns (Octave cannot delete an onCleanup object early). Neither
   % the probe file nor its folder outlives this function, on the normal
   % path or after an error. A folder that cannot be written cannot be
   % probed.
   probeDir = tempname(folder);
   probe = fullfile(probeDir, 'CaseProbe.tmp');
   cleanup = onCleanup(@() removeprobe(probeDir));
   try
      mkdir(probeDir)
      fid = fopen(probe, 'w');
   catch
      fid = -1;
   end
   if fid < 0
      tf = ispc || ismac;
      return
   end
   fclose(fid);
   tf = isfile(fullfile(probeDir, 'caseprobe.tmp'));
end

function removeprobe(probeDir)
   %REMOVEPROBE Delete the probe folder and its file when they exist.
   if isfolder(probeDir)
      rmdir(probeDir, 's')
   end
end
