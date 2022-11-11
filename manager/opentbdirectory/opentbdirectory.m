function opentbdirectory()
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
   p                 = inputParser;
   p.FunctionName    = 'opentbdirectory';
   p.CaseSensitive   = false;
   p.KeepUnmatched   = true;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   dbpath = [getenv('TBDIRECTORYPATH') 'toolboxdirectory.csv'];
   
   system(sprintf('open %s',dbpath));