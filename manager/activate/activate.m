function activate(tbname,varargin)
%ACTIVATE adds toolbox 'tbname' to path and makes it the working directory
% 
%  activate(TBNAME) activates toolbox TBNAME
% 
% See also addtoolbox, isactive

% PARSE INPUTS
[tbname, except, postset] = parseinputs(tbname, mfilename, varargin{:});

% MAIN FUNCTION

% if the toolbox is active, return silently
if isactive(tbname)
   warning([tbname ' toolbox is already active'])
   return
elseif ~istoolbox(tbname)
   % error if the toolbox is not in the directory
   eid = 'matfunclib:manager:toolboxNotFound';
   msg = 'toolbox not found in directory, use addtoolbox to add it';
   error(eid, msg)
   
   % option to add the toolbox deactivated, if used, need option to return
   % status = tryaddtoolbox(tbname);
end

% otherwise, proceed with activating the toolbox
toolboxes = readtbdirectory(gettbdirectorypath);
tbidx = findtbentry(toolboxes,tbname);

% alert the user the toolbox is being activated
ifelse(isempty(except), disp(['activating ' tbname]), ...
   disp(strjoin(['activating',tbname,'except',except])))

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

%% local functions

function status = tryaddtoolbox(tbname)
% this is not used b/c it does not support sub-libraries, better to just warn
% the user to add the toolbox using addtoolbox
msg = 'toolbox not found in directory, press ''y'' to add it ';
msg = [msg 'or any other key to return\n'];
str = input(msg,'s');
status = false;
if string(str) == "y"
   addtoolbox(tbname);
   status = true;
end
   
function [tbname, except, postset] = parseinputs(tbname, funcname, varargin)

persistent parser
if isempty(parser)
   parser = inputParser;
   parser.FunctionName = funcname;
   parser.addRequired('tbname', @ischarlike);
   parser.addOptional('postset', 'none', @(x) any(validatestring(x, {'goto'})));
   parser.addParameter('except', string.empty(), @ischarlike);
end
parser.parse(tbname, varargin{:});
tbname = char(parser.Results.tbname);
except = string(parser.Results.except);
postset = string(parser.Results.postset);
