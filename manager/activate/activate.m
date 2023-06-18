function activate(tbname,varargin)
%ACTIVATE adds toolbox 'tbname' to path and makes it the working directory
%-------------------------------------------------------------------------------
p = inputParser;
p.FunctionName = mfilename;

validoptions = @(x)any(validatestring(x,{'goto'}));
addRequired( p,'tbname', @(x)ischar(x));
addOptional( p,'goto', 'none', validoptions);
addParameter( p,'except', string.empty(), @(x)ischarlike(x));

parse(p,tbname,varargin{:});

tbname = p.Results.tbname;
except = tostring(p.Results.except); % tostring supports cellstr arrays
goto = string(p.Results.goto) == "goto"; % transform to logical

% 28 May 2023 added except option, for now it only accepts one argument e.g.:
% activate cryosphere except CVPM
% not
% activate cryosphere except CVPM fastice

%-------------------------------------------------------------------------------
toolboxes = readtbdirectory(gettbdirectorypath);
tbidx = findtbentry(toolboxes,tbname);

if sum(tbidx) == 0
   
   % 27 May 2023, removed addtoolbox option b/c it doesn't deal with sublibs
   error('toolbox not found in directory, use addtoolbox to add it')
   
%    msg = 'toolbox not found in directory, press ''y'' to add it ';
%    msg = [msg 'or any other key to return\n'];
%    str = input(msg,'s');
%    
%    if string(str) == "y"
%       addtoolbox(tbname);
%    else
%       return;
%    end
   
end

% alert
if isempty(except)
   disp(['activating ' tbname]);
else
   disp(strjoin(['activating',tbname,'except',except(:)]));
end

% get the toolbox source path
tbpath = toolboxes.source{tbidx};

% set the active state
toolboxes.active(tbidx) = true;

% add toolbox paths
addpath(genpath(tbpath));

% remove .git files from path and any 'except' sublibraries
if contains(genpath(fullfile(tbpath,'.git')),'.git')
   w = withwarnoff('MATLAB:rmpath:DirNotFound');
   rmpath(genpath(fullfile(tbpath,'.git')));
   if ~isempty(except)
      for n = 1:numel(except)
         rmpath(genpath(fullfile(tbpath,except(n))))
      end
   end
end

% cd to the activated tb if requested
if goto; cd(tbpath); end

% rewrite the directory
writetbdirectory(toolboxes);
