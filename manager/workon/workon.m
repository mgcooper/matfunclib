function workon(varargin)
   %WORKON Add project to path and make it the working directory.
   %
   %    workon(projectname)
   %    workon(projectname, 'updatefiles', false)
   %
   %  Description
   %
   %    WORKON(PROJECTNAME) first calls WORKOFF to update the active files and
   %    deactivate the current active project, then activates PROJECTNAME. When
   %    PROJECTNAME is activated, WORKON changes the current working directory
   %    to the project root directory, adds project paths to the matlab path,
   %    opens the project files, calls CONFIGUREPROJECT to source config and/or
   %    setup hooks, and rewrites the project directory after creating a backup.
   %
   %    WORKON(PROJECTNAME, 'UPDATEFILES', FALSE) does not update the active
   %    files list when calling WORKOFF to deactivate the current active project
   %    prior to activating PROJECTNAME. Use UPDATEFILES=FALSE to retain the
   %    active files list when switching projects, ignoring any new files opened
   %    during the current session. If UPDATEFILES=TRUE (the default behavior),
   %    a list of all files currently open in the the matlab editor is saved to
   %    the 'activefiles' field in the project directory prior to deactivating
   %    the current active project. If PROJECTNAME is the current active project
   %    and UPDATEFILES=TRUE, the active files for PROJECTNAME are updated. The
   %    default option is TRUE.
   %
   %  See also: workoff, manager, addproject
   %
   %  Updates
   %
   %  - 25 Jul 2024, replaced USERPROJECTPATH with MATLAB_PROJECTS_PATH. Note
   %    this is not used in this function.
   %  - 30 Jan 2023, only call workoff when switching to a new project.
   %  - 16 Jan 2023, save current project activefiles and close before opening
   %    new one.
   %  - 11 Jan 2023, support for activefiles; added Setup, Install, and Startup
   %    to Config source on startup behavior.
   %  - 30 Dec 2022, if Config.m exists in project directory, source it on goto.
   %  - 23 Nov 2022, added support for projects in USERPROJECTPATH in addition
   %    to MATLABPROJECPATH by adding it to buildprojectdirectory and adding
   %    method from activate.m that reads the folder from projectdirectory to
   %    build the projectpath instead of appending projectname to the
   %    MATLABPROJECTPATH environment variable.
   %
   % TODO
   % - add if usejava('desktop') methods to not open or save editor files
   % - add a "writedirectory" flag to all functions, pass the updated
   %   projectlist back and forth, only writing it when necessary. Currently,
   %   all setproject** fucntions write the directory, so each time one of those
   %   is called, writeprjdirectory creates a backup.

   % Parse inputs.
   [projname, updatefiles] = parseinputs(mfilename, varargin{:});

   % Check if the project exists, or add a new project to the directory.
   if ~verifyproject(projname)
      return
   end

   % Check if the requested project is currently active.
   if strcmpi(projname, getactiveproject('name'))
      if updatefiles
         % Update the active files for the current project.
         setprojectfiles(projname);
      end
   else
      % Close and save the current open project before opening the new one.
      workoff(getactiveproject(), 'updatefiles', updatefiles);

      % Note: If for some reason the active files are closed and workon is
      % called the active files list will be updated and they will be lost. To
      % recover them, open a backup and pass the files to reopenfiles, then
      % either call setprojectfiles or workon('updatefiles', true).
   end

   % Full path to the project activefolder.
   projpath = getprojectfolder(projname);

   % Activate.
   disp(['activating ' projname]);

   % Set the active project - NOTE: directory is updated.
   setprojectactive(projname);

   % Manage project paths.
   addprojectpaths(projname);

   % cd to the activated tb if requested
   try
      cd(projpath)
   catch
   end

   % Open project files
   openprojectfiles(projname);

   % Run config, setup, install, or startup scripts if they exist in userhooks/
   configureproject(projpath);

   % FOR NOW, writeprjdirectory creates a temporary backup instead of running
   % writeprjdirectory, use onCleanup to only trigger on success
   %
   % cleanup = onCleanup(@() onCleanupFun(projectlist));
   %
   % NOTE: implementing this will require never running writeprjdirectory in
   % other functions or somehow controlling onCleanup within writeprjdirectory
   % itself and therefore passing projectlist back and forth in functions like
   % workon.
end

%% INPUT PARSER
function [projname, updatefiles, force] = parseinputs(funcname, varargin)

   parser = inputParser;
   parser.FunctionName = funcname;
   parser.addOptional('projectname', getactiveproject(), @validateProjectName);
   parser.addParameter('updatefiles', true, @islogicalscalar);
   parser.addParameter('force', false, @islogicalscalar);
   parser.parse(varargin{:});

   projname = char(parser.Results.projectname);
   updatefiles = parser.Results.updatefiles;
   force = parser.Results.force;
end

function onCleanupFun(projectlist) %#ok<*DEFNU>
   % this is how I would do it if i always passed projectlist around between
   % functions and never allowed it to be written during a function call, only
   % written here on cleanup:
   writeprjdirectory(projectlist)
end
