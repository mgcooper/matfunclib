function success = mkproject(projectname, varargin)
   %MKPROJECT Make a new project in MATLAB_PROJECTS_PATH.
   %
   %  mkproject(projectname)
   %  success = mkproject(projectname)
   %  success = mkproject(projectname, 'maketoolbox', true)
   %  success = addproject(projectname, 'setfiles', true)
   %  success = addproject(projectname, 'setactive', true)
   %
   % Description
   %
   %  MKPROJECT(PROJECT_NAME) creates the MATLAB_PROJECTS_PATH/PROJECT_NAME
   %  folder if it does not exist, and adds PROJECT_NAME to the project
   %  directory. If the folder already exists, an option to add the folder to
   %  the project directory is presented.
   %
   %  MKPROJECT(PROJECT_NAME, 'MAKETOOLBOX', TRUE) also copies the toolbox
   %  template into the new project folder.
   %
   %  MKPROJECT(PROJECT_NAME, 'SETFILES', TRUE) also sets the activefiles
   %  property in the project directory list to the files open in the Matlab
   %  Editor.
   %
   %  MKPROJECT(PROJECT_NAME, 'SETACTIVE', TRUE) also sets the activeproject
   %  property TRUE in the project directory.
   %
   % Inputs
   %
   %  PROJECT_NAME - (required) scalar text indicating the name of the new
   %  project folder.
   %
   %  MAKETOOLBOX - (optional, name-value) logical scalar to control whether the
   %  toolbox template is copied into the new project folder.
   %
   %  SETFILES - (optional, name-value) logical scalar to control whether the
   %  ACTIVEFILES property (in the project directory) for the new project is set
   %  to the files currently open in the Matlab Editor.
   %
   %  SETACTIVE - (optional, name-value) logical scalar to control whether the
   %  ACTIVEPROJECT property (in the project directory) is set to TRUE for the
   %  new project (make the new project the active project).
   %
   % Outputs
   %  SUCCESS - a struct containing flags indicating if each operation was
   %  successful. Use these to debug why project creation failed.
   %
   % Matt Cooper, 21-Mar-2023, https://github.com/mgcooper
   %
   % See also: copytoolboxtemplate

   % parse inputs
   [projectname, opts] = parseinputs(projectname, mfilename, varargin{:});

   % Full path to project
   projectpath = fullfile(getenv('MATLAB_PROJECTS_PATH'), projectname);

   % Flags to proceed with making the new project or not.
   %
   %  make_project_flag: make a new project (add it to the directory)
   %  make_folder_flag: make the new project folder
   %  add_existing_flag: add an existing project folder to the directory

   make_folder_flag = false;
   make_project_flag = false;
   add_existing_flag = false;

   % Flags indicating successful operations. Set true by default b/c they're
   % only checked in specific cases below.
   success.makefolder = true;
   success.copytoolbox = true;
   success.replaceprefix = false; % if +tbx within files was replaced
   success.movenamespace = false; % if +tbx was moved to +<toolboxname>

   % Keep them for assertions at later steps, in case fieldnames change.
   successflags = fieldnames(success);

   % >>>> NOTE: NO SIDE EFFECTS BETWEEN HERE AND NEXT >>>>

   % Determine if the requested project should be made
   PROJECT_FOLDER_EXISTS = isfolder(projectpath);
   PROJECT_PARENT_EXISTS = isfolder(fileparts(projectpath));

   if PROJECT_FOLDER_EXISTS

      % Ask to add it to the directory and determine if it's empty.
      [PROJECT_FOLDER_NOTEMPTY, ...
         add_existing_flag] = checkProjectPath(projectpath);

   else
      % The project folder does not exist. If the parent folder exists
      % (which should be MATLAB_PROJECTS_PATH), set make_project_flag
      % and make_folder_flag true, since the project folder does not exist.

      if PROJECT_PARENT_EXISTS

         make_project_flag = true;
         make_folder_flag = true;
      else
         error('project parent folder does not exist: %s', ...
            fileparts(projectpath));
      end
   end

   % >>>> NOTE: SIDE EFFECTS BEGIN HERE

   if make_project_flag || add_existing_flag

      % Make a new project or add an existing one to the directory. In either
      % case, the toolbox template can be safely copied to the project folder.

      if make_folder_flag

         status = mkdir(projectpath);

         % If mkdir successful, status == 1 (opposite of system)
         success.makefolder = status == 1;
      end

      % Copy the toolbox template. Do it safely if PROJECT_FOLDER_NOTEMPTY.
      if opts.maketoolbox

         success = copyTemplateToProject(projectpath, projectname, ...
            PROJECT_FOLDER_NOTEMPTY);
      end

      % If there were no failures, add the new project to the directory.
      addProjectToDirectory(projectname, success, opts);
   end

   if opts.createMatlabProject
      createMatlabProject(projectpath, projectname, true, true, true, ...
         string(NaN), "sandbox")
   end

   if ~nargout
      clearvars
   end
end

%% Local Functions

function [FOLDER_NOTEMPTY, add_existing_flag] = checkProjectPath(projectpath)

   % This means projectpath exists. Check if its empty, and prompt if it should
   % be added to the project directory.

   FOLDER_NOTEMPTY = numel(rmdotfolders(dir(projectpath))) > 0;

   msg = sprintf(['\nproject folder exists in %s,\n' ...
      'press ''y'' to add the project to the project directory or ' ...
      'any other key to exit\n'], ...
      projectpath);

   str = input(msg, 's');

   % add the existing project to the project directory
   add_existing_flag = strcmp(str, 'y');
end

function success = copyTemplateToProject( ...
      projectpath, projectname, PROJECT_FOLDER_NOTEMPTY)

   copyinfo = copytoolboxtemplate(projectpath, ...
      'safecopy', PROJECT_FOLDER_NOTEMPTY);

   success.copytoolbox = copyinfo.WAS_COPIED;

   % Try to replace the +tbx prefix with +<toolbox_name>.
   try
      tbx.internal.replacePackagePrefix(projectpath, ...
         'tbx', projectname, false);
      success.replaceprefix = true;
   catch e
      % rethrow(e)
   end

   % Rename +tbx to +<toolboxname>
   old_tbxpath = fullfile(projectpath, 'toolbox', '+tbx');
   new_tbxpath = fullfile(projectpath, 'toolbox', ['+' projectname]);

   if isfolder(old_tbxpath)
      status = system(['mv ' old_tbxpath ' ' new_tbxpath], "-echo");

      success.movenamespace = status == 0;
   end
end

function addProjectToDirectory(projectname, success, opts)

   if all(structfun(@(flag) flag, success))

      addproject(projectname, ...
         'setfiles', opts.setfiles, 'setactive', opts.setactive);
   else
      % Something failed.

      % TODO: Undo what was done. For now, issue a warning and don't add the
      % project otherwise it needs to be undone.
      warning( ...
         ['Project creation failed on one or more steps. Not updating the ' ...
         'project directory. Suggest examining the SUCCESS flags and/or ' ...
         'manually deleting new project folders if they were created.'])
   end

   if success.replaceprefix
      warning( ...
         ['Template prefix +tbx was replaced with +%s in toolbox files. ' ...
         'This feature is experimental. Suggest checking the codebase ' ...
         'and/or running tests before developing the toolbox further.'], ...
         projectname)
   else
      warning( ...
         ['Attempt to replace template prefix +tbx with +%s in toolbox ' ...
         'files failed. This feature is experimental. Suggest replacing ' ...
         'the prefix manually and/or issuing a bug report.'], ...
         projectname)
   end
end
%% input parsing
function [projectname, opts] = parseinputs(projectname, funcname, varargin)

   parser = inputParser;
   parser.FunctionName = funcname;
   parser.addRequired('projectname', @isscalartext);
   parser.addParameter('setfiles', false, @islogicalscalar);
   parser.addParameter('setactive', false, @islogicalscalar);
   parser.addParameter('maketoolbox', false, @islogicalscalar);
   parser.addParameter('createMatlabProject', true, @islogicalscalar);
   parser.parse(projectname,varargin{:});

   opts = parser.Results;
   projectname = char(parser.Results.projectname);
end
