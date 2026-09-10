function projlist = revertprojectdirectory(varargin)
   %REVERTPROJECTDIRECTORY Revert project directory to previous (backup) version
   %
   %  revertprojectdirectory(N) Replaces the current directory with the the Nth
   %  backup.
   %
   %  The candidates are projectdirectory.mat (always first) and then the
   %  backups, newest first. The backups are the tp*.mat files
   %  writeprjdirectory makes and the projectdirectory_revert_*.mat
   %  snapshots this function saves before a revert. The function skips a
   %  backup byte-identical to the current file, and toolbox files in the
   %  same folder are never candidates. The prompt runs in the desktop
   %  only; a declined prompt returns the current list.
   %
   % See also: readprjdirectory, writeprjdirectory

   % n is the nth-previous backup
   if nargin == 1
      n = varargin{1};
   else
      n = 2;
   end

   % path to projectdirectory.mat
   projectdirectorypath = getprjdirectorypath;

   % strip the filename off the path to keep the folder
   projectdirectoryfolder = fileparts(projectdirectorypath);

   % Only the project files are candidates. The folder also holds the
   % toolbox CSV and its tbd_*.mat backups, which must never be copied
   % over projectdirectory.mat (audit LOW 53).
   [latestfiles,filedates] = latestprojectfiles(projectdirectoryfolder, n);

   % first backup the current one
   if strcmp(latestfiles{1},'projectdirectory.mat')

      % Paging needs the desktop; a headless session has no pager.
      if usejava('desktop')
         more on
      end

      fprintf('\n current project directory: %s',filedates(1));
      fprintf('\n revert project directory:  %s\n\n',filedates(2));

      str = input(' press y to continue or any other key to cancel\n',"s");

      if ~strncmp(str,'y',1)
         projlist = readprjdirectory();
         return
      end

      projectdirectory_backup = fullfile(projectdirectoryfolder, ...
         ['projectdirectory_revert_' strrep(latestfiles{2},'.mat','') '.mat']);

      fprintf('\n backing up project directory (%s) to %s \n', ...
         filedates(1),projectdirectory_backup);

      % copyfile(projectdirectorypath,projectdirectory_backup);
   else
      error(' latest file should be projectdirectory.mat')
   end

   % now replace the directory with the backup
   fprintf('\n reverting project directory to %s (%s)\n\n',latestfiles{2},filedates(2));

   % cleanup
   cleanup = onCleanup(@()cleanupfun( ...
      projectdirectorypath,projectdirectory_backup,latestfiles));

   % return the new projlist (doesn't work, need to understand onCleanup better)
   % projlist = readprjdirectory();
end

function [names, dates] = latestprojectfiles(folder, n)
   %LATESTPROJECTFILES The canonical file and the (n-1)th-newest backup.
   %
   % The canonical projectdirectory.mat is always the first candidate. A
   % completed revert leaves it older than the snapshot that revert saved
   % (copyfile keeps modification times), so it must not compete in the
   % date order. The backups are the tp*.mat files writeprjdirectory
   % makes and the projectdirectory_revert_*.mat snapshots this function
   % saves before a revert, newest first. The snapshot lets a revert be
   % undone. dir on a folder of that name lists its contents, so a folder
   % shows as one or more isdir entries and the same test rejects it.
   canonical = dir(fullfile(folder, 'projectdirectory.mat'));
   if isempty(canonical) || any([canonical.isdir])
      error('matfunclib:revertprojectdirectory:noCanonical', ...
         'revertprojectdirectory: no projectdirectory.mat file in %s', folder);
   end
   backups = [dir(fullfile(folder, 'tp*.mat')); ...
      dir(fullfile(folder, 'projectdirectory_revert_*.mat'))];
   backups = backups(~[backups.isdir]);
   [~, order] = sort([backups.datenum], 'descend');
   backups = backups(order);

   % A backup whose bytes equal the canonical file (the snapshot a revert
   % just restored, or a copy of the current state) would restore the
   % registry onto itself. Repeated reverts skip it and go on to older
   % backups.
   current = fileread(fullfile(folder, canonical.name));
   same = arrayfun(@(b) isequal(fileread(fullfile(folder, b.name)), ...
      current), backups);
   backups = backups(~same);
   if numel(backups) < n - 1
      error('matfunclib:revertprojectdirectory:noBackup', ...
         'revertprojectdirectory: fewer than %d project registry backups in %s', ...
         n - 1, folder);
   end
   listing = [canonical; backups(n - 1)];
   names = {listing.name};
   dates = datetime({listing.date});
end

function cleanupfun(projectdirectorypath,projectdirectory_backup,latestfiles)
   % backup the current directory
   copyfile( ...
      projectdirectorypath, ...
      projectdirectory_backup ...
      );

   % revert to the prior backup
   copyfile( ...
      fullfile(fileparts(projectdirectorypath),latestfiles{2}), ...
      fullfile(fileparts(projectdirectorypath),latestfiles{1}) ...
      );
   if usejava('desktop')
      more off % turn paging off
   end
end
