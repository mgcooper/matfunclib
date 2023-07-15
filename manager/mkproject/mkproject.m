function mkproject(projectname,varargin)
%MKPROJECT make a new project in MATLABPROJECTPATH
%
%  MKPROJECT(projectname) creates a new default project in
%  MATLABPROJECTPATH/projectname
%
% Example
%
%
% Matt Cooper, 21-Mar-2023, https://github.com/mgcooper
%
% See also: copytoolboxtemplate

%% parse inputs
[projectname, setfiles, setactive, maketoolbox] = parseinputs( ...
   projectname, mfilename, varargin{:});

%% main

% Full path to project
projectpath = fullfile(getenv('MATLABPROJECTPATH'),projectname);

% Flag to proceed with making the new project or not
createproject = false;
forcecopyflag = false;
safercopyflag = false;

% Determine if the requested project should be made
if isfolder(projectpath)
   % project folder exists
   msg = sprintf(['\nproject folder exists in %s,\n' ...
      'press ''y'' to add the project to the project directory or any other key to exit\n'], ...
      projectpath);
   str = input(msg,'s');

   if string(str) == "y"
      % add the existing project to the project directory
      createproject = true;
   end

   if numel(rmdotfolders(dir(projectpath))) > 0
      % existing folder is not empty
      safercopyflag = true;
   else
      forcecopyflag = true;
   end
else
   if isfolder(fileparts(projectpath))
      mkdir(projectpath)
      createproject = true;
   else
      error('project path parent folder does not exist: %s',fileparts(projectpath));
   end
end

% add the new project to the project directory
if createproject == true
   
   % if this is a toolbox, copy the template first
   if maketoolbox == true
      copytoolboxtemplate(projectpath, 'forcecopy', forcecopyflag, ...
         'safecopy', safercopyflag);
   end
   addproject(projectname, setfiles, setactive);
end


%% input parsing
function [projectname,setfiles,setactive,maketoolbox] = parseinputs( ...
   projectname, funcname, varargin)

p = inputParser;
p.FunctionName = funcname;

addRequired(p,'projectname',@ischar);
addParameter(p,'setfiles',false,@islogical);
addParameter(p,'setactive',false,@islogical);
addParameter(p,'maketoolbox',false,@islogical);

parse(p,projectname,varargin{:});

setfiles = p.Results.setfiles;
setactive = p.Results.setactive;
maketoolbox = p.Results.maketoolbox;
projectname = p.Results.projectname;

