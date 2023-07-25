function varargout = renametoolbox(oldtbname,newtbname,varargin)
%RENAMETOOLBOX renames toolbox entry in toolboxdir and json files
% 
% 
% 
% See also

% TODO add onCleanup and/or other methods when rewriting the directory

% UPDATES
% 11 Apr 2023, support for sublibs via 'libary' optional argument
% 11 Apr 2023, support for moving source to sublib via 'movesource' namevalue

% PARSE INPUTS
[oldtbname, newtbname, libraryname, renamesource, force] = parseinputs( ...
   oldtbname, newtbname, mfilename, varargin{:});

% MAIN FUNCTION

% confirm the toolbox exists
oldtbname = validatetoolbox(oldtbname, funcname, 'TBNAME', 1);

% read the toolbox directory into memory
toolboxes = readtbdirectory(gettbdirectorypath());

% get the logical index for the toolbox entry
tbidx = findtbentry(toolboxes,oldtbname);

% set the path to the toolbox source code (works if args.library is empty)
oldtbpath = gettbsourcepath(oldtbname);

% build the new toolbox path
newtbpath = fullfile(gettbsourcepath,libraryname,newtbname);

% set the toolbox directory entries
toolboxes.name{tbidx} = newtbname;
toolboxes.source{tbidx} = newtbpath;

fprintf('\n toolbox %s renamed to %s/%s \n',oldtbname,libraryname,newtbname);

% rewrite the toolbox directory
writetbdirectory(toolboxes);

% rename the source directory if requested
renametbsourcedir(renamesource,oldtbpath,newtbpath,force)

% output
switch nargout
   case 1
      varargout{1} = toolboxes;
end

%% INPUT PARSER

function [oldtbname, newtbname, libraryname, renamesource, movesource, force] = ...
   parseinputs(oldtbname, newtbname, funcname, varargin)

validlibs = @(x)any(validatestring(x,cellstr(gettbdirectorylist)));
persistent parser
if isempty(parser)
   parser = inputParser;
   parser.FunctionName = funcname;
   parser.CaseSensitive = false;
   parser.KeepUnmatched = true;
   parser.addRequired('oldtbname', @ischarlike);
   parser.addRequired('newtbname', @ischarlike);
   parser.addOptional('library', '', validlibs); % default value must be ''
   parser.addParameter('renamesource', false, @islogical);
   parser.addParameter('movesource', false, @islogical);
   parser.addParameter('force', false, @islogical);
end
parser.parse(oldtbname, newtbname, varargin{:});
force = parser.Results.force;
oldtbname = parser.Results.oldtbname;
newtbname = parser.Results.newtbname;
movesource = parser.Results.movesource;
libraryname = parser.Results.library;
renamesource = parser.Results.renamesource;

% 'renaming' is the same as 'moving' so combine them here
renamesource = movesource | renamesource;

% parsing below only needed b/c NEWTBNAME does not exist in toolbox directory,
% otherwise validateToolbox would do all of this work. If any of the inputs are
% non-scalar strings, then convertStringsToChars will convert them to cellstr,
% which is why the iscell check is performed.

% convert strings to chars so path-joining functions work as expected
[oldtbname, newtbname, libraryname] = convertStringsToChars( ...
   oldtbname, newtbname, libraryname);
oldtbname = validatetoolbox(oldtbname,funcname,'OLDTBNAME',1);
if iscell(oldtbname) || iscell(newtbname) || iscell(libraryname)
   error('MATFUNCLIB:renametoolbox:nonScalarToolboxName', 'toolbox names must be scalar text')
end


% % DEPRECATED - use gettbnamelist in functionsignatures instead
% function renamejsondirectoryentry(oldtbname,newtbname,directoryname)
% 
% jspath      = gettbjsonpath(directoryname);
% wholefile   = readtbjsonfile(jspath);
% 
% % simple find/replace
% wholefile   = strrep(wholefile,oldtbname,newtbname);
% 
% % write it over again
% try
%    writetbjsonfile(jspath,wholefile);
% end