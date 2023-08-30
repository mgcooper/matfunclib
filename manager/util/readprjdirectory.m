function projectlist = readprjdirectory(projectdirectorypath)
if nargin == 0
   projectdirectorypath = getprjdirectorypath(); % path to projectdirectory.mat
end
if isoctave
   load(projectdirectorypath, 'projectstruct'); projectlist = projectstruct;
else
   load(projectdirectorypath, 'projectlist');
end

% % old method that saved the directory as a table
% projects = readtable(prjpath,'Delimiter',',','ReadVariableNames',true);