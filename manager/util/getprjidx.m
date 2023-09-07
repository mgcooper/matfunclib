function prjidx = getprjidx(projectname, projectlist)
   %GETPRJIDX Get the project index in the projectlist directory table.

   if nargin == 1
      projectlist = readprjdirectory();
   end
   if isoctave
      prjidx = ismember(lower({projectlist.name}), lower(projectname));
   else
      prjidx = ismember(lower(projectlist.name), lower(projectname));
   end
end
