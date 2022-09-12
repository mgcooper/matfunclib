function showtbdirectory()
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
   p                 = inputParser;
   p.FunctionName    = 'showtbdirectory';
   p.CaseSensitive   = false;
   p.KeepUnmatched   = true;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   dbpath   = gettbdirectorypath;
   tbdir    = readtbdirectory(dbpath);
   
   disp(tbdir)