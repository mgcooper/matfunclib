function projpath = getprjsourcepath(projname)
%GETPRJSOURCEPATH get path to root of project

% note: should rename to getprojectpath
if nargin == 0
   projpath = getenv('MATLABPROJECTPATH');
else
   projlist = readprjdirectory;
   projindx = ismember(projlist.name,projname);
   projpath = fullfile(projlist.folder{projindx},projname);
end

   
% % deprecated by new method that reads the folder in the project directory
%    if nargin == 0
%       prjpath = getenv('MATLABPROJECTPATH');
%    else
%       prjpath = [getenv('MATLABPROJECTPATH') prjname '/'];
%    end
   