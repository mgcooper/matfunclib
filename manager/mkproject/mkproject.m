function mkproject(projectname, varargin)
   %MKPROJECT Make a new project in MATLABPROJECTPATH.
   %
   %  MKPROJECT(projectname) creates a new default project in
   %  MATLABPROJECTPATH/projectname
   %
   % Description:
   %  mkproject('newproject') Creates a new folder MATLABPROJECTPATH/newproject
   %  if one does not exist. If one does exist, an option to add the folder to
   %  the project directory is presented.
   %
   %  mkproject('newproject', 'maketoolbox', true) Copies the toolbox template
   %  into the new project folder.
   %
   % Matt Cooper, 21-Mar-2023, https://github.com/mgcooper
   %
   % See also: copytoolboxtemplate

   % parse inputs
   [projectname, opts] = parseinputs(projectname, mfilename, varargin{:});

   % Full path to project
   projectpath = fullfile(getenv('MATLABPROJECTPATH'), projectname);

   % Flag to proceed with making the new project or not
   createproject = false;
   forcecopyflag = false;
   safercopyflag = false;

   % Determine if the requested project should be made
   if isfolder(projectpath)
      % project folder exists
      msg = sprintf(['\nproject folder exists in %s,\n' ...
         'press ''y'' to add the project to the project directory or any other key to exit\n'], ...
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
         mkdir(projectpath)
         createproject = true;
      else
         error('project path parent folder does not exist: %s', ...
            fileparts(projectpath));
      end
   end

   % add the new project to the project directory
   if createproject == true

      % if this is a toolbox, copy the template first
      if opts.maketoolbox == true
         copytoolboxtemplate(projectpath, 'forcecopy', forcecopyflag, ...
            'safecopy', safercopyflag);

         % replace the +tbx prefix with +<toolbox_name>
         try
            warning(['replacing +tbx with +%s, this feature is experimental, ' ...
               'suggest checking the codebase and/or running tests before ' ...
               'developing the project further.'], projectname)
            tbx.internal.replacePackagePrefix(projectpath, ...
               'tbx', projectname, false);
         catch e
            rethrow(e)
         end

         % Rename +tbx to +<toolboxname>
         old_tbxpath = fullfile(projectpath, 'toolbox', '+tbx');
         new_tbxpath = fullfile(projectpath, 'toolbox', ['+' projectname]);

         if isfolder(old_tbxpath)
            status = system(['mv ' old_tbxpath ' ' new_tbxpath], "-echo");
         end

      end
      addproject(projectname, 'setfiles', opts.setfiles, 'setactive', opts.setactive);
   end
end

%% input parsing
function [projectname, opts] = parseinputs(projectname, funcname, varargin)

   parser = inputParser;
   parser.FunctionName = funcname;
   parser.addRequired('projectname', @ischar);
   parser.addParameter('setfiles', false, @islogicalscalar);
   parser.addParameter('setactive', false, @islogicalscalar);
   parser.addParameter('maketoolbox', false, @islogicalscalar);
   parser.parse(projectname,varargin{:});

   opts = parser.Results;
   projectname = parser.Results.projectname;
end
