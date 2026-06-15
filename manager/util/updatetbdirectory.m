function varargout = updatetbdirectory(option, varargin)
   %UPDATETBDIRECTORY Update toolbox directory paths and library assignments.
   %
   % TOOLBOXES = UPDATETBDIRECTORY('paths')
   %   Traverses the toolbox directory and checks if each source path exists.
   %   If the path is found at a different location (toolbox was moved), both
   %   source and library are updated in the returned table. Entries whose
   %   source cannot be found anywhere under MATLAB_TOOLBOX_PATH are marked
   %   'missing' in the returned table but are not removed unless dryrun=false.
   %
   % TOOLBOXES = UPDATETBDIRECTORY('paths', 'dryrun', true)  [default]
   %   Returns the updated table without writing to disk.
   %
   % TOOLBOXES = UPDATETBDIRECTORY('paths', 'dryrun', false)
   %   Writes the updated table to the canonical CSV (removing missing entries).
   %
   % Filesystem layout assumed:
   %   MATLAB_TOOLBOX_PATH/
   %     <name>/            <- Zone 1: stand-alone toolbox   (library = name)
   %     libraries/
   %       <libname>/       <- Zone 2a: library folder entry  (library = libname)
   %         <name>/        <- Zone 2b: library toolbox       (library = libname)
   %
   % See also: buildtoolboxdirectory, addtoolbox, gettbsourcepath, rmtoolbox

   % PARSE INPUTS
   narginchk(1, 3)

   opts.dryrun = true;
   if nargin > 1
      [~, pairs] = parseparampairs(varargin);
      opts = cell2struct(pairs(2:2:end), pairs(1:2:end-1), 2);
   end

   assert(strcmp(option, 'paths'), ...
      "Invalid option. The only available option is 'paths'.");

   % Read current toolbox directory (falls back to backup if CSV is corrupted).
   toolboxes = readtbdirectory(gettbdirectorypath());

   tbroot  = gettbsourcepath();             % MATLAB_TOOLBOX_PATH
   libroot = fullfile(tbroot, 'libraries'); % MATLAB_TOOLBOX_PATH/libraries

   allnames = string(toolboxes.name).';

   for tbname = allnames

      % Current recorded source path (may be stale).
      tbpath = gettbsourcepath(tbname);

      % Derive the correct library and source path for this entry.
      [newpath, newlib] = resolveToolboxPath(tbname, tbpath, tbroot, libroot);

      toolboxes.library{allnames == tbname} = newlib;
      toolboxes.source{allnames == tbname}  = newpath;
   end

   % Remove missing entries and write if not a dry run.
   if ~opts.dryrun
      toolboxes(strcmp(toolboxes.source, 'missing'), :) = [];
      writetbdirectory(toolboxes);
   end

   if nargout > 0
      varargout{1} = toolboxes;
   end
end

% -------------------------------------------------------------------------
function [newpath, library] = resolveToolboxPath(tbname, tbpath, tbroot, libroot)
   %RESOLVETOOLBOXPATH Determine the correct source path and library for TBNAME.
   %
   % If the recorded path still exists, derive the library from its location:
   %   - parent == tbroot           -> stand-alone toolbox, library = tbname
   %   - parent == libroot          -> library folder entry, library = tbname
   %   - grandparent == libroot     -> library toolbox, library = parent name
   %
   % If the recorded path no longer exists, search the filesystem in order:
   %   1. Zone 1: tbroot/<tbname>
   %   2. Zone 2a: libroot/<tbname>
   %   3. Zone 2b: libroot/<any-lib>/<tbname>

   if isfolder(tbpath)
      % Path is valid — classify by location.
      parent      = fileparts(tbpath);
      grandparent = fileparts(parent);

      if strcmp(parent, tbroot)
         % Zone 1: stand-alone toolbox directly under MATLAB_TOOLBOX_PATH.
         library = char(tbname);
         newpath = tbpath;

      elseif strcmp(parent, libroot)
         % Zone 2a: library folder entry (the library root as a toolbox).
         library = char(tbname);
         newpath = tbpath;

      elseif strcmp(grandparent, libroot)
         % Zone 2b: toolbox nested inside a library folder.
         [~, library] = fileparts(parent);
         newpath = tbpath;

      else
         % Path exists but is outside the expected layout — leave as-is.
         library = char(tbname);
         newpath = tbpath;
      end

   else
      % Path no longer exists — search the filesystem.
      newpath = 'missing';
      library = char(tbname);

      % Check Zone 1: directly under MATLAB_TOOLBOX_PATH.
      candidate = fullfile(tbroot, tbname);
      if isfolder(candidate)
         newpath = candidate;
         library = char(tbname);
         return
      end

      % Check Zone 2a: library folder itself under libraries/.
      candidate = fullfile(libroot, tbname);
      if isfolder(candidate)
         newpath = candidate;
         library = char(tbname);
         return
      end

      % Check Zone 2b: toolbox inside any library folder.
      if isfolder(libroot)
         libFolders = dir(libroot);
         libFolders = libFolders([libFolders.isdir] & ...
            ~strcmp({libFolders.name}, '.') & ~strcmp({libFolders.name}, '..'));
         for k = 1:numel(libFolders)
            candidate = fullfile(libroot, libFolders(k).name, tbname);
            if isfolder(candidate)
               newpath  = candidate;
               library  = libFolders(k).name;
               return
            end
         end
      end
   end
end
