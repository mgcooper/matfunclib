function rmprojectpaths(projpath)
%RMPROJECTPATHS remove all paths in projpath
% 
%     rmprojectpaths(projpath)
% 
% projpath is the full path to the project

% warning off/on suppresses warnings issued when a new folder was
% created in the active toolbox directory and isn't on the path
warning off; rmpath(genpath(projpath)); warning on;

% probably don't want this. instead let workon set the active project
% setenv('ACTIVEPROJECT','default');