function cdfex()
   %CDFEX cd to the FEXFUNCTIONPATH if it exists
   %
   % cdfex() executes cd(getenv('FEXFUNCTIONPATH'))
   %
   % See also cd, cdback, cddata, cdenv, cdfunc, cdhome, cdproject, cdtb, withcd

   thisdir = pwd();
   cleanup = onCleanup( @() setenv('OLD_CWD', thisdir) );
   try
      cd(getenv('FEXFUNCTIONPATH'));
   catch
   end
end
