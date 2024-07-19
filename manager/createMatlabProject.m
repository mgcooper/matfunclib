function proj = createMatlabProject(projectFolder, addProjectFiles, ...
      addChildFiles, projectSubfolders, projectName, ignoreFolders)
   %CREATEMATLABPROJECT Creates a MATLAB project in the given projectFolder.
   %
   % proj = createMatlabProject(projectFolder, addProjectFiles, addChildFiles,
   %  projectSubfolders, projectName)
   %
   % Inputs
   %
   % projectFolder: String. The parent folder of the project.
   %
   % addProjectFiles: Logical. If true, the function adds all files in the
   % top-level projectFolder to the project.
   %
   % addChildFiles: Logical. If true, the function recursively adds all files
   % in subfolders of projectFolder or projectSubfolders.
   %
   % projectSubfolders: String array. Each string is a subfolder in
   % projectFolder containing project files that will be added to the project.
   % If projectSubfolders is not empty and addChildFiles is true, only files
   % in projectSubfolders are added to the project.
   %
   % projectName: String (Optional). Specifies the .prj filename. If not
   % provided, the name of the projectFolder is used as the projectName.
   %
   % Outputs
   %
   % proj: The MATLAB project object.
   %
   % This function creates a new MATLAB project, adds files from the
   % projectFolder to the project, and recursively adds files from all
   % projectSubfolders if addChildFiles is true. Finally, it updates the
   % dependencies of the project.

   % TODO: use the second output from getProjectFolders subfunction to
   % recursively call addFiles rather than addFolderIncludingChildFiles b/c the
   % latter adds .DS_Store etc. I decided to use addFolderIncludingChildFiles
   % because in projectfile.m, I set addChildFiles true and addProjectFiles
   % false, and pass in 'toolbox' for projectSubfolders, so
   % addFolderIncludingChildFiles gets called on the toolbox folder, and I don't
   % need the second output from getProjectFolders, which is a cleaner file list
   % w/o the .DS_Store etc. Similarly, in the `if addProjectFiles` section, I
   % use dir with *.m, but this doesn't get used if 'toolbox' is passed in for
   % projectSubfolders.

   arguments
      projectFolder (1,1) string {mustBeFolder} = pwd()
      addProjectFiles logical = false
      addChildFiles logical = true
      projectSubfolders (:,1) string = string(NaN)
      projectName string = string(NaN)
      ignoreFolders (1, :) string = ""
   end

   if isempty(projectName) || ismissing(projectName)
      [~, projectName, ~] = fileparts(projectFolder);
      projectName = string(projectName);
   end

   defaultIgnore = [".git",".svn","resources"];
   if isempty(ignoreFolders)
      ignoreFolders = defaultIgnore;
   else
      ignoreFolders = [ignoreFolders, defaultIgnore];
   end

   % % This doesn't work b/c the project name is converted to a valid varname
   % % Check if a project with the same name already exists
   % projectPath = fullfile(projectFolder, projectName + ".prj");
   % if isfile(projectPath)
   %     error("A project with the name '%s' already exists in '%s'.", projectName, projectFolder)
   % end

   % Get a list of all sub-folders to add to the project.
   % This step is performed first because creating the project generates new folders.
   projectSubfolders = getProjectFolders(projectFolder, ...
      projectSubfolders, ignoreFolders);

   % Create a new project
   proj = matlab.project.createProject( ...
      "Name", projectName, "Folder", projectFolder);

   % Add all top-level files
   if addProjectFiles
      projectFiles = dir(fullfile(projectFolder,'*.m'));
      projectFiles = fullfile({projectFiles.folder}', {projectFiles.name}');
      cellfun(@(file) proj.addFile(file), projectFiles);
   end

   % Recursively add all files in all projectSubfolders.
   if addChildFiles
      cellfun(@(folder) ...
         proj.addFolderIncludingChildFiles(folder), projectSubfolders);
   else
      % Add only files in the top-level of each projectSubfolder
      cellfun(@(folder) ...
         proj.addFile(folder), projectSubfolders);
   end

   % Update dependencies
   updateDependencies(proj);
end

function [projectSubfolders, projectFiles] = getProjectFolders( ...
      projectFolder, projectSubfolders, ignoreFolders)
   %GETPROJECTFOLDERS Returns a list of subfolders within projectFolder.
   %
   % projectSubfolders: String array. A list of specific subfolders to be
   % included. If this is empty, all subfolders within projectFolder are
   % returned.
   %
   % The function also excludes certain folders like '.git', '.svn', and
   % 'resources' from the returned list.
   %
   % Note: It returns only the subfolders, and 'addFolderIncludingChildFiles'
   % takes care of adding files from these subfolders to the project.

   % Note: I could return all the files, including the top level projectFolder
   % ones, and use addFile on all of them, but for now, I return the subfolders,
   % and addFolderIncludingChildFiles takes care of recursive files.

   % Get all subfolders
   allSubfolders = rmdotfolders(dir(fullfile(projectFolder, '**/*')));
   allSubfolders = allSubfolders([allSubfolders.isdir]);

   % Remove .git, .svn, and resources folders.
   allSubfolders = allSubfolders(~contains({allSubfolders.folder},ignoreFolders));
   allSubfolders = allSubfolders(~ismember({allSubfolders.name},ignoreFolders));

   % If no subfolders are specified, use all subfolders (except ignored ones).
   if ismissing(projectSubfolders) || isempty(projectSubfolders)
      projectSubfolders = allSubfolders;
   else
      % Use the specified projectSubfolders
      projectSubfolders = allSubfolders( ...
         ismember({allSubfolders.name}, projectSubfolders));
   end

   % Check if specified subfolders are actual subfolders of the projectFolder
   if ~all(startsWith({projectSubfolders.folder}, projectFolder))
      error('All projectSubfolders must be subfolders of projectFolder.')
   end

   % Remove .git, .svn, and resources folders.
   projectSubfolders = projectSubfolders(~contains( ...
      {projectSubfolders.folder}, ignoreFolders));

   projectSubfolders = projectSubfolders(~ismember( ...
      {projectSubfolders.name}, ignoreFolders));

   % Convert from dir struct to full path.
   projectSubfolders = fullfile( ...
      {projectSubfolders.folder}', {projectSubfolders.name}');

   % Get a list of all files in the project folder.
   projectFiles = listfiles(projectSubfolders, "subfolders", true, ...
      "aslist", true, "fullpath", true);
end
