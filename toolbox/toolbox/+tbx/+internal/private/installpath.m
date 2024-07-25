function fullpath = installpath(toolboxname)
   %INSTALLPATH Return toolbox installation path from user preferences group.
   %
   %
   % See also:
   if nargin < 1
      toolboxname = mpackagename();
   end
   fullpath = getpref(toolboxname, 'install_path');
end
