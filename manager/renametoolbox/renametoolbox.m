function varargout = renametoolbox(oldtbname,newtbname,varargin)
%RENAMETOOLBOX renames toolbox entry in toolboxdir and json files

% NOTE!!! Need to add onCleanup and/or other methods to ensure the json file is
% not overwritten and then fails to rewrite, this happened when i passed in
% strings not chars, but I was able to copy deactivate version and recover

% UPDATES
% 11 Apr 2023, support for sublibs via 'libary' optional argument
% 11 Apr 2023, support for moving source to sublib via 'movesource' namevalue

%-------------------------------------------------------------------------
p                 = inputParser;
p.FunctionName    = mfilename;
p.CaseSensitive   = false;
p.KeepUnmatched   = true;

validlibs = @(x)any(validatestring(x,cellstr(gettbdirectorylist)));

addRequired(p,'oldtbname',@(x)ischarlike(x));
addRequired(p,'newtbname',@(x)ischarlike(x));
addOptional(p,'library','',validlibs); % default value must be ''
addParameter(p,'renamesource',false,@(x)islogical(x));
addParameter(p,'movesource',false,@(x)islogical(x));
addParameter(p,'force',false,@(x)islogical(x));

parse(p,oldtbname,newtbname,varargin{:});
oldtbname      = p.Results.oldtbname;
newtbname      = p.Results.newtbname;
libraryname    = p.Results.library;
renamesource   = p.Results.renamesource;
movesource     = p.Results.movesource;
force          = p.Results.force;

% 'renaming' is the same as 'moving' so combine them here
renamesource = movesource | renamesource;

%-------------------------------------------------------------------------

if isstring(oldtbname)
   if isscalar(oldtbname)
      oldtbname = char(oldtbname);
   else
      error('scalar string or char required')
   end
end

if isstring(newtbname)
   if isscalar(newtbname)
      newtbname = char(newtbname);
   else
      error('scalar string or char required')
   end
end

if isstring(libraryname)
   if isscalar(libraryname)
      libraryname = char(libraryname);
   else
      error('scalar string or char required')
   end
end


% read the toolbox directory into memory
toolboxes = readtbdirectory(gettbdirectorypath());

% get the logical index for the toolbox entry
tbidx = findtbentry(toolboxes,oldtbname);

% set the path to the toolbox source code (works if args.library is empty)
oldtbpath = gettbsourcepath(oldtbname);

if not(any(tbidx))

   error('toolbox not in directory');

else

   % new method 11 Apr 2023 to move to sublib
   %newtbpath = strrep(oldtbpath,oldtbname,newtbname);
   newtbpath = fullfile(gettbsourcepath,libraryname,newtbname);
   
   toolboxes.name{tbidx} = newtbname;
   toolboxes.source{tbidx} = newtbpath;

   fprintf('\n toolbox %s renamed to %s/%s \n',oldtbname,libraryname,newtbname);

   writetbdirectory(toolboxes);

end

% rename it to the json directory choices for function 'activate'
renamejsondirectoryentry(oldtbname,newtbname,'activate');

% repeat for 'deactivate'
renamejsondirectoryentry(oldtbname,newtbname,'deactivate');

% rename the source directory ?
renametbsourcedir(renamesource,oldtbpath,newtbpath,force)

% output
switch nargout
   case 1
      varargout{1} = toolboxes;
end


function renamejsondirectoryentry(oldtbname,newtbname,directoryname)

jspath      = gettbjsonpath(directoryname);
wholefile   = readtbjsonfile(jspath);

% simple find/replace
wholefile   = strrep(wholefile,oldtbname,newtbname);

% write it over again
try
   writetbjsonfile(jspath,wholefile);
end
