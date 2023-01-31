function Setup()
% SETUP set paths etc.
% 
% See also Config

% temporarily turn off warnings about paths not already being on the path
warning off

% Get the path to this file, in case Setup is run from some other folder. More
% robust than pwd(), but assumes the directory structure has not been modified.
thispath = fileparts(mfilename('fullpath'));

% NOTE genpath ignores folders named private, folders that begin with the @
% character (class folders), folders that begin with the + character (package
% folders), folders named resources, or subfolders within any of these.

% add all paths then remove git paths
addpath(genpath(thispath));
rmpath(genpath(fullfile(thispath,'.git')));

% run Config, Startup, read .env, etc
configureproject(thispath,{'startup.m','config.m'});

% TODO
% resolve dependencies
% use preferences: addpref('toolboxname','version',toolboxversion);

% save the path
% savepath(fullfile(thispath,'pathdef.m'));

% turn warning back on
warning on


