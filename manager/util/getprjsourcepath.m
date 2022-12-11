function prjpath = getprjsourcepath(prjname)
%GETPRJSOURCEPATH get path to root of project

% note: should rename to getprojectpath
   if nargin == 0
      prjpath = getenv('MATLABPROJECTPATH');
   else
      projects = readprjdirectory;
      prjidx   = ismember(projects.name,prjname);
      prjpath  = [projects.folder{prjidx} filesep prjname filesep];
   end
   
   
% % deprecated by new method that reads the folder in the project directory
%    if nargin == 0
%       prjpath = getenv('MATLABPROJECTPATH');
%    else
%       prjpath = [getenv('MATLABPROJECTPATH') prjname '/'];
%    end
   