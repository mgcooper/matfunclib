function activate(tbname,varargin)
%ACTIVATE adds toolbox 'tbname' to path and makes it the working directory
% 
%  activate(TBNAME) activates toolbox TBNAME
% 
% See also addtoolbox, isactive

% PARSE INPUTS
[tbname, except, pathloc, postset] = parseinputs(tbname, mfilename, varargin{:});

% MAIN FUNCTION

% if the toolbox is active, issue a warning, but suppress warnings about
% filename conflicts
withwarnoff('MATLAB:dispatcher:nameConflict');
[tbname, wid, msg] = validatetoolbox(tbname, mfilename, 'TBNAME', 1);
if ~isempty(wid)
   warning(wid, msg)
   return
end

% otherwise, proceed with activating the toolbox
toolboxes = readtbdirectory(gettbdirectorypath);
tbidx = findtbentry(toolboxes,tbname);

% alert the user the toolbox is being activated
if isempty(except)
   disp(['activating ' tbname])
else
   disp(strjoin(['activating',tbname,'except',except]))
end

% set the active state
toolboxes.active(tbidx) = true;

% get the toolbox source path
tbpath = toolboxes.source{tbidx};

% add toolbox paths
pathadd(tbpath, true, pathloc, except);

% cd to the activated tb if requested
if postset == "goto"
   cd(tbpath); 
end

% rewrite the directory
writetbdirectory(toolboxes);

%% local functions
   
function [tbname, except, pathloc, postset] = parseinputs(tbname, funcname, varargin)

persistent parser
if isempty(parser)
   parser = inputParser;
   parser.FunctionName = funcname;
   parser.addRequired('tbname', @ischarlike);
   parser.addOptional('postset', 'none', @(x) any(validatestring(x, {'goto'})));
   parser.addParameter('except', string.empty(), @ischarlike);
   parser.addParameter('pathloc', '-end', @ischarlike);
end
parser.parse(tbname, varargin{:});
tbname = char(parser.Results.tbname);
except = string(parser.Results.except);
postset = string(parser.Results.postset);
pathloc = string(parser.Results.pathloc);


% if isactive(tbname)
%    wid = 'MATFUNCLIB:manager:toolboxAlreadyActive';
%    msg = [tbname ' toolbox is already active'];
%    warning(wid, msg)
%    return
% elseif ~istoolbox(tbname)
%    % error if the toolbox is not in the directory
%    eid = 'MATFUNCLIB:manager:toolboxNotFound';
%    msg = 'toolbox not found in directory, use addtoolbox to add it';
%    error(eid, msg)
%    
%    % option to add the toolbox deactivated, if used, need option to return
%    % status = tryaddtoolbox(tbname);
% end
% 
% function status = tryaddtoolbox(tbname)
% % this is not used b/c it does not support sub-libraries, better to just warn
% % the user to add the toolbox using addtoolbox
% msg = 'toolbox not found in directory, press ''y'' to add it ';
% msg = [msg 'or any other key to return\n'];
% str = input(msg,'s');
% status = false;
% if string(str) == "y"
%    addtoolbox(tbname);
%    status = true;
% end