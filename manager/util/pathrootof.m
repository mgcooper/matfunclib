function root = pathrootof(folder)
   %PATHROOTOF The path folder MATLAB resolves a code folder through.
   %
   %    root = pathrootof(folder)
   %
   %  Walks up while the folder is a +package, @class, or private
   %  folder, returning the first ordinary ancestor: the folder that
   %  must be on the MATLAB path for the code inside FOLDER to
   %  resolve. An ordinary folder returns itself.
   %
   %  createMatlabProject applies this to every imported folder and
   %  syncprojectfiles to every imported file's parent, so the two
   %  cannot diverge on what belongs on the Project path.
   %
   % See also: createMatlabProject, syncprojectfiles, listprojectpath

   arguments
      folder (1,1) string
   end

   root = folder;
   [parent, leaf] = fileparts(root);
   while startsWith(leaf, "+") || startsWith(leaf, "@") ...
         || leaf == "private"
      root = string(parent);
      [parent, leaf] = fileparts(root);
   end
end
