function proj = projectfile(buildOption, projectName, codeFolders, opts)
   %PROJECTFILE File to create a matlab project.
   %
   % proj = projectfile('MyProject', 'toolbox') creates a new project called
   % MyProject.prj and adds all files in the toolbox/ directory to the project.
   % Files in the top level directory are not added to the project.
   %
   % list = projectfile('listfiles') returns the open project's file
   % list as a string column (requires an open MATLAB Project; untested
   % in the template suite for that reason).
   %
   % Note: dependency vendoring is not this function's job. Declare
   % dependencies in mproject.toml and vendor files for release with
   % tbx.internal.installRequiredFiles (the template's one dependency
   % mechanism; see the matfunclib redesign DesignSpec, decision 4).
   %
   % See also: buildfile, setupfile

   % Define the options to add folders and files

   % Parse the option
   arguments(Input)

      buildOption (1,:) string {mustBeMember(buildOption, ...
         ["create", "delete", "update", "listfiles"])} ...
         = "create"

      projectName (1,1) string ...
         = string(NaN)

      codeFolders (:,1) string ...
         = string(NaN)

      opts.addCodeFiles (1,1) logical ...
         = true

      opts.addProjectFiles (1,1) logical ...
         = false

      opts.ignoreFolders (:,1) string ...
         = ["sandbox", "testbed"]
   end

   % Define the main project folder. This file lives at the project
   % root, beside buildfile and releasefile.
   projectFolder = fileparts(mfilename('fullpath'));

   % Define the project name. fileparts treats a dot in a folder name
   % as an extension separator, so rejoin the parts to keep dotted
   % folder names whole.
   if ismissing(projectName)
      [~, folderBase, folderExt] = fileparts(projectFolder);
      projectName = string(folderBase) + string(folderExt);
   end

   switch buildOption

      case 'delete'
         % Delete the project. An open Project must close before
         % deleteProject can remove it.
         % TODO: Add warning with user input "y" or "n".
         try
            close(currentProject);
            matlab.project.deleteProject(projectFolder);
         catch
         end
         return

      case 'create'
         % Define the sub folders to add to the project
         codeFolders = parseCodeFolders(codeFolders, projectFolder, ...
            projectName, buildOption, mfilename);

         % The subfolder filter only applies when the code import is
         % enabled; with addCodeFiles=false nothing below the root is
         % imported, so no filter is passed.
         if opts.addCodeFiles
            subfolders = codeFolders;
         else
            subfolders = string.empty();
         end

         % Create (or converge) the project through the manager
         % generator's name-value interface.
         proj = createMatlabProject(projectFolder, ...
            projectName=projectName, ...
            addProjectFiles=opts.addProjectFiles, ...
            addProjectFolders=opts.addCodeFiles, ...
            addChildFiles=opts.addCodeFiles, ...
            projectSubfolders=subfolders, ...
            ignoredSubFolders=opts.ignoreFolders(:).');

      case 'listfiles'
         % This should probably be an internal function or in a new namespace
         % convention such as +project but put here for now.
         proj = currentProject;
         proj = [proj.Files.Path].';
   end
end

%% subfunctions
function codeFolders = parseCodeFolders(codeFolders, projectFolder, ...
      projectName, buildOption, mfilename)

   if ismissing(codeFolders)

      if isfolder(fullfile(projectFolder, 'toolbox'))
         codeFolders = "toolbox";
      else
         eid = ['custom:' mfilename ':CodeFolderMissingOrNotFound'];
         msg = ['No codeFolder specified. Default toolbox/ folder not found.' ...
            newline 'To specify which folders to add to the project, try:' ...
            newline '   projectfile("' char(buildOption) '", "' ...
            char(projectName) '", codeFolder)'];
         error(eid, msg)
      end
   end
end
