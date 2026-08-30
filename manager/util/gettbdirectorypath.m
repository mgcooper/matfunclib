function dbpath = gettbdirectorypath()
   %GETTBDIRECTORYPATH Get the full path to the toolbox directory file.
   dbpath = fullfile(getenv('MATLAB_DIRECTORY_PATH'),'toolboxdirectory.csv');
end
