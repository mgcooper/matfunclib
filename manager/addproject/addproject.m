function varargout = addproject(projectname,varargin)
   %ADDPROJECT Add project to project directory.
   %
   %  ADDPROJECT(PROJECTNAME) Adds a new project with name PROJECTNAME to the
   %  project directory.
   %
   %  ADDPROJECT(PROJECTNAME, 'SETFILES', TRUE) Sets the activefiles property of
   %  the project directory list for the project to the files open in the Matlab
   %  Editor.
   %
   %  ADDPROJECT(PROJECTNAME, 'SETACTIVE', TRUE) Sets the activeproject property
   %  of the project directory list for the project true.
   %
   %  PROJECTLIST = ADDPROJECT(PROJECTNAME, _) Also returns the project
   %  directory list.
   %
   %  Note: This "adds" the project by calling rebuildprojectdirectory,
   %  therefore the project must exist as a folder in the project path. See
   %  mkproject to create a new project.
   %
   %  Updates
   %  21 Mar 2023: added setfiles and setactive following mkproject
   %  11 Jan 2023: added support for activefile list, see buildprojectdirectory.
   %  11 Jan 2023: removed addtojsondirectory in favor of new
   %  choices=projectdirectorylist option in json files
   %  23 Nov 2022 added support for USERPROJECTPATH by adding it to
   %  buildprojectdirectory and adding method from activate.m to workon.m that
   %  reads the folder from projectdirectory instead of appending projectname to
   %  the MATLABPROJECTPATH environment variable
   %
   % See also: rmproject, mkproject, workon, workoff

   % NOTE common use case, a project is active but you want to make it another
   % project or branch off to another project without updating the active project
   % file list which would happen with workon/workoff, e.g.
   % addproject('exactremap','setfiles',true,'setactive',true) effectively makes
   % this the active project without updating the activefiles property of the
   % active project

   % Parse inputs.
   [projectname, opts] = parseinputs(projectname, mfilename, varargin{:});

   % Read the project directory.
   projectlist = readprjdirectory(getprjdirectorypath);

   % Check if the project exists already.
   if any(ismember(projectlist.name, projectname))
      msg = ['project already in directory, press ''y'' to add to rebuild project ' ...
         'directory or any other key to return\n'];
      str = input(msg,'s');
      if string(str) ~= "y"
         return
      end
   end
   disp(['adding ' projectname ' to project directory']);

   % Rebuild the project directory
   buildprojectdirectory('rebuild');

   % Read the project directory into memory
   projectlist = readprjdirectory(getprjdirectorypath);

   % post hooks
   if opts.setfiles
      setprojectfiles(projectname);
   end

   if opts.setactive
      setprojectactive(projectname)
   end

   if nargout == 1
      varargout{1} = projectlist;
   end
end

%% input parsing
function [projectname, opts] = parseinputs(projectname, funcname, varargin)
   parser = inputParser;
   parser.FunctionName = funcname;
   parser.addRequired('projectname', @ischar);
   parser.addParameter('setfiles', false, @islogicalscalar);
   parser.addParameter('setactive', false, @islogicalscalar);
   parser.parse(projectname, varargin{:});
   opts = parser.Results;
end

% % No longer used, but keep for reference.
% function addtojsondirectory(projects,prjidx,directoryname)
%
%    % 23 Nov 2022 - use choices={ for prjfind to append new projects rather than
%    % searching for the last entry using prjidx-1
%
%    jspath      = getprjjsonpath(directoryname);
%    wholefile   = readprjjsonfile(jspath);
%
%    % append the new project to the choices array:
%    prjfind     = sprintf('%s','choices={');
%    prjreplace  = sprintf('%s''%s'',',prjfind,projects.name{prjidx});
%    wholefile   = strrep(wholefile,prjfind,prjreplace);
%
%    % write it over again
%    writeprjjsonfile(jspath,wholefile)
%
%    % method that replaced the most recent entry with itself + the new one:
%    %prjfind     = sprintf('''%s''',projects.name{prjidx-1});
%    %prjreplace  = sprintf('%s,''%s''',prjfind,projects.name{prjidx});
% end
