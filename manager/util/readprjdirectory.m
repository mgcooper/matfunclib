function [projectlist, source] = readprjdirectory(projectdirectorypath)
   %READPRJDIRECTORY Read the project directory into memory
   %
   %  projectlist = readprjdirectory(projectdirectorypath)
   %  [projectlist, source] = readprjdirectory(...)
   %
   % Returns:
   %   projectlist - the project registry (table; struct under Octave)
   %   source      - where the data came from: 'canonical' | 'backup'
   %
   % Recovery order (mirroring readtbdirectory):
   %   1. Canonical projectdirectory.mat
   %   2. Most recent tp*.mat backup in MATLAB_DIRECTORY_PATH
   %   3. Error with rebuild guidance. Unlike readtbdirectory, no empty
   %      table is fabricated: the project schema is wider and less stable
   %      than the toolbox schema, and downstream indexing of a guessed
   %      empty schema would fail in less obvious ways than a clear error.
   %
   % See also: writeprjdirectory, readtbdirectory, openprojectdirectory

   if nargin == 0
      % returns the path to projectdirectory.mat including the filename.
      projectdirectorypath = getprjdirectorypath();
   end

   source = 'canonical';

   % --- Attempt 1: canonical MAT file ---
   try
      if isoctave
         % May 2025 - projectstruct must not exist anymore, so another function
         % that writes the file is probably not saving it
         loaded = load(projectdirectorypath, 'projectstruct');
         projectlist = loaded.projectstruct;
      else
         loaded = load(projectdirectorypath, 'projectlist');
         projectlist = loaded.projectlist;
      end
      return

   catch readErr
      warning('matfunclib:readprjdirectory:canonicalFailed', ...
         'readprjdirectory: canonical file unreadable (%s). Trying backup.', ...
         readErr.message);
   end

   % --- Attempt 2: most recent tp*.mat backup ---
   % Project backups use the tp prefix (written by writeprjdirectory via
   % gettmpdirectorypath) so they are distinct from the toolbox backups
   % (tbd_*.mat) in the same folder.
   source = 'backup';
   backupfolder = fileparts(projectdirectorypath);
   backups = dir(fullfile(backupfolder, 'tp*.mat'));
   if ~isempty(backups)
      [~, idx] = max([backups.datenum]);
      bkfile = fullfile(backupfolder, backups(idx).name);
      try
         loaded = load(bkfile, 'projectlist');
         projectlist = loaded.projectlist;
         warning('matfunclib:readprjdirectory:restoredFromBackup', ...
            'readprjdirectory: project directory restored from backup:\n  %s', ...
            bkfile);
         return
      catch bkErr
         warning('matfunclib:readprjdirectory:backupFailed', ...
            'readprjdirectory: backup restore failed (%s).', bkErr.message);
      end
   end

   % --- Last resort: error with rebuild guidance ---
   error('matfunclib:readprjdirectory:noUsableDirectory', ...
      ['readprjdirectory: no usable project directory found at\n  %s\n' ...
      'Run buildprojectdirectory to rebuild from the filesystem.'], ...
      projectdirectorypath);
end
% % old method that saved the directory as a table
% projects = readtable(prjpath,'Delimiter',',','ReadVariableNames',true);
