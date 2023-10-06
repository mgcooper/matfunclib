function tf = isspreadsheet(filename)
   %ISSPREADSHEET Return true if file has a spreadsheet extension.
   %
   %
   % See also:

   spreadsheetextensions = {'.xlsx','.xls','.xlsm','.xltx','.xltm'};

   tf = false;
   if contains(filename,spreadsheetextensions)
      tf = true;
   end
end
