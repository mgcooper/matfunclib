function toolboxes = rmtoolbox(tbname,varargin)
%RMTOOLBOX removes toolbox from toolboxdir (optional: delete the toolbox)
%
%
% See also

% parse inputs
p                 = inputParser;
p.FunctionName    = mfilename;
p.CaseSensitive   = false;
p.KeepUnmatched   = true;

validlibs = @(x)any(validatestring(x,cellstr(gettbdirectorylist)));

addRequired(p, 'tbname',@(x)ischar(x));
addOptional(p, 'library','',validlibs);
addParameter(p,'removesource',false,@(x)islogical(x));

parse(p,tbname,varargin{:});
tbname         = p.Results.tbname;
sublib         = p.Results.library;
removesource   = p.Results.removesource;

% function code

% read in the toolbox directory and find the entry for this toolbox
toolboxes   = readtbdirectory(gettbdirectorypath());
tbidx       = findtbentry(toolboxes,tbname);
tbpath      = gettbsourcepath(tbname);

if not(any(tbidx))

   error('toolbox not in directory');

else

   toolboxes(tbidx,:) = [];

   fprintf('\n toolbox %s removed from toolbox directory \n',tbname);

   writetbdirectory(toolboxes);

end

% add it to the json directory choices for function 'activate'
rmjsondirectoryentry(tbname,'activate');

% repeat for 'deactivate'
rmjsondirectoryentry(tbname,'deactivate');

% remove the source?
removetbsourcedir(removesource,tbpath);



function rmjsondirectoryentry(tbname,directoryname)

jspath      = gettbjsonpath(directoryname);
wholefile   = readtbjsonfile(jspath);

% replace the entry with a blank string, note formatting a bit complex
% to get comma and single '' around entry right
tbfind      = sprintf(''',''%s''',tbname);
tbreplace   = '''';
wholefile   = strrep(wholefile,tbfind,tbreplace);

% write it over again
writetbjsonfile(jspath,wholefile);







