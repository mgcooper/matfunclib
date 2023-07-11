function varargout = rmtoolbox(tbname,varargin)
%RMTOOLBOX removes toolbox from toolboxdir (optional: delete the toolbox)
%
%
% See also renametoolbox addtoolbox

% Note: I have an optional 'libary' option but i don't think it's needed if the
% tbpath is read from the directory 'source' column, but maybe for backward
% compatibility with older entries? 

% parse inputs
p = inputParser;
p.FunctionName = mfilename;
p.CaseSensitive = false;
p.KeepUnmatched = true;

validlibs = @(x)any(validatestring(x,cellstr(gettbdirectorylist)));

addRequired(p, 'tbname',@(x)ischar(x));
addOptional(p, 'library','',validlibs);
addParameter(p,'removesource',false,@(x)islogical(x));

parse(p,tbname,varargin{:});
tbname = p.Results.tbname;
sublib = p.Results.library;
removesource = p.Results.removesource;

% function code

% read in the toolbox directory and find the entry for this toolbox
toolboxes = readtbdirectory(gettbdirectorypath());
tbindx = findtbentry(toolboxes,tbname);
tbpath = gettbsourcepath(tbname);

if not(any(tbindx))

   error('toolbox not in directory');

else

   toolboxes(tbindx,:) = [];

   fprintf('\n toolbox %s removed from toolbox directory \n',tbname);

   writetbdirectory(toolboxes);

end

% add it to the json directory choices for function 'activate'
rmjsondirectoryentry(tbname,'activate');

% repeat for 'deactivate'
rmjsondirectoryentry(tbname,'deactivate');

% remove the source?
removetbsourcedir(removesource,tbpath);

if nargout == 1
   varargout{1} = toolboxes;
end



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







