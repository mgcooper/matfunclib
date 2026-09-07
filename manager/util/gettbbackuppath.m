function filename = gettbbackuppath()
   %GETTBBACKUPPATH Generate a unique backup file path under MATLAB_DIRECTORY_PATH.
   %
   % Mirrors gettmpdirectorypath for the project directory.
   %
   % See also: gettmpdirectorypath, writetbdirectory
   % Use a 'tbd_' prefix to distinguish toolbox-directory backups from the
   % project-directory backups (tp*.mat) in the same MATLAB_DIRECTORY_PATH folder.
   % mgetenv keeps the target absolute when the variable is unset, so a
   % backup can never land in the current folder (matfunclib-47r).
   [~, name] = fileparts(tempname);
   filename = fullfile(mgetenv('MATLAB_DIRECTORY_PATH'), ['tbd_' name '.mat']);
end
