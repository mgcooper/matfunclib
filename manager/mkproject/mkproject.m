function mkproject(projectname,varargin)
   %MKPROJECT Make a new project in MATLABPROJECTPATH.
   %
   %  MKPROJECT(projectname) creates a new default project in
   %  MATLABPROJECTPATH/projectname
   %
   % Example
   %
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
      end
      addproject(projectname, 'setfiles', opts.setfiles, 'setactive', opts.setactive);
   end
end

%% input parsing
function [projectname, opts] = parseinputs(projectname, funcname, varargin)

   parser = inputParser;
   parser.FunctionName = funcname;
   parser.addRequired('projectname', @ischar);
   parser.addParameter('setfiles', false, @islogical);
   parser.addParameter('setactive', false, @islogical);
   parser.addParameter('maketoolbox', false, @islogical);
   parser.parse(projectname,varargin{:});

   opts = parser.Results;
   projectname = parser.Results.projectname;
end
