function cdprojects()
   %CDPROJECTS cd to the project root directory
   %
   % cdprojects() executes cd(mgetenv('MATLAB_PROJECT_PATH')) if this env var
   % exists. Otherwise it does nothing.
   %
   % See also cd, cddata, cdenv, cdfex, cdfunc, cdback, cdproject, cdtb, withcd

   thisdir = pwd();
   cleanup = onCleanup( @() setenv('OLD_CWD', thisdir) );

   cd(mgetenv("MATLAB_PROJECT_PATH"));
end
