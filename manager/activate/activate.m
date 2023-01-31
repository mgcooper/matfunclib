function activate(tbname,varargin)
%ACTIVATE adds toolbox 'tbname' to path and makes it the working directory
%-------------------------------------------------------------------------------
p                 = inputParser;
p.FunctionName    = 'activate';

addRequired(   p,'tbname',       @(x)ischar(x));
addOptional(   p,'goto',   'no', @(x)ischar(x));

parse(p,tbname,varargin{:});

tbname   = p.Results.tbname;
goto     = string(p.Results.goto) == "goto"; % transform to logical

%-------------------------------------------------------------------------------
toolboxes   = readtbdirectory(gettbdirectorypath);
tbidx       = findtbentry(toolboxes,tbname);

if sum(tbidx) == 0
   msg = 'toolbox not found in directory, press ''y'' to add it ';
   msg = [msg 'or any other key to return\n'];
   str = input(msg,'s');
   
   if string(str) == "y"
      addtoolbox(tbname);
   else
      return;
   end
   
end

% commented this out when I added support for sub-libs, since I can just use
% the path entry in the tbdirectory anyway
%tbpath = gettbsourcepath(tbname);
tbpath = toolboxes.source{tbidx};

disp(['activating ' tbname]);
addpath(genpath(tbpath));

if goto; cd(tbpath); end   % cd to the activated tb if requested

% remove .git files from path
if contains(genpath([tbpath '*.git']),'.git')
   warning off; rmpath(genpath([tbpath '*.git'])); warning on;
end