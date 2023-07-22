function addprojectpaths(projectname)
%ADDPROJECTPATHS add all project paths to path
% 
%     addprojectpaths(projectname)
%     addprojectpaths(projectpath)
% 
% projectpath is the full path to the project
% 
% See also: workon, workoff

% default option to use the active project
if nargin < 1
   try
      projectname = getactiveproject();
   catch
      error('manager:addpath:noActiveProject', 'no active project found')
   end
end

if isfolder(projectname)
   projectpath = projectname;
else
   projectpath = getprojectfolder(projectname);
end

% add the paths
try
   % use pathadd if its on the path
   pathadd(projectpath);
catch ME
   % use built-ins
   addpath(genpath(projectpath),'-end');
   % remove .git files from path
   try
      rmpath(genpath(fullfile(projectpath,'.git')));
      rmpath(genpath(fullfile(projectpath,'.svn')));
   catch
   end
end