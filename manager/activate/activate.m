function activate(tbname,varargin)
%ACTIVATE adds toolbox 'tbname' to path and makes it the working directory

% parse inputs
[tbname, except, postset] = parseinputs(tbname, mfilename, varargin{:});

% main function
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
   disp(strjoin(['activating',tbname,'except',except]));
end

% set the active state
toolboxes.active(tbidx) = true;

% get the toolbox source path
tbpath = toolboxes.source{tbidx};

% add toolbox paths
pathadd(tbpath, true, '-end', except);

% cd to the activated tb if requested
if postset == "goto"
   cd(tbpath); 
end

% rewrite the directory
writetbdirectory(toolboxes);


function [tbname, except, postset] = parseinputs(tbname, funcname, varargin)

p = inputParser;
p.FunctionName = funcname;

validoptions = @(x) any(validatestring(x, {'goto'}));
p.addRequired('tbname', @(x) ischarlike(x));
p.addOptional('postset', 'none', validoptions);
p.addParameter('except', string.empty(), @(x) ischarlike(x));

p.parse(tbname, varargin{:});

tbname = char(p.Results.tbname);
except = string(p.Results.except);
postset = string(p.Results.postset);
