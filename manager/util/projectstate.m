function state = projectstate(folder)
   %PROJECTSTATE Classify a folder's MATLAB Project state.
   %
   %    state = projectstate(folder)
   %
   % Description
   %
   %  Returns one of four states, from folder existence and the two
   %  on-disk markers a MATLAB Project has (a root .prj file and the
   %  resources/project tree):
   %
   %    "missing"  - the folder does not exist (for example a project
   %                 directory entry whose folder was deleted or
   %                 moved).
   %    "project"  - both markers present; openProject can open it.
   %    "none"     - neither marker present; createProject can create it.
   %    "orphaned" - one marker without the other. openProject fails on
   %                 such a folder, so a caller must not treat it as a
   %                 Project, and creating over it risks mixing stale
   %                 state into the new Project. Repair means deleting
   %                 the stale marker and regenerating.
   %
   %  createMatlabProject and addprojectrefs share this check so a
   %  broken folder is reported the same way at creation time and at
   %  reference-validation time.
   %
   % See also: createMatlabProject, addprojectrefs

   arguments
      folder (1,1) string
   end

   % A validator would throw here and rob callers of their own
   % diagnostic for stale directory entries, so absence is a state.
   if ~isfolder(folder)
      state = "missing";
      return
   end

   % The two markers: any root .prj file, and the resources/project
   % tree createProject writes.
   hasprj = ~isempty(dir(fullfile(folder, "*.prj")));
   hasresources = isfolder(fullfile(folder, "resources", "project"));

   if hasprj && hasresources
      state = "project";
   elseif ~hasprj && ~hasresources
      state = "none";
   else
      state = "orphaned";
   end
end
