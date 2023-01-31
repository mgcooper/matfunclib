function prjidx = findprjentry(projects,projectname)
   
   prjidx = ismember(lower(projects.name),lower(projectname));