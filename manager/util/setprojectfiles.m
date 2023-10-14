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

   % if a file list is provided, use it, otherwise get all open files
   if nargin < 2
      if isoctave
         error('Default open editor files does not work in Octave')
      end
      filelist = getopenfiles();
   elseif nargin == 2
      % filelist was provided
   end

   % read the project list
   projlist = readprjdirectory(); % struct if in octave, table if in matlab
   projindx = find(getprjidx(projectname, projlist));

   % Set the list
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
