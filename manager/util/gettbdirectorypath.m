function dbpath = gettbdirectorypath()
   %GETTBDIRECTORYPATH Get the full path to the toolbox directory file.
   dbpath = fullfile(getenv('TBDIRECTORYPATH'),'toolboxdirectory.csv');
end
