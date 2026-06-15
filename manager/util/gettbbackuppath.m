function filename = gettbbackuppath()
   %GETTBBACKUPPATH Generate a unique backup file path under TBDIRECTORYPATH.
   %
   % Mirrors gettmpdirectorypath for the project directory.
   %
   % See also: gettmpdirectorypath, writetbdirectory
   % Use a 'tbd_' prefix to distinguish toolbox-directory backups from the
   % project-directory backups (tp*.mat) in the same TBDIRECTORYPATH folder.
   [~, name] = fileparts(tempname);
   filename = fullfile(getenv('TBDIRECTORYPATH'), ['tbd_' name '.mat']);
end
