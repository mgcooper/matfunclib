function openprojectfiles(projectname, activefiles)
   %OPENPROJECTFILES open project files
   %
   % Note:

   % TODO: I added activefiles second input so this does not rely on
   % getprojectfiles having access to the updated file list while
   % activating/deactivating ... to complete, need to add activefiles and/or
   % a writedirectory logical flag to all involved functions and then do the
   % final write step in workon/workoff.

   if nargin < 1
      projectname = getactiveproject();
   end

   if nargin < 2
      activefiles = getprojectfiles(projectname);
   end

   % Open the project files (skipping those which are already open).
   if ~isempty(activefiles)
      openfiles = getopenfiles();
      activefiles = activefiles(~ismember(activefiles, openfiles));
      reopenfiles(activefiles);
   end
end
