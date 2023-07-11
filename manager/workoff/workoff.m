function workoff(varargin)
%WORKOFF deactivate project and (optionally) update activefiles
% 
%  workoff('myproject') removes project paths, unsets env vars, updates the
%  activefiles property of the projectdirectory to the currently open files, and
%  sets the 'default' project active. 
% 
%  workoff('myproject','updatefiles', false) does not update the activefiles
%  list associated with MYPROJECT to the current open files. Default is true,
%  the current open files are saved to the activefiles property for MYPROJECT.
% 
% See also: workon, manager, addproject

% TODO: save open variables in struct then save as .mat file, save open figures,
% and save help docs? couldn't find a built in or fex method but see
% gethelpdoclink, it gets the active one.

% UPDATES
% 10 Mar 2023 set active project to 'default' to prevent losing active files
% when workoff is called during a session and then matlab is closed.
% Old behavior: when workoff is called, activefiles are updated, but
% activeproject is not. If matlab is closed, workoff is called from finish.m and
% the activefiles are updated, but the activeproject is still set so the
% activefiles are lost
% New behavior: when workoff is called, activefiles are updat4ed and
% activeproject is set to 'default'. If matlab is closed, the activefiles are
% updated for project 'default'.

%% parse inputs
[projname, updatefiles] = parseinputs(mfilename, varargin{:});

%% main

% deactivate the project
disp(['deactivating ' projname]);

% update the active file list
if updatefiles == true
   setprojectfiles(projname);
end

% close all currently open files
closeopenfiles();

% if this is not the default project, remove the project paths
if ~strcmpi(projname,'default')
   
   % full path to project folder
   projpath = getprojectfolder(projname); % use 'namespace' for old behavior

   % remove project paths
   rmprojectpaths(projpath);
end

% unset the active project
setprojectactive('default');

%% subfunctions

function [projname, updatefiles] = parseinputs(funcname, varargin)
p = inputParser;
p.FunctionName = funcname;

projectnames = cat(1,cellstr(projectdirectorylist),'default');
validproject = @(x)any(validatestring(x,projectnames));

addOptional(p,'projectname',getactiveproject,validproject);
addParameter(p,'updatefiles',true,@islogical);
parse(p,varargin{:});

projname = p.Results.projectname;
updatefiles = p.Results.updatefiles;
