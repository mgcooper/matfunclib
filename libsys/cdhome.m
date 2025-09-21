function cdhome()
   %CDHOME cd to the home directory
   %
   % cdhome() executes cd(getenv('MATLAB_HOME_PATH')) if this env var exists.
   % cdhome() executes cd(userpath) if MATLAB_HOME_PATH does not exist.
   %
   % See also cd, cddata, cdenv, cdfex, cdfunc, cdback, cdproject, cdtb, withcd

   thisdir = pwd();
   cleanup = onCleanup( @() setenv('OLD_CWD', thisdir) );

   if isenv('MATLAB_HOME_PATH')
      cd(getenv('MATLAB_HOME_PATH'));
   else
      cd(userpath);
   end
end
