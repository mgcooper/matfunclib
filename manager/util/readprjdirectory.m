function projectlist = readprjdirectory(projectdirectorypath)
   if nargin == 0
      % returns the path to projectdirectory.mat including the filename.
      projectdirectorypath = getprjdirectorypath();
   end
   if isoctave
      load(projectdirectorypath, 'projectstruct'); projectlist = projectstruct;
   else
      load(projectdirectorypath, 'projectlist');
   end
end
   % % old method that saved the directory as a table
   % projects = readtable(prjpath,'Delimiter',',','ReadVariableNames',true);