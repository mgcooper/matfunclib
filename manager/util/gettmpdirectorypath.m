function filename = gettmpdirectorypath
   %GETTMPDIRECTORYPATH Generate a unique tp*.mat backup path under
   %MATLAB_DIRECTORY_PATH (tempname basenames begin with "tp").
   %
   % mgetenv keeps the target absolute when the variable is unset, so a
   % backup can never land in the current folder (matfunclib-47r).
   [~,filename] = fileparts(tempname);
   filename = fullfile(mgetenv('MATLAB_DIRECTORY_PATH'),[filename '.mat']);
end