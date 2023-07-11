function workon(varargin)
%WORKON adds project `projectname` to path and makes it the working directory
% 
%  workon('myproject') adds paths to myproject, updates the project directory,
%  sets env vars, and cd's to the active project directory. The current active
%  project is deactivated by calling WORKOFF prior to activating MYPROJECT.
% 
%  workon('myproject', 'updatefiles', false) does not update the activefiles
%  list associated with MYPROJECT to the current open files. Default is true,
%  the current open files are saved to the activefiles property for MYPROJECT.
% 
% See also: workoff, manager, addproject
% 
%  Updates
%  30 Jan 2023, only call workoff when switching to a new project
%  16 Jan 2023, save current project activefiles and close before opening new one
%  11 Jan 2023, support for activefiles; added Setup, Install, and Startup to
%  Config source on startup behavior.
%  30 Dec 2022, if Config.m exists in project directory, source it on goto.
%  23 Nov 2022, added support for projects in USERPROJECTPATH in addition to
%  MATLABPROJECPATH by adding it to buildprojectdirectory and adding method from
%  activate.m that reads the folder from projectdirectory to build the
%  projectpath instead of appending projectname to the MATLABPROJECTPATH
%  environment variable

% TODO add if usejava('desktop') methods to not open or save editor files

% note: all setproject** fucntions write the directory, so each time one of
% those is called, writeprjdirectory creates a temporary file. need to stop this

%% parse inputs
[projname, updatefiles, force] = parseinputs(mfilename, varargin{:});

%% main

% check if this is a new project (ie it doesn't exist in the project directory)
ok = verifyprojectexists(projname);

if ok == false; return; end

% If switching projects, close and save the current project. If not, do nothing. 
if strcmpi(projname,getactiveproject('name'))
   % the requested project is the active project (do nothing)
   if force == true 
      % unless force is true (not implemented)
   end
else
   % close and save the current open project before opening the new one
   workoff(getactiveproject(), 'updatefiles', updatefiles);
   % NOTE: if for some reason the active files are closed and workon is called
   % the active file list will be updated and they will be lost, so a backup can
   % be opened and openprojectfiles called first then workon or workoff but
   % better to create option here or some other method thats why i added 'force'
end

% full path to the project activefolder
projpath = getprojectfolder(projname);

% activate 
disp(['activating ' projname]);

% set the active project - NOTE: directory is updated
setprojectactive(projname);

% manage project paths
addprojectpaths(projname);

% cd to the activated tb if requested
try
   cd(projpath)
end

% open project files
openprojectfiles(projname);

% run config, setup, install, or startup scripts if they exist in the top-level
configureproject(projpath);

% realized this isn't needed b/c nothing is updated between setprojectactive and
% here, but if we want to save any prefs or env vars set in configureproject
% then we would need it again
% writeprjdirectory();

% FOR NOW, writeprjdirectory creates a temporary backup
% instead of running writeprjdirectory, use onCleanup to only trigger on success
% cleanup = onCleanup(@()onCleanupFun(projectlist));
% NOTE: implementing this will require never running writeprjdirectory in other
% functions or somehow controlling onCleanup within writeprjdirectory itself and
% therefore passing projectlist back and forth in functions like workon

%% subfunctions

function ok = verifyprojectexists(projname)
ok = true;
if isproject(projname)
   % ok = true
else
   % option to add the project to the directory
   msg = 'project not found in directory, press ''y'' to add it ';
   msg = [msg 'or any other key to return\n'];
   str = input(msg,'s');
   if string(str) == "y"
      addproject(projname);
      % ok = true
   else
      ok = false;
   end
end


function [projname, updatefiles, force] = parseinputs(funcname, varargin)

p = inputParser;
p.FunctionName = funcname;

projectnames = cat(1,cellstr(projectdirectorylist),'default');
validproject = @(x)any(validatestring(x,projectnames));

addOptional(p, 'projectname', getactiveproject, validproject);
addParameter(p, 'updatefiles', true, @islogical);
addParameter(p, 'force', false, @islogical);
parse(p,varargin{:});

projname = p.Results.projectname;
updatefiles = p.Results.updatefiles;
force = p.Results.force;


function onCleanupFun(projectlist)

% this is how I would do it if i always passed projectlist around between
% functions and never allowed it to be written during a function call, only
% written here on cleanup:

writeprjdirectory(projectlist)
