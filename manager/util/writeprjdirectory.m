function writeprjdirectory(projectlist)

if nargin < 1
   projectlist = readprjdirectory;
end
% get the full path to projectdirectory.mat
projectdirectorypath = getprjdirectorypath();

% temporary backup
tmpfile = gettmpdirectorypath();
copyfile(projectdirectorypath, tmpfile);

% save it
save(projectdirectorypath, 'projectlist')

% % old method that saved the directory as a table
% writetable(projectlist,projectdirectorypath);