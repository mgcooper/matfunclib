function opentbdirectory()
   %OPENTBDIRECTORY Open the toolbox directory spreadsheet in Excel.
   %
   %
   % See also:

   try
      system(sprintf('open %s', ...
         fullfile(getenv('TBDIRECTORYPATH'),'toolboxdirectory.csv')));
   catch
   end
end
