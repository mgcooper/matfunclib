function setprojectlinked(projectname,linkedprojectname)
   %SETPROJECTLINKED link project to another one
   %
   %  setprojectlinked(projectname, linkedprojectname) sets the
   %  projectlist.linkedproject attribute for projectname to linkedprojectname
   %  and the projectlist.activefolder attribute to the activefolder of the
   %  linked project.
   %
   % See also

   % Note this is not called by any functions. If it is later added, pay
   % attention to how the activefiles are updated. The main purpose is to link
   % the activefolder so the desired folder is activated with workon, not to
   % override the active files

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
end
