function workon(projectname,varargin)
%WORKON adds project 'projectname' to path and makes it the working directory
%
%
%
%
%
%
%  Updates
%  30 Dec 2022, if Config.m exists in project directory, source it on goto.
%  23 Nov 2022, added support for projects in USERPROJECTPATH in addition to
%  MATLABPROJECPATH by adding it to buildprojectdirectory and adding method from
%  activate.m that reads the folder from projectdirectory to build the
%  projectpath instead of appending projectname to the MATLABPROJECTPATH
%  environment variable

%-------------------------------------------------------------------------------
p                 = inputParser;
p.FunctionName    = 'workon';

addRequired(   p,'projectname',       @(x)ischar(x));
addOptional(   p,'goto',   'goto', @(x)ischar(x));

parse(p,projectname,varargin{:});

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

% commented this out when I added support for sub-libs, since I can just use
% the path entry in the tbdirectory anyway
%prjpath = getprjsourcepath(projectname);
prjpath = [projects.folder{prjidx} filesep projectname];

function onCleanupFun(projectlist)

% this is how I would do it if i always passed projectlist around between
% functions and never allowed it to be written during a function call, only
% written here on cleanup:

writeprjdirectory(projectlist)
