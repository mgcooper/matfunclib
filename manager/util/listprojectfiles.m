function files = listprojectfiles(proj)
   %LISTPROJECTFILES A Project's current file set as a string column.
   %
   %    files = listprojectfiles(proj)
   %
   %  Returns the full paths of every file and folder the open Project
   %  PROJ tracks, as a string column, empty when the Project tracks
   %  nothing. createMatlabProject and syncprojectfiles share this so
   %  their membership checks cannot diverge.
   %
   % See also: createMatlabProject, syncprojectfiles

   arguments
      proj (1,1) matlab.project.Project
   end

   if isempty(proj.Files)
      files = strings(0, 1);
   else
      files = string({proj.Files.Path}).';
   end
end
