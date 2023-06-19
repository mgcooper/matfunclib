function Setup()
% SETUP set paths etc.
% 
% See also Config

% temporarily turn off warnings about paths not already being on the path
withwarnoff('MATLAB:rmpath:DirNotFound')

% Get the path to this file, in case Setup is run from some other folder. More
% robust than pwd(), but assumes the directory structure has not been modified.
thispath = fileparts(mfilename('fullpath'));

% NOTE genpath ignores folders named private, folders that begin with the @
% character (class folders), folders that begin with the + character (package
% folders), folders named resources, or subfolders within any of these.

% UPDATE might use V = filesep() and [thispath V subpath] method b/c right now I
% remove .git but there are other folders that could be problematic e.g. codegen

% This is true if running in desktop. Use it to suppress interactions with
% editor such as opening or closing project files
if usejava('desktop')
   
   
end

% add all paths then remove git paths
addpath(genpath(thispath));
rmpath(genpath(fullfile(thispath,'.git')));

% run Config, Startup, read .env, etc
configureproject(thispath,{'startup.m','config.m'});

% TODO
% 
% resolve dependencies
% 
% set preferences
% setpref('mytoolbox','version',toolboxversion)
% addpref('mytoolbox','toolboxdir',thispath);


% save the path
% savepath(fullfile(thispath,'pathdef.m'));


% helpful notes:
% 
% pathsep returns the platform-specific path separator (e.g. : on macos)
% 
% example:
% p = genpath(pwd);
% s = regexp(p, pathsep, 'split');
% if any(contains(s,'git'))
%    warning off; cellfun(@rmpath,s(contains(s,'git'))); warning on;
% end
% 
% filesep returns the platform-specific file separator (e.g. : on macos)
% 
% fullfile builds a platform-specific full file from fileparts by inserting
% filesep where necessary but not a trailing file separator
% 
% toolboxdir returns the full path to mathworks toolboxes, needed for compiler
% 
% tbxprefix returns the root folder for mathworks toolboxes (its a builtin func)
% 
% tempname, tempdir create temp folders and temp files
% 
% use dbstack to get the file that called a function. For Config, might add a
% check that workon called it (or configurepackage) or it was called directly
% which might require checking mfilename('fullpath') so as to rule out other
% Config files. If called from the command window or terminal I'm not sure.     
