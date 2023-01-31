function projfolder = getprojectfolder(varargin)
%GETPROJECTFOLDER get the activefolder property of project
%
%     projfolder = getprojectfolder() returns the activefolder
%     attribute for the activeproject in the projectlist directory
% 
%     projfolder = getprojectfolder(projname) returns the activefolder
%     attribute for project projname in the projectlist directory
% 
%     projfolder = getprojectfolder(___,'namespace') returns the namespace
%     folder for the prior syntax. The namespace folder is the projlist.folder
%     attribute, i.e. the parent folder containing the root of the project,
%     which can differ from the activefolder property. The default behavior
%     returns projlist.activefolder
% 
% See also setprojectfolder

%  GREAT EXAMPLE OF WHY INPUTPARSER IS NEEDED! shows how optionParser only works
%  if we have a fixed number of required args and the opts come after. For
%  example, it fails if I have varargin and one argument (here projlist) is not
%  a char. If I did  not allow projlist to come in then it would be much easier 
%  and in fact I should do that 

% set default option to return the activefolder then parse the input
validopts = {'activefolder','namespace'};
opts = optionParser(validopts,varargin);

if nargin < 1
   opts.activefolder = true;
end

% check if inputs include 'activefolder' or 'namespace'.
if sum(ismember(varargin,validopts))>1
   error('choose one: activefolder or namespace')
else
   numargs = nargin - sum(ismember(varargin,validopts));
end

projlist = readprjdirectory;

% this works if one optional argument is provided
if numargs < 1
   projname = getactiveproject();
else
   projname = varargin{1};
end

projindx = getprjidx(projname,projlist);

% if the namespace folder is requested, append projname to projectlist.folder
if opts.namespace == true
   projfolder = fullfile(projlist.folder{projindx},projname);
else
   projfolder = projlist.activefolder{projindx};
end


% this works if there are no optional arguments and the input is:
% function projfolder = getprojectfolder(projname,projlist)
% if nargin < 2
%    projlist = readprjdirectory;
%    if nargin < 1
%       projname = getactiveproject();
%    end
% end