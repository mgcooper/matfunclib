function workoff(varargin)
%WORKOFF removes project 'projectname' from path and (optionally) goes to
%the home directory (go home)
% 
%  workoff('myproject') removes paths and unsets env vars
% 
%  workoff('myproject','gohome') cd to the MATLABUSERPATH
% 
% See also: workon, manager, addproject

% TODO: save open help docs. couldn't find a built in or fex method but see
% gethelpdoclink, it gets the active one, would 

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

% parse inputs
%-------------------------------------------------------------------------------
p = inputParser;
p.FunctionName = mfilename;

projectnames = cat(1,cellstr(projectdirectorylist),'default');
validproject = @(x)any(validatestring(x,projectnames));
validoptions = @(x)any(validatestring(x,{'gohome','no'}));

addOptional(p,'projectname',getactiveproject,validproject);
addOptional(p,'gohome','gohome',validoptions);
parse(p,varargin{:});

projname = p.Results.projectname;
gohome = string(p.Results.gohome) == "gohome"; % transform to logical

% % if no path was provided, this assumes the local directory is it
% if nargin == 0
%    [~,projectname] = fileparts(pwd);
% end
%-------------------------------------------------------------------------------

% deactivate the project
disp(['deactivating ' projname]);

% update the active file list
setprojectfiles(projname);

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

if gohome; cdhome(); end


