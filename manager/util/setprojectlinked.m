function setprojectlinked(projectname,linkedprojectname)
%SETPROJECTLINKED link project to another one
% 
%  setprojectlinked(projectname, linkedprojectname) sets the
%  projectlist.linkedproject attribute for projectname to linkedprojectname and
%  the projectlist.activefolder attribute to the activefolder of the linked
%  project.
% 
% See also

% Note this is not called by any functions. 

projlist = readprjdirectory();
if nargin == 1
   projectname = getactiveproject();
end
activeidx = getprjidx(projectname);
linkedidx = getprjidx(linkedprojectname);

% set the linkedproject attribute
projlist.linkedproject(activeidx) = projlist.name(linkedidx);
projlist.activefolder(activeidx) = projlist.activefolder(linkedidx);
writeprjdirectory(projlist);