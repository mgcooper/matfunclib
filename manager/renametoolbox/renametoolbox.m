function toolboxes = renametoolbox(oldtbname,newtbname,varargin)
%RENAMETOOLBOX renames toolbox entry in toolboxdir and json files
%-------------------------------------------------------------------------
p                 = inputParser;
p.FunctionName    = mfilename;
p.CaseSensitive   = false;
p.KeepUnmatched   = true;

addRequired(p,'oldtbname',@(x)ischar(x));
addRequired(p,'newtbname',@(x)ischar(x));
addParameter(p,'renamesource',false,@(x)islogical(x));

parse(p,oldtbname,newtbname,varargin{:});
oldtbname      = p.Results.oldtbname;
newtbname      = p.Results.newtbname;
renamesource   = p.Results.renamesource;
%-------------------------------------------------------------------------

dbpath      = gettbdirectorypath;
toolboxes   = readtbdirectory(dbpath);
tbidx       = findtbentry(toolboxes,oldtbname);
tbpath      = gettbsourcepath(oldtbname);

if not(any(tbidx))

   error('toolbox not in directory');

else

   newtbpath            = strrep(tbpath,oldtbname,newtbname);
   toolboxes(tbidx,:)   = {newtbname,newtbpath};

   fprintf('\n toolbox %s renamed to %s \n',oldtbname,newtbname);

%       disp(['renaming ' oldtbname ' to ' newtbname]);

   writetbdirectory(toolboxes,dbpath);

end

% rename it to the json directory choices for function 'activate'
renamejsondirectoryentry(oldtbname,newtbname,'activate');

% repeat for 'deactivate'
renamejsondirectoryentry(oldtbname,newtbname,'deactivate');

% rename the source directory ?
renametbsourcedir(renamesource,tbpath,newtbpath)



function renamejsondirectoryentry(oldtbname,newtbname,directoryname)

jspath      = gettbjsonpath(directoryname);
wholefile   = readtbjsonfile(jspath);

% simple find/replace
wholefile   = strrep(wholefile,oldtbname,newtbname);

% write it over again
writetbjsonfile(jspath,wholefile);
