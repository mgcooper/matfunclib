function deactivate(tbname)
%DEACTIVATE removes toolbox 'tbname' from path and goes to the home directory

% parse inputs
p = inputParser;
p.FunctionName = mfilename;

if nargin == 0
   tbname = defaulttbdir;
end

% alert 
disp(['deactivating ' tbname]);

% main code
toolboxes   = readtbdirectory(gettbdirectorypath());
tbidx       = findtbentry(toolboxes,tbname);
tbpath      = toolboxes.source{tbidx};

% warning off/on suppresses warnings issued when a new folder was
% created in the active toolbox directory and isn't on the path
w = withwarnoff('MATLAB:rmpath:DirNotFound');
rmpath(genpath(tbpath));

% set the active state
toolboxes.active(tbidx) = false;

% rewrite the directory
writetbdirectory(toolboxes);

% cd(getenv('MATLABUSERPATH'));


function tbdir = defaulttbdir
% if no path was provided, use pwd
[~,tbdir] = fileparts(pwd);
