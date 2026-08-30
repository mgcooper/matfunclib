function opentbdirectory()
   %OPENTBDIRECTORY Open the toolbox directory spreadsheet in Excel.
   %
   %
   % See also:

   try
      system(sprintf('open %s', ...
         fullfile(getenv('MATLAB_DIRECTORY_PATH'),'toolboxdirectory.csv')));
   catch
   end
end
