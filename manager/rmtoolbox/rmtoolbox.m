function varargout = rmtoolbox(tbname,varargin)
%RMTOOLBOX removes toolbox from toolboxdir (optional: delete the toolbox)
%
%  TOOLBOXES = rmtoolbox(TBNAME) removes TBNAME entry in TOOLBOXES directory 
%  and resaves the toolbox directory file.
% 
% See also: renametoolbox, addtoolbox, activate, deactivate

% Note: I have an optional 'libary' option but i don't think it's needed if the
% tbpath is read from the directory 'source' column, but maybe for backward
% compatibility with older entries? 

% PARSE INPUTS
[tbname, rmsource] = parseinputs(tbname, mfilename, varargin{:});

% MAIN FUNCTION

% confirm the toolbox exists
tbname = validatetoolbox(tbname, funcname, 'TBNAME', 1);

% read in the toolbox directory and find the entry for this toolbox
toolboxes = readtbdirectory(gettbdirectorypath());
tbindx = findtbentry(toolboxes,tbname);
tbpath = gettbsourcepath(tbname);

% remove the toolbox entry
toolboxes(tbindx,:) = [];
fprintf('\n toolbox %s removed from toolbox directory \n',tbname);
writetbdirectory(toolboxes);

% remove the source code if requested
removetbsourcedir(rmsource,tbpath);

% manage output
if nargout == 1
   varargout{1} = toolboxes;
end

%% INPUT PARSER
function [tbname, rmsource, library] = parseinputs(tbname, funcname, varargin)

% validation function for toolbox names
validlibs = @(x) any(validatestring(x,cellstr(gettbdirectorylist)));

parser = inputParser;
parser.FunctionName = funcname;
parser.CaseSensitive = false;
parser.KeepUnmatched = true;
parser.addRequired('tbname', @ischar);
parser.addOptional('library', '', validlibs);
parser.addParameter('rmsource', false, @islogical);
parser.parse(tbname,varargin{:});

tbname = convertStringsToChars(parser.Results.tbname);
library = convertStringsToChars(parser.Results.library);
rmsource = parser.Results.rmsource;


% % deprecated - use getbnamelist in functionsignatures instead
% function rmjsondirectoryentry(tbname,directoryname)
% 
% jspath      = gettbjsonpath(directoryname);
% wholefile   = readtbjsonfile(jspath);
% 
% % replace the entry with a blank string, note formatting a bit complex
% % to get comma and single '' around entry right
% tbfind      = sprintf(''',''%s''',tbname);
% tbreplace   = '''';
% wholefile   = strrep(wholefile,tbfind,tbreplace);
% 
% % write it over again
% writetbjsonfile(jspath,wholefile);
