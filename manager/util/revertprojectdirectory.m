function projlist = revertprojectdirectory(varargin)
   %REVERTPROJECTDIRECTORY Revert project directory to previous (backup) version
   %
   %  revertprojectdirectory(N) Replaces the current directory with the the Nth
   %  backup.
   %
   % See also:

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

   [latestfiles,filedates] = getlatestfile(projectdirectoryfolder,[1,n]);

   % first backup the current one
   if strcmp(latestfiles{1},'projectdirectory.mat')

      more on

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
   more off % turn paging off
end
