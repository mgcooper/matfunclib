function deactivate(tbname)
%DEACTIVATE removes toolbox 'tbname' from path and goes to the home directory

% parse inputs
p = inputParser;
p.FunctionName = mfilename;

if nargin == 0
   tbname = defaulttbdir;
elseif nargin == 1
   tbname = char(tbname);
end

% validate that the toolbox exists
withwarnoff({'MATFUNCLIB:manager:toolboxAlreadyActive', ...
   'MATLAB:dispatcher:nameConflict', 'MATLAB:rmpath:DirNotFound'});

% main code
toolboxes = readtbdirectory(gettbdirectorypath());

if strcmp('all', tbname)
   
   for tbname = toolboxes.name.'
      toolboxes = deactivateToolbox(tbname{:}, toolboxes);
   end
   
else

   [tbname, wid, msg] = validatetoolbox(tbname, mfilename, 'TBNAME', 1);
   if ~isempty(wid)
      warning(wid, msg); return
   end

   % alert 
   disp(['deactivating ' tbname]);
   
   toolboxes = deactivateToolbox(tbname, toolboxes);
end

% rewrite the directory
writetbdirectory(toolboxes);
   

function toolboxes = deactivateToolbox(tbname, toolboxes)

withwarnoff({'MATFUNCLIB:manager:toolboxAlreadyActive', ...
   'MATLAB:dispatcher:nameConflict', 'MATLAB:rmpath:DirNotFound'});

tbidx = findtbentry(toolboxes, tbname);
tbpath = toolboxes.source{tbidx};

% remove toolbox paths
pathadd(tbpath, "rmpath", true);

% set the active state
toolboxes.active(tbidx) = false;

      
function tbdir = defaulttbdir
% if no path was provided, use pwd
[~,tbdir] = fileparts(pwd);
