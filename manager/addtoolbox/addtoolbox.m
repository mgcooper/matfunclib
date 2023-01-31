function toolboxes = addtoolbox(tbname,varargin)
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
%     See also activate deactivate

%-------------------------------------------------------------------------------
p                 = inputParser;
p.FunctionName    = mfilename;
p.CaseSensitive   = false;
p.KeepUnmatched   = true;

validlibs         = @(x)any(validatestring(x,cellstr(gettbdirectorylist)));
validopts         = @(x)any(validatestring(x,{'activate'}));

addRequired(p,'tbname',@(x)ischar(x));
addOptional(p,'tblibrary','',validlibs);
addOptional(p,'tbactivate','',@(x)ischar(x));

parse(p,tbname,varargin{:});
tbname      = p.Results.tbname;
tblibrary   = p.Results.tblibrary;
tbactivate  = p.Results.tbactivate;

% test - can I just combine tbname w/ tblibrary and the rest works?
uselib      = ~isempty(tblibrary);

%-------------------------------------------------------------------------------

dbpath = gettbdirectorypath;      % get the tb database (directory) path
toolboxes = readtbdirectory(dbpath); % read the directory into memory

% set the path to the toolbox source code
if uselib
   tbpath = gettbsourcepath([tblibrary filesep tbname]);
else
   tbpath = gettbsourcepath(tbname);
end

% add the toolbox to the end of directory
tbidx = height(toolboxes)+1;

% regardless of sub-libs, we still want to match this
if any(ismember(toolboxes.name,tbname))
   
   error('toolbox already in directory');
   
else
   
   toolboxes(tbidx,:) = {tbname,tbpath};
   
   disp(['adding ' tbname ' to toolbox directory']);
   
   writetbdirectory(toolboxes,dbpath);
   
end

% add it to the json directory choices for function 'activate'
addtojsondirectory(toolboxes,tbidx,'activate');

% repeat for 'deactivate'
addtojsondirectory(toolboxes,tbidx,'deactivate');

% activate the toolbox if requested
if string(tbactivate)=="activate"
   activate(tbname,'goto');
end


function addtojsondirectory(toolboxes,tbidx,directoryname)

jspath      = gettbjsonpath(directoryname);
wholefile   = readtbjsonfile(jspath);

% replace the most recent entry with itself + the new one
tbfind      = sprintf('''%s''',toolboxes.name{tbidx-1});
tbreplace   = sprintf('%s,''%s''',tbfind,toolboxes.name{tbidx});
wholefile   = strrep(wholefile,tbfind,tbreplace);

% write it over again
writetbjsonfile(jspath,wholefile)







