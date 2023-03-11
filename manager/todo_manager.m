
% NEED TO USE A BASE PROJECT PATH AND BUILD PROJECTFOLDER FOR CROSS-MACHINE
% PROBABLY BEST TO USE PREFS FOR THIS

% useful functions for manager:
% - version -release
% - version -java
% - verLessThan
% - computer
% - ispc/isunix/ismac but computer may negate the need for them
% just typing 'help' displays useful info

% moved content hre to manager.m but prob better to keep here ...

% not sure what i meant here:
% Use validate string to use the 'env' syntax

% For manager:
% SessionManager
% Project
% Explore
% SMASH Toolbox
% Process
% Soft interrupting of long runs
% template_matlab_analysis

% For mutually exclusive groups I think use separate input parser depending on
% number of inputs see STREAMobj 

% openPackage goes to it

% for ManagerialClass
% SEE rlCreateEnvTemplate FOR EXAMPLE
% Note that class functions can be defined in separate files, so the class can
% just wrap them and set/get props can use short function names 
% This will centralize all operations and facilitate

% Replicate pyenv and virtualenvwrapper in that only two paths are required and
% activate manager in Startup exposes everything else 
% add a wrapper around mlint
% DONE setpref in Setup
% DONE setenv in Config
% Create hashes and backups
% see check_my_code 
% Try using varargin in the json file so valid optionParser autocomplete 
% For initial install of menv-manager there needs to be an option to supply a
% list of project paths in case a root project folder doesn't exist, assumign
% default install option is to provide the WORKON_HOME and PROJECT+HOME and then
% buildprojectdiretory does the rest
% Manager freeze makes a requirements file but also puts a backup in a unique
% hashed folder 
% manager import mypackage imports a package object of class Package so you can
% see in the workspace all the properties of the active package

% If mpm install generated a hash and put each installed copy in that folder
% version dependency could be supported 

% Local versioning is sort of implicit in that the user builds virtual
% environments and or projects and they can be frozen anytime but remote
% versioning is only supported insofar as mpm does it    


% Toolboxes and projects should be able to have the same name so either:
% 
% manager activate bfra toolbox
% manager activate bfra project
% Or
% manager activate -toolbox bfra
% Or keep activate and work on and users have to know that activate means work
% on for toolboxes 
% Or explain that until it's a functioning toolbox, it should be in the project
% directory, or if you're the maintainer it's always a project  



% Best packages:
% hmm and prlm toolboxes
% Climate toolbox
% m_map
% topotoolbox
% CDT
% FSDA
% gmtmex
% chebfun
% bayesFactor
% petsc4m-lite
% pso
% easyh5
% bnt
% fomcon
% Burkhardt mirror
