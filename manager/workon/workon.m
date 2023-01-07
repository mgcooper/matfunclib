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

projectname = p.Results.projectname;
goto        = string(p.Results.goto) == "goto"; % transform to logical

%-------------------------------------------------------------------------------
dbpath      = getprjdirectorypath;
projects    = readprjdirectory(dbpath);
prjidx      = findprjentry(projects,projectname);

if sum(prjidx) == 0
   msg = 'project not found in directory, press ''y'' to add it ';
   msg = [msg 'or any other key to return\n'];
   str = input(msg,'s');
   
   if string(str) == "y"
      addproject(projectname);
   else
      return;
   end
end

% commented this out when I added support for sub-libs, since I can just use
% the path entry in the tbdirectory anyway
%prjpath = getprjsourcepath(projectname);
prjpath = [projects.folder{prjidx} filesep projectname];

disp(['activating ' projectname]);
addpath(genpath(prjpath));

% remove .git files from path
if contains(genpath([prjpath '*.git']),'.git')
   warning off; rmpath(genpath([prjpath '*.git'])); warning on;
end

if exist(fullfile(prjpath,'Config.m'),'file') == 2
   try
      feval(fullfile(prjpath,'Config'),[]);
   catch ME
      if strcmp(ME.identifier,'MATLAB:feval:invalidFunctionName')
         try
            run(fullfile(prjpath,'Config'));
         catch ME
            rethrow(ME)
         end
      end
   end
end

if goto; cd(prjpath); end   % cd to the activated tb if requested