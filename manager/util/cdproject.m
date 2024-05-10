function cdproject(projectname)
   %CDPROJECT cd to the active project root directory
   %
   % cdproject() changes the current working directory to the active project
   % directory.
   %
   % cdproject(projectname) changes the current working directory to
   % PROJECTNAME's root directory.
   %
   % See also cd, cddata, cdenv, cdfex, cdfunc, cdback, cdproject, cdtb, withcd

   thisdir = pwd();
   cleanup = onCleanup( @() setenv('OLD_CWD', thisdir) );
   if nargin == 0
      projectname = getactiveproject();
   end
   cd(getprojectfolder(projectname));
end
