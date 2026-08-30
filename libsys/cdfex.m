function cdfex()
   %CDFEX cd to the MATLAB_FEX_PATH if it exists
   %
   % cdfex() executes cd(getenv('MATLAB_FEX_PATH'))
   %
   % See also cd, cdback, cddata, cdenv, cdfunc, cdhome, cdproject, cdtb, withcd

   thisdir = pwd();
   cleanup = onCleanup( @() setenv('OLD_CWD', thisdir) );
   try
      cd(getenv('MATLAB_FEX_PATH'));
   catch
   end
end
