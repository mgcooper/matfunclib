function varargout = addproject(projectname,varargin)
%ADDPROJECT add project to project directory
%
%
%
%
%
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

% NOTE common use case, a project is active but you want to make it another
% project or branch off to another project without updating the active project
% file list which would happen with workon/workoff, e.g.
% addproject('exactremap','setfiles',true,'setactive',true) effectively makes
% this the active project without updating the activefiles property of the
% active project

%% parse inputs

[projectname, setfiles, setactive] = parseinputs( projectname, ...
   mfilename, varargin{:});

%% main
projectlist = readprjdirectory(getprjdirectorypath); % read the project directory
projectpath = fullfile(getenv('MATLABPROJECTPATH'),projectname);

if any(ismember(projectlist.name,projectname))
   
   msg = ['project already in directory, press ''y'' to add to rebuild project ' ...
      'directory or any other key to return\n'];
   str = input(msg,'s');
   if string(str) ~= "y"
      return
   end
end

disp(['adding ' projectname ' to project directory']);

% rebuild the project directory
buildprojectdirectory('rebuild');

% read the project directory into memory
projectlist = readprjdirectory(getprjdirectorypath);
projindx = getprjidx(projectname,projectlist);

% % commented these out - json files use projectdirectorylist instead
% % add it to the json directory choices for function 'workon'
% addtojsondirectory(projlist,projindx,'workon');
% 
% % repeat for 'workoff'
% addtojsondirectory(projlist,projindx,'workoff');

% post mk options
if setfiles
   setprojectfiles(projectname);
end

if setactive
   setprojectactive(projectname)
end

if nargout == 1
   varargout{1} = projectlist;
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


%% input parsing
function [projectname,setfiles,setactive] = parseinputs(projectname, ...
   funcname, varargin)

p = inputParser;
p.FunctionName = funcname;
p.CaseSensitive = false;
p.KeepUnmatched = true;

addRequired(p,'projectname',@ischar);
addParameter(p,'setfiles',false,@islogical);
addParameter(p,'setactive',false,@islogical);

parse(p,projectname,varargin{:});

setfiles = p.Results.setfiles;
setactive = p.Results.setactive;
projectname = p.Results.projectname;
