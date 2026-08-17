function held = listprojectpath(proj)
   %LISTPROJECTPATH A Project's path entries as a string column.
   %
   %    held = listprojectpath(proj)
   %
   %  Returns the folders the open Project PROJ places on the MATLAB
   %  path, empty when it places none. createMatlabProject and
   %  syncprojectfiles share this so their idempotent path
   %  registration cannot diverge.
   %
   % See also: createMatlabProject, syncprojectfiles, listprojectfiles

   arguments
      proj (1,1) matlab.project.Project
   end

   if isempty(proj.ProjectPath)
      held = strings(0, 1);
   else
      held = string({proj.ProjectPath.File}).';
   end
end
