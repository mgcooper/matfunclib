function dbpath = gettbdirectorypath()
   %GETTBDIRECTORYPATH Get the full path to the toolbox directory file.
   %
   % mgetenv falls back to the mconfig default when the variable is
   % unset. The returned path is always absolute, so a registry save
   % cannot land in the current folder (matfunclib-47r).
   dbpath = fullfile(mgetenv('MATLAB_DIRECTORY_PATH'),'toolboxdirectory.csv');
end
