function varargout = addtoolbox(tbname,varargin)
% ADDTOOLBOX adds toolbox to toolbox directory and functionsignature file
%
%     addtoolbox('tbname') adds toolbox with name 'tbname' to the toolbox
%     directory and the functionSignatures.json code for function 'activate'. a
%     check is done that the toolbox source code exists in the user toolbox
%     source code directory and whether the toolbox already exists in the
%     directory.
%
%     addtoolbox('tbname','libname') adds toolbox with name 'tbname' located in
%     toolbox library with name 'libname' to the toolbox directory, as above.
%     This option allows toolboxes to be grouped within libraries such as
%     'stats', 'hydro', etc.
%
%     addtoolbox(___,'activate') adds the toolbox to the current path and cd's
%     into the source code folder.
%
%
%     Examples
%
%     addtoolbox('test','stats','activate') will add an entry to the toolbox
%     directory for toolbox 'test' located in libary 'stats' and will attempt to
%     cd into the folder located at:
%     [getenv('MATLABSOURCEPATH') filesep libname filesep tbname]
%
%     See also activate deactivate renametoolbox isactive
% 
% UPDATES
% 7 Feb 2023, tbpath method updated to work for both top-level and sublib dirs,
% but assumes args.library is empty by default. changed variable names from
% 'tblibrary' and 'tbactivate' to 'library' and 'postadd'

% PARSE INPUTS
args = parseinputs(tbname, mfilename, varargin{:});

% MAIN

% read the toolbox directory into memory
toolboxes = readtbdirectory(gettbdirectorypath());

% set the path to the toolbox source code (works if args.library is empty)
tbpath = fullfile(gettbsourcepath,args.library,args.tbname);

% add the toolbox to the end of directory
tbidx = height(toolboxes)+1;

% regardless of sub-libs, we still want to match this
if any(ismember(toolboxes.name,args.tbname))
   error('toolbox already in directory');
else
   toolboxes(tbidx,:) = {args.tbname,tbpath,false};
   
   disp(['adding ' args.tbname ' to toolbox directory']);
   
   writetbdirectory(toolboxes);
end

% add it to the json directory choices for function 'activate'
addtojsondirectory(toolboxes,tbidx,'activate');

% repeat for 'deactivate'
addtojsondirectory(toolboxes,tbidx,'deactivate');

% activate the toolbox if requested
if string(args.postadd)=="activate"
   activate(args.tbname,'goto');
end

% output
switch nargout
   case 1
      varargout{1} = toolboxes;
end

%% LOCAL FUNCTIONS
function addtojsondirectory(toolboxes,tbidx,directoryname)

jspath      = gettbjsonpath(directoryname);
wholefile   = readtbjsonfile(jspath);

% replace the most recent entry with itself + the new one
tbfind      = sprintf('''%s''',toolboxes.name{tbidx-1});
tbreplace   = sprintf('%s,''%s''',tbfind,toolboxes.name{tbidx});
wholefile   = strrep(wholefile,tbfind,tbreplace);

% write it over again
writetbjsonfile(jspath,wholefile)

% % NOTE on tbpath method - gettbsourcepath with no input returns the matlab
% source directory so if args.library is empty then the new method in the main
% code works for both cases, sub-library or no sublibrary. This is the old
% method that is slightly safer b/c gettbsourcepath loads the file and finds the
% path in the table. 

% if ~isempty(args.library)
%    tbpath = fullfile(gettbsourcepath,args.library,args.tbname);
% else
%    tbpath = gettbsourcepath(args.tbname);
% end

%% INPUT PARSER
function [tbname, args] = parseinputs(tbname, funcname, varargin)

validlibs = @(x)any(validatestring(x,cellstr(gettbdirectorylist)));
validopts = @(x)any(validatestring(x,{'activate'}));
persistent parser
if isempty(parser)
   parser = inputParser;
   parser.FunctionName = funcname;
   parser.CaseSensitive = false;
   parser.KeepUnmatched = true;
   parser.addRequired('tbname', @ischar);
   parser.addOptional('library', '', validlibs); % default value must be ''
   parser.addOptional('postadd', '', validopts);
end
parser.parse(tbname,varargin{:});
args = parser.Results;

