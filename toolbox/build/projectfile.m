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

   % Define the main project folder
   projectFolder = fileparts(mfilename('fullpath'));

   % Define the project name
   if ismissing(projectName)
      [~, projectName] = fileparts(projectFolder);
   end

   switch buildOption

      case 'delete'
         % Delete the project
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

         % Create the project
         proj = createMatlabProject(projectFolder, opts.addProjectFiles, ...
            opts.addCodeFiles, codeFolders, projectName, opts.ignoreFolders);

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
%%
%%
% Dormant alternative validator, kept as commented code. To use it, add
% this back to the arguments block:
%   buildOption (1, 1) char {mustBeValidOption(buildOption)} = 'create'
%
% function mustBeValidOption(option)
%    % Test for membership in list
%    validopts = {'create', 'delete', 'update'};
%    if ~ismember(option, validopts)
%       eid = 'Option:notValid';
%       msg = 'Input option must be ''add'' or ''multiply''.';
%       throwAsCaller(MException(eid,msg))
%    end
% end
% This is from teh delete project section. It is based on my initial attempts to
% create a project programmatically in icom-msd project create_matlab_project
% script where I had to close it first b/c I had just created it, but I am not
% acutally sure it has to be closed.
%    try
%       projectRootFolder = currentProject().RootFolder;
%    catch e
%       if strcmp(e.message, 'No project is currently loaded.')
%          openProject(projectFolder)
%          projectRootFolder = currentProject().RootFolder;
%       end
%    end
%    close(currentProject); matlab.project.deleteProject(projectRootFolder);
%    return
