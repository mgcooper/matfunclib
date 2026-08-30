function cddata()
   %CDDATA cd to USERDATAPATH if it exists
   %
   %  cddata() executes cd(getenv('USERDATAPATH')). If that fails, it tries
   %  MATLAB_ACTIVE_PROJECT_DATA_PATH
   %
   % See also cd, cdback, cdenv, cdfex, cdfunc, cdhome, cdproject, cdtb, withcd

   thisdir = pwd();
   cleanup = onCleanup( @() setenv('OLD_CWD', thisdir) );

   if isenv('USERDATAPATH')
      cd(getenv('USERDATAPATH'));
   elseif isenv('MATLAB_ACTIVE_PROJECT_DATA_PATH')
      cd(getenv('MATLAB_ACTIVE_PROJECT_DATA_PATH'));
   else
      warning('no USERDATAPATH found')
      return
   end
end
