function workoff(varargin)
   %WORKOFF Deactivate project and (optionally) update activefiles.
   %
   %  WORKOFF(PROJECTNAME) removes project paths, unsets env vars, updates the
   %  activefiles property of the projectdirectory to the currently open files,
   %  and sets the 'default' project active.
   %
   %  WORKOFF(PROJECTNAME,'UPDATEFILES', FALSE) does not update the activefiles
   %  list associated with MYPROJECT to the current open files. Default is true,
   %  the current open files are saved to the activefiles property for
   %  MYPROJECT.
   %
   % See also: workon, manager, addproject

   % TODO: save open variables in struct then save as .mat file, save open
   % figures, and save help docs? couldn't find a built in or fex method but see
   % gethelpdoclink, it gets the active one.

   % problematic behavior: workoff updates activefiles but not activeproject
   % - call workoff during session
   % - activefiles are updated and closed, but activeproject is not
   % - close matlab
   % - finish.m calls workoff
   % - workoff sets the activeproject activefiles to the files open in the
   % editor, which are not the files for the activeproject
   %
   % To fix this, workoff sets the activeproject to 'default', which is the
   % right method, but it is still problematic to call workoff from finish.m,
   % here's why:
   % - close matlab
   % - finish.m calls workoff
   % - workoff updates the activefiles and sets the activeproject to 'default'
   % - reopen matlab
   % - startup.m calls workon
   % - workon

   % parse inputs
   [projname, updatefiles] = parseinputs(mfilename, varargin{:});

   % deactivate the project
   disp(['deactivating ' projname]);

   try
      close(currentProject);
   catch
   end

   % update the active file list
   if updatefiles == true
      setprojectfiles(projname);
   end

   % close all currently open files
   closeopenfiles();

   % if this is not the default project, remove the project paths
   if ~strcmpi(projname,'default')

      % full path to project folder
      projpath = getprojectfolder(projname); % use 'namespace' for old behavior

      % remove project paths
      rmprojectpaths(projpath);
   end

   % unset the active project
   setprojectactive('default');
end

%% subfunctions

function [projname, updatefiles] = parseinputs(funcname, varargin)
   parser = inputParser;
   parser.FunctionName = funcname;

   projectnames = cat(1,cellstr(projectdirectorylist),'default');
   validproject = @(x)any(validatestring(x,projectnames));

   parser.addOptional('projectname',getactiveproject,validproject);
   parser.addParameter('updatefiles',true,@islogical);
   parser.parse(varargin{:});

   projname = parser.Results.projectname;
   updatefiles = parser.Results.updatefiles;
end
