function activefiles = getprojectfiles(projectname,projectlist)
   %GETPROJECTFILES get the list of active project files
   %
   % activefiles = getprojectfiles(projectname,projectlist)
   % 
   % See also: getactiveproject, setprojectfiles

   if nargin < 2
      projectlist = readprjdirectory();
      if nargin < 1
         projectname = getactiveproject();
      end
   end
   activefiles = projectlist.activefiles{getprjidx(projectname,projectlist)};
end