function deactivate(tbname)
%DEACTIVATE removes toolbox 'tbname' from path and goes to the home directory

% parse inputs
p = inputParser;
p.FunctionName = mfilename;

if nargin == 0
   tbname = defaulttbdir;
elseif nargin == 1
   tbname = char(tbname);
end

% validate that the toolbox exists
withwarnoff({'MATFUNCLIB:manager:toolboxAlreadyActive', ...
   'MATLAB:dispatcher:nameConflict', 'MATLAB:rmpath:DirNotFound'});

[tbname, wid, msg] = validatetoolbox(tbname, mfilename, 'TBNAME', 1);
if ~isempty(wid)
   warning(wid, msg); return
end

% alert 
disp(['deactivating ' tbname]);

% main code
toolboxes = readtbdirectory(gettbdirectorypath());
tbidx = findtbentry(toolboxes,tbname);
tbpath = toolboxes.source{tbidx};

% remove toolbox paths
rmpath(genpath(tbpath));

% set the active state
toolboxes.active(tbidx) = false;

% rewrite the directory
writetbdirectory(toolboxes);

% cd(getenv('MATLABUSERPATH'));


function tbdir = defaulttbdir
% if no path was provided, use pwd
[~,tbdir] = fileparts(pwd);
