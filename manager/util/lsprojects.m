function varargout = lsprojects()
   %LSPROJECTS List projects in MATLABPROJECTPATH.
   %
   % LSPROJECTS() with no inputs lists all projects in MATLABPROJECTPATH. The
   % active project is printed in color.
   %
   % PROJECTLIST = LSPROJECTS() also returns the list of projects.
   %
   % See also: lstoolboxes

   % turn on 'more' pager
   cleanup = onCleanup(@() onCleanupFun());

   projectlist = readprjdirectory;
   projectnames = projectlist.name;
   activeproject = find(projectlist.activeproject);

   more on
   for n = 1:numel(projectnames)
      if n == activeproject
         fprintf(2,'%s%d: %s\n', '--> ', n, projectnames{n});
      else
         fprintf(1,'%s%d: %s\n', '    ', n, projectnames{n});
      end
   end
   if nargout == 1
      varargout{1} = projectlist;
   end
end

function onCleanupFun
   more off
end
