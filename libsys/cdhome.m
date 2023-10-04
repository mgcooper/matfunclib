function cdhome()
   %CDBACK cd to the prior working directory
   %
   % cdback() executes cd(getenv('OLD_CWD'))
   %
   % See also cd, cddata, cdenv, cdfex, cdfunc, cdhome, cdproject, cdtb, withcd

   thisdir = pwd();
   cleanup = onCleanup( @() setenv('OLD_CWD', thisdir) );

   if isenv('MATLABUSERPATH')
      cd(getenv('MATLABUSERPATH'));
   else
      cd(userpath);
   end
end
