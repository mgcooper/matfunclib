function addprojectpaths(projectname)
%ADDPROJECTPATHS add all paths in projectpath
% 
%     addprojectpaths(projectname)
% 
%     addprojectpaths(projectpath)
% 
% projectpath is the full path to the project

% 26 Jan 2023 hack to get path from project name rather than full path
if nargin < 1
   projectname = getactiveproject();
end

if isfolder(projectname)
   projectpath = projectname;
else
   projectpath = getprojectfolder(projectname);
end

addpath(genpath(projectpath));
% remove .git files from path
if contains(genpath(fullfile(projectpath,'.git')),'.git')
   warning off; rmpath(genpath(fullfile(projectpath,'.git'))); warning on;
end