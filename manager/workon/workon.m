function workon(varargin)
%WORKON adds project `projectname` to path and makes it the working directory
% 
%  workon('myproject') adds paths to myproject, updates the project directory,
%  sets env vars, and cd's to the active project directory
% 
%  workoff('myproject','goto') cd to the MATLABACTIVEPROJECT path
% 
% See also: workoff, manager, addproject
% 
%  Updates
%  16 Jan 2023, save current project activefiles and close before opening new one
%  11 Jan 2023, support for activefiles; added Setup, Install, and Startup to
%  Config source on startup behavior.
%  30 Dec 2022, if Config.m exists in project directory, source it on goto.
%  23 Nov 2022, added support for projects in USERPROJECTPATH in addition to
%  MATLABPROJECPATH by adding it to buildprojectdirectory and adding method from
%  activate.m that reads the folder from projectdirectory to build the
%  projectpath instead of appending projectname to the MATLABPROJECTPATH
%  environment variable

%-------------------------------------------------------------------------------
p              = inputParser;
p.FunctionName = mfilename;

projectnames   = cat(1,cellstr(projectdirectorylist),'default');
validproject   = @(x)any(validatestring(x,projectnames));
validpostopts  = @(x)any(validatestring(x,{'goto'}));

addOptional(   p,'projectname',  getactiveproject, validproject);
addOptional(   p,'postactivate', 'goto',           validpostopts);
addParameter(  p,'force',        false,            @(x)islogical(x));

parse(p,varargin{:});

projname = p.Results.projectname;
postopts = string(p.Results.postactivate) == "goto"; % transform to logical
force = p.Results.force;

% % thought this might permit syntax like workon -f interface but no
% p.PartialMatching = true;
% validpreopts   = @(x)any(validatestring(x,{'force',''}));
% addOptional(   p,'preactivate',  'none',           validpreopts);
% preopts  = p.Results.preactivate;

%-------------------------------------------------------------------------------

% note: all setproject** fucntiosn write the directory, so each time one of
% those is called, writeprjdirectory creates a temporary file. need to stop this

% check if this is a new project (ie it doesn't exist in the project directory)
ok = verifyprojectexists(projname);

if ok == false; return; end

% close and save the current open project
if strcmpi(projname,getactiveproject('name'))
   if force == true
      % continue
   else
      % 30 Jan if workoff is in the else block, it should be fine to run workon
      % for an already active project, it will open the files and configure
      % openprojectfiles();
      % warning('the requested project is already active')
      % return
   end
else
   % 30 Jan moved here so on startup the active project is loaded
   % WARNING: workoff sets the active files  - directory is updated
   workoff(getactiveproject('name'));
end

% ---------------- to not use workoff to prevent resetting the active file list

% didn't finish this but the problem only occurred b/c interface is linked to
% e3sm-offline-mode but to the interface branch and i wanted to switch to the
% icom branch whihc won't work with workon/workoff so i have todo a custom thing
% whrre i keep interface checked out, do workoff, then do workon ... but the
% problem is that will update the activefiles list to empty, so i hae to just do
% the workon then checkout icom branch and missing files won't open but I can do
% it manually 

% % deactivate the active project
% disp(['deactivating ' getactiveproject('name')]);
% 
% % full path to project folder
% projpath = getprojectfolder(projname); % use 'namespace' for old behavior


% ----------------

% NOTE: if for some reason the active files are closed and workon is called the
% active file list will be updated and they will be lost, so a backup can be
% opened and openprojectfiles called first then workon or workoff but better to
% create option here or some other method thats why i added 'force' 

% % 30 Jan moved this up to else
% % WARNING: workoff sets the active files  - directory is updated
% workoff(getactiveproject('name'));

% full path to the project activefolder
projpath = getprojectfolder(projname);
% projpath = getprojectfolder(projname,'activefolder');
% old method: (to replicate, use: getprojectfolder(projname,'namespace') )
% projpath = fullfile(projlist.folder{projindx},projname);

% activate 
disp(['activating ' projname]);

% set the active project - NOTE: directory is updated
setprojectactive(projname);

% manage project paths
addprojectpaths(projname);

% cd to the activated tb if requested
if postopts; cd(projpath); end

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

%-------------------------------------------------------------------------------
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
      return;
   end
end

%-------------------------------------------------------------------------------

% this is how I would do it if i always passed projectlist around between
% functions and never allowed it to be written during a function call, only
% written here on cleanup:
function onCleanupFun(projectlist)
writeprjdirectory(projectlist)
