function deactivate(tbname)
%DEACTIVATE removes toolbox 'tbname' from path and goes to the home directory

% parse inputs
p                 = inputParser;
p.FunctionName    = mfilename;
% p.UsingDefaults % this may be needed to solve the function hint issue
%  addOptional(p,'tbname',defaulttbdir(),@(x)ischar(x));
%  parse(p,tbname);
%  tbname   = p.Results.tbname;
% input parsing may be overkill here ... I just want to deactivate
if nargin == 0
   tbname = defaulttbdir;
end

% main code
toolboxes = readtbdirectory(gettbdirectorypath());
tbidx = findtbentry(toolboxes,tbname);
tbpath = toolboxes.source{tbidx};

% could put next three into a function rmtbpath(tbpath);
disp(['deactivating ' tbname]);
warning off; rmpath(genpath(tbpath)); warning on;
% cd(getenv('MATLABUSERPATH'));
% warning off/on suppresses warnings issued when a new folder was
% created in the active toolbox directory and isn't on the path


function tbdir = defaulttbdir
% if no path was provided, use pwd
[~,tbdir] = fileparts(pwd);
