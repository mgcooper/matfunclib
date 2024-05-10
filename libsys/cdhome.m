function cdhome()
   %CDHOME cd to the home directory
   %
   % cdhome() executes cd(getenv('MATLABUSERPATH')) if this env var exists.
   % cdhome() executes cd(userpath) if MATLABUSERPATH does not exist.
   %
   % See also cd, cddata, cdenv, cdfex, cdfunc, cdback, cdproject, cdtb, withcd

   thisdir = pwd();
   cleanup = onCleanup( @() setenv('OLD_CWD', thisdir) );

   if isenv('MATLABUSERPATH')
      cd(getenv('MATLABUSERPATH'));
   else
      cd(userpath);
   end
end
