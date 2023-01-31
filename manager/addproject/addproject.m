function projlist = addproject(projectname,varargin)
%ADDPROJECT add project to project directory
%
%
%
%
%
%
%  Updates
%  23 Nov 2022 added support for USERPROJECTPATH by adding it to
%  buildprojectdirectory and adding method from activate.m to workon.m that
%  reads the folder from projectdirectory instead of appending projectname to
%  the MATLABPROJECTPATH environment variable

%-------------------------------------------------------------------------------
p                 = inputParser;
p.FunctionName    = mfilename;
p.CaseSensitive   = false;
p.KeepUnmatched   = true;

addRequired(p,'projectname',@(x)ischar(x));
addOptional(p,'workon','',@(x)ischar(x));

parse(p,projectname,varargin{:});
projname = p.Results.projectname;
workon   = p.Results.workon;

% Updates
% 11 Jan 2023: added support for activefile list, see buildprojectdirectory.
% 11 Jan 2023: removed addtojsondirectory in favor of new
% choices=projectdirectorylist option in json files
%-------------------------------------------------------------------------------

% NOTE: getprjsourcpath is more like 'buildprjsourcepath' - it builds the path,
% it doesn't check if it alredy exists, like I do below with any(ismember)
projlist = readprjdirectory(getprjdirectorypath); % read the project directory
projpath = getprjsourcepath(projname); % get the full path to the project

if any(ismember(projlist.name,projname))
   
   msg = ['project already in directory, press ''y'' to add to json signature ' ...
      'file or any other key to return\n'];
   str = input(msg,'s');
   if string(str) ~= "y"
      return
   end
end

disp(['adding ' projname ' to project directory']);

% rebuild the project directory
buildprojectdirectory('rebuild');

% read the project directory into memory
projlist = readprjdirectory(getprjdirectorypath);
projindx = getprjidx(projname,projlist);

% % commented these out - json files use projectdirectorylist instead
% % add it to the json directory choices for function 'workon'
% addtojsondirectory(projlist,projindx,'workon');
% 
% % repeat for 'workoff'
% addtojsondirectory(projlist,projindx,'workoff');

% activate the toolbox if requested
if string(workon)=="workon"
   workon(projname);
end


function addtojsondirectory(projects,prjidx,directoryname)

% 23 Nov 2022 - use choices={ for prjfind to append new projects rather than
% searching for the last entry using prjidx-1

jspath      = getprjjsonpath(directoryname);
wholefile   = readprjjsonfile(jspath);

% append the new project to the choices array:
prjfind     = sprintf('%s','choices={');
prjreplace  = sprintf('%s''%s'',',prjfind,projects.name{prjidx});
wholefile   = strrep(wholefile,prjfind,prjreplace);

% write it over again
writeprjjsonfile(jspath,wholefile)

% method that replaced the most recent entry with itself + the new one:
%prjfind     = sprintf('''%s''',projects.name{prjidx-1});
%prjreplace  = sprintf('%s,''%s''',prjfind,projects.name{prjidx});







