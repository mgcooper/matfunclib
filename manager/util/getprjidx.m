function prjidx = getprjidx(projectname,projectlist)
%GETPRJIDX get the index of the project specified by `projectname` in the
%projectlist directory table.

if nargin == 1
   projectlist = readprjdirectory;
end
if isoctave
   prjidx = ismember(lower({projectlist.name}),lower(projectname));
else
   prjidx = ismember(lower(projectlist.name),lower(projectname));
end

