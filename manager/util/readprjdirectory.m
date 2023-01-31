function projectlist = readprjdirectory(projectdirectorypath)
if nargin == 0
   projectdirectorypath = getprjdirectorypath; % path to projectdirectory.mat
end
load(projectdirectorypath,'projectlist');

% % old method that saved the directory as a table
% projects = readtable(prjpath,'Delimiter',',','ReadVariableNames',true);