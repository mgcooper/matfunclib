function projlist = setprojectfiles(projectname, filelist)
   %SETPROJECTFILES Update the project file list to the open Editor files.
   %
   % projlist = setprojectfiles() Sets the current active project files to the
   % files open in the Editor.
   %
   % projlist = setprojectfiles(PROJECTNAME) Sets PROJECTNAME files.
   %
   % projlist = setprojectfiles(PROJECTNAME, FILELIST) Sets the files to the
   % ones in FILELIST. Use this option to overrule the ones set based on the
   % Editor, but take care to not overrule them again when the project is
   % changed or Matlab is closed.
   %
   % Without FILELIST the write is guarded. When the stored list is not
   % empty and the editor holds none of its files, the function keeps the
   % stored list and issues the warning
   % matfunclib:setprojectfiles:unpopulatedSession. That is the state of
   % a session that never reopened the project's files. The overlap test
   % compares full paths. It folds case for each stored path when its own
   % volume folds it, and it folds separators on Windows.
   %
   %
   % Example:
   %
   % % Update the paths in the activefiles list of a project:
   %
   % oldstr = 'E3SM-MOSART-offline-mode';
   % newstr = 'interface-e3sm';
   % projectlist = openprojectdirectory();
   % files = projectlist.activefiles{48, 1};
   % files = strrepl(files, oldstr, newstr);
   % setprojectfiles("interface-e3sm", files)
   %
   % See also: getprojectfiles

   narginchk(0,2);

   if nargin < 1
      projectname = getactiveproject();
   end

   % If a file list was not provided, get all open files.
   editorderived = nargin < 2;
   if editorderived
      if isoctave
         error('Default open editor files does not work in Octave')
      end
      filelist = getopenfiles();
   end

   % Read the project directory list.
   projlist = readprjdirectory(); % struct if in octave, table if in matlab
   projindx = find(getprjidx(projectname, projlist));

   % Guard the editor-derived write (matfunclib-juq.39, audit HIGH #11 and
   % MEDIUM #38). A session that never reopened the project's files would
   % overwrite a curated list with whatever the editor holds. Examples are
   % a boot without the startup shim, or a plain workon/workoff in a
   % session whose editor holds none of them. The function keeps the
   % stored list when it is not empty and none of its files is open. That
   % is the sign of a session that never populated the editor. A
   % caller-supplied FILELIST is never guarded, and a session that holds
   % at least one of the stored files updates the list. matfunclib-6og
   % found the normal quit path sound (28 of 28 files preserved, finish.m's
   % path repair 0.13 s). The default therefore stays true, and only the
   % write is guarded. The stored and editor paths are both absolute, but
   % a file system that folds case can report the same file in two
   % spellings. So anystoredopen compares each stored path without case
   % when the volume holding that path folds it. foldscase probes the
   % volume through the path and walks up to its nearest existing
   % ancestor. The stored list can span volumes with different rules (a
   % folding home volume and a case-sensitive external one), so the test
   % asks the rule per path. Windows accepts either separator, so
   % separators fold there only; on other systems a backslash is an
   % ordinary character in a name.
   if editorderived && ~isoctave
      stored = string(projlist.activefiles{projindx});
      stored = stored(strlength(stored) > 0);
      current = string(filelist);
      if ispc
         stored = strrep(stored, "\", "/");
         current = strrep(current, "\", "/");
      end
      if ~isempty(stored) && ~anystoredopen(stored, current)
         warning('matfunclib:setprojectfiles:unpopulatedSession', ...
            ['setprojectfiles: the editor holds none of the %d files ' ...
            'stored for %s, so the stored list is kept. Pass a file list ' ...
            'to replace it on purpose.'], numel(stored), projectname);
         return
      end
   end

   % Set the list.
   if isoctave
      projlist(projindx).activefiles = filelist;
      warning(['writeprjdirectory not supported in Octave, ' ...
         'returning projectlist but not updating the directory'])
      return
   else
      projlist.activefiles{projindx} = filelist;
   end

   writeprjdirectory(projlist);
end

function tf = anystoredopen(stored, current)
   %ANYSTOREDOPEN True when any STORED path names a file in CURRENT.
   %
   % Each stored path matches with or without case according to its own
   % volume, so a list that spans a folding and a case-sensitive volume
   % gets a per-path test.
   tf = false;
   for k = 1:numel(stored)
      if foldscase(char(stored(k)))
         tf = any(strcmpi(stored(k), current));
      else
         tf = any(strcmp(stored(k), current));
      end
      if tf
         return
      end
   end
end
