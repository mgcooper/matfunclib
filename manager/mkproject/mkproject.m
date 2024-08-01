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

   % Flag to proceed with making the new project or not
   createproject = false;
   forcecopyflag = false;
   safercopyflag = false;

   % Flags indicating successful operations
   success.createproject = true;
   success.copytoolbox = true;
   success.replaceprefix = true; % replacing +tbx within files
   success.movenamespace = true; % moving +tbx to +<toolboxname>

   % >>>> NOTE: NO SIDE EFFECTS BETWEEN HERE AND NEXT >>>>

   % Determine if the requested project should be made
   if isfolder(projectpath)
      % project folder exists
      createfolder = false;

      msg = sprintf(['\nproject folder exists in %s,\n' ...
         'press ''y'' to add the project to the project directory or ' ...
         'any other key to exit\n'], ...
         projectpath);
      str = input(msg,'s');

      if string(str) == "y"
         % add the existing project to the project directory
         createproject = true;
      end

      if numel(rmdotfolders(dir(projectpath))) > 0
         % existing folder is not empty
         safercopyflag = true;
      else
         forcecopyflag = true;
      end
   else
      if isfolder(fileparts(projectpath))
         createproject = true;
         createfolder = true;
      else
         error('project path parent folder does not exist: %s', ...
            fileparts(projectpath));
      end
   end

   % >>>> NOTE: SIDE EFFECTS BEGIN HERE

   % Add the new project to the project directory.
   if createproject

      % If the project folder does not exist, create it.
      if createfolder
         status = mkdir(projectpath);

         % If the mv was successful, status == 1 (opposite of system)
         success.createproject = status == 1;
      end

      % if this is a toolbox, copy the template first
      if opts.maketoolbox

         copyinfo = copytoolboxtemplate(projectpath, ...
            'forcecopy', forcecopyflag, ...
            'safecopy', safercopyflag);

         success.copytoolbox = copyinfo.WAS_COPIED;

         % Try to replace the +tbx prefix with +<toolbox_name>.
         try
            tbx.internal.replacePackagePrefix(projectpath, ...
               'tbx', projectname, false);
         catch e
            % rethrow(e)
            success.replaceprefix = false;
         end

         % Rename +tbx to +<toolboxname>
         old_tbxpath = fullfile(projectpath, 'toolbox', '+tbx');
         new_tbxpath = fullfile(projectpath, 'toolbox', ['+' projectname]);

         if isfolder(old_tbxpath)
            status = system(['mv ' old_tbxpath ' ' new_tbxpath], "-echo");

            success.movenamespace = status == 0;
         else
            success.movenamespace = false;
         end
      end

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

   if ~nargout
      clearvars
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
   parser.parse(projectname,varargin{:});

   opts = parser.Results;
   projectname = char(parser.Results.projectname);
end
