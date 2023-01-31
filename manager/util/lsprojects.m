function lsprojects
projectlist = readprjdirectory;
projectnames = projectlist.name;
activeproject = find(projectlist.activeproject);

for n = 1:numel(projectnames)
   if n == activeproject
      fprintf(2,'%s%d: %s\n', '--> ', n, projectnames{n});
   else
      fprintf(1,'%s%d: %s\n', '    ', n, projectnames{n});
   end
end