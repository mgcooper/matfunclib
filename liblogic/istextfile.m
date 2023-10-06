function tf = istextfile(filename)

   % note - these are specific to detectImportOptions
   textfileextensions = {'.txt', '.dat', '.csv'};

   tf = false;
   if contains(filename,textfileextensions)
      tf = true;
   end
end
