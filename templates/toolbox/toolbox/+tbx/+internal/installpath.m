function fullpath = installpath(toolboxname)
%INSTALLPATH get toolbox installation path 
% 
% 
% See also

fullpath = getpref(toolboxname, 'install_path');