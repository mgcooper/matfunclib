function proj = createhubproject(projectFolder, subprojects, opts)
   %CREATEHUBPROJECT Generate sub-projects, then the hub referencing them.
   %
   %    proj = createhubproject(projectFolder, subprojects)
   %    proj = createhubproject(projectFolder, subprojects, Name, Value)
   %
   % Description
   %
   %  Generates one MATLAB Project for each subfolder in SUBPROJECTS,
   %  then the Project at PROJECTFOLDER that references all of them:
   %  the hub layout, where a repository holds independent libraries
   %  and one root Project ties them together. Opening the hub puts
   %  every sub-project's code on the MATLAB path through its
   %  Referenced Projects.
   %
   %  Generation runs leaves-first because addReference requires a
   %  target that is already an openable Project. Every call converges:
   %  a re-run adds no file and no reference, and a subfolder dropped
   %  from SUBPROJECTS is removed from the hub's reference set.
   %
   %  An open Project closes first. Generation opens each target in
   %  turn, and MATLAB holds one root Project at a time. A call with
   %  the hub already open returns the hub open again.
   %
   %  Each sub-project imports its subfolders and its top-level *.m
   %  files. That puts the sub-project root and every code subfolder on
   %  the Project path. Files inside subfolders are not imported: the
   %  path entry already exposes them. Importing them would grow the
   %  tracked resources/project trees by the repository's whole file
   %  count. The hub imports no source files; it carries the
   %  references.
   %
   % Inputs
   %
   %  PROJECTFOLDER - The hub project root folder (scalar text).
   %
   %  SUBPROJECTS - An N-by-2 string array pairing each subfolder name,
   %  given relative to PROJECTFOLDER, with the Project name to create
   %  it under. MATLAB writes the .prj filename from the Project name,
   %  so CamelCase text there gives a CamelCase .prj filename.
   %
   % Name-value options
   %
   %  projectName - Scalar text for the hub Project name at creation
   %  time. An existing Project keeps its name. The default is the
   %  PROJECTFOLDER folder name.
   %
   %  ignoredSubFolders - Folder names excluded from every sub-project
   %  import wherever they appear, for example scratch trees. Default
   %  empty.
   %
   % Outputs
   %
   %  PROJ - The open hub matlab.project.Project. The caller closes it.
   %
   % See also: createMatlabProject, addprojectrefs, projectfile

   arguments
      projectFolder (1,1) string {mustBeFolder}
      subprojects (:,2) string
      opts.projectName (1,1) string = string(NaN)
      opts.ignoredSubFolders (1,:) string = string.empty()
   end

   % The folders holding this function and the generator it calls,
   % resolved while they are still on the path. The close below can
   % take them off it. They are the only folders worth putting back:
   % the rest belong to the closed Project.
   generatorFolders = [ ...
      string(fileparts(mfilename("fullpath"))); ...
      string(fileparts(which("createMatlabProject")))];
   generatorFolders = unique(generatorFolders(isfolder(generatorFolders)));

   % MATLAB holds one root Project at a time, so opening the first
   % sub-project closes whatever is open. When that is the hub itself
   % (the "open the hub, then regenerate" call), the close lands in the
   % middle of a createMatlabProject call. It takes the generator's own
   % folders with it. Close it here instead, before the loop.
   openroot = matlab.project.rootProject();
   if ~isempty(openroot)
      close(openroot)
      for k = 1:numel(generatorFolders)
         addpath(generatorFolders(k))
      end
   end

   % Closing a Project restores the MATLAB path to its state at the
   % open. That drops every folder the Project managed. A sub-project
   % holding the generator's own code (in matfunclib, manager) would
   % therefore drop createMatlabProject from the path at its close.
   % Every later iteration would then fail. The loop restores this path
   % after each close, which keeps the generator callable. The capture
   % follows the close above, so the closed Project contributes
   % nothing to it.
   entryPath = path();

   % Sub-projects first: addReference opens each target, so a target
   % that is not yet a Project fails the hub's reference pass.
   for k = 1:size(subprojects, 1)
      sub = createMatlabProject( ...
         fullfile(projectFolder, subprojects(k, 1)), ...
         projectName=subprojects(k, 2), ...
         addProjectFiles=true, ...
         addProjectFolders=true, ...
         addChildFiles=false, ...
         ignoredSubFolders=opts.ignoredSubFolders);

      % One Project is open at a time, so close each sub-project before
      % generating the next one and before the hub opens.
      close(sub)
      path(entryPath);
   end

   % The hub: no source files, just the references. Its only members
   % are the root .gitignore and .gitattributes, which createProject
   % records when it creates a Project in a Git worktree; both belong
   % to the repository and must stay. A missing projectName means "use
   % the folder name", which is what createMatlabProject already does,
   % so it is forwarded unchanged.
   proj = createMatlabProject(projectFolder, ...
      projectName=opts.projectName, ...
      subprojects=subprojects(:, 1));
end
