function projects = addproject(projectname,varargin)
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
p.FunctionName    = 'addproject';
p.CaseSensitive   = false;
p.KeepUnmatched   = true;

addRequired(p,'projectname',@(x)ischar(x));
addOptional(p,'workon','',@(x)ischar(x));

parse(p,projectname,varargin{:});
projectname = p.Results.projectname;
workon      = p.Results.workon;

%-------------------------------------------------------------------------------

% NOTE: getprjsourcpath is more like 'buildprjsourcepath' - it builds the path,
% it doesn't check if it alredy exists, like I do below with any(ismember
dbpath      = getprjdirectorypath;      % tb database (directory) path
prjpath     = getprjsourcepath(projectname); % tb source path
projects    = readprjdirectory(dbpath); % read the directory into memory

% this would be needed if i was appending it to the end of the table,
% but with buildprojectdirectory method, we just reubild it every time,
% in which case we need to get prjidx after adding it to send to tjhe
% subfunctions
%prjidx      = height(projects)+1;

if any(ismember(projects.name,projectname))
   
   %warning('project already in directory, press y to add to json signature file');
   msg = 'project already in directory, press ''y'' to add to json signature file or any other key to return\n';
   str = input(msg,'s');
   if string(str) ~= "y"
      return
   end
end

disp(['adding ' projectname ' to project directory']);
buildprojectdirectory;

% this is based on the tb method which is more complicated, that
% directory only has two columns so i just add the name and path, but
% buildprojectdirectory is better, it just uses the outupt of dir(),
% so i just use buildprojectdirectory as above
%projects(prjidx,:) = {projectname,prjpath};
%writeprjdirectory(projects,dbpath);

projects = readprjdirectory(dbpath); % read the directory into memory
prjidx   = find(ismember(projects.name,projectname));

% add it to the json directory choices for function 'workon'
addtojsondirectory(projects,prjidx,'workon');

% repeat for 'workoff'
addtojsondirectory(projects,prjidx,'workoff');

% activate the toolbox if requested
if string(workon)=="workon"
   workon(projectname);
end

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
end







