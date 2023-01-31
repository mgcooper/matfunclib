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

% parse inputs
%-------------------------------------------------------------------------------
p              = inputParser;
p.FunctionName = 'workoff';

validproject = @(x)any(validatestring(x,cellstr(projectdirectorylist)));
validoption = @(x)any(validatestring(x,{'gohome','no'}));

addOptional(p,'projectname',getactiveproject,validproject);
addOptional(p,'gohome','gohome',validoption);
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

% full path to project folder
projpath = getprojectfolder(projname); % use 'namespace' for old behavior

% update the active file list
setprojectfiles(projname);

% remove project paths
rmprojectpaths(projpath);

% close all currently open files
closeopenfiles();

if gohome
   cdhome();
end


