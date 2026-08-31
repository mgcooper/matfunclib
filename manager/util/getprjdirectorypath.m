function prjpath = getprjdirectorypath()
   %GETPRJDIRECTORYPATH Get the full path to the project registry file.
   %
   % mgetenv falls back to the mconfig default when the variable is
   % unset. The returned path is always absolute, so a registry save
   % cannot land in the current folder (matfunclib-47r).
   prjpath = fullfile(mgetenv('MATLAB_DIRECTORY_PATH'),'projectdirectory.mat');
   % prjpath = fullfile(mgetenv('MATLAB_DIRECTORY_PATH'),'projectdirectory.csv');
end
