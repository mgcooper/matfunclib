function tf = isspreadsheet(filename)
   
   spreadsheetextensions = {'.xlsx','.xls','.xlsm','.xltx','.xltm'};
   
   tf = false;
   if contains(filename,spreadsheetextensions)
      tf = true;
   end