function opentbdirectory()
   %OPENTBDIRECTORY Open the toolbox directory spreadsheet in Excel.
   %
   %
   % See also:

   try
      % gettbdirectorypath keeps the target absolute when the variable
      % is unset (matfunclib-47r).
      system(sprintf('open %s', gettbdirectorypath()));
   catch
   end
end
