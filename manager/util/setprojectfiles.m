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
   % Example
   %
   % I want to update the paths in the activefiles list of a project:
   %
   % oldstr = 'E3SM-MOSART-offline-mode';
   % newstr = 'interface-e3sm';
   % projectlist = openprojectdirectory;
   % files = projectlist.activefiles{48,1};
   % files = strrepl(files, oldstr, newstr);
   % setprojectfiles("interface-e3sm", files)
   %
   % See also getprojectfiles

   % Bit more detail on the example. I wanted to rename e3sm-interface to
   % interface-e3sm, but I don't think there is a 'renameproject' function, so I
   % first removed it, b/c it had no activefiles, then changed the actual
   % dirname to interface-e3sm, then used addproject, but the active files were
   % the ones associated with 'interface' which were all in
   % E3SM-MOSART-offline-mode dir, so I needed to replace those paths with
   % interface-e3sm, below did it, I made it a general purpose function strrepl,
   % but it is useful for resetting project paths

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

   % I had this note: Shouldn't need these with setprojectfolder but in case:
   % setprojectfiles
   % setactivefiles
   % not sure what I was thinking or if I missed something like maybe if
   % setprojectfolder is used then the projectfiles are just the ones in that path,
   % but activefiles could be antyhing

   % careful with passing projlist around. if we always read/write, then we know
   % its state is up to date, but if we pass it around, it can get out of sync. an
   % older version of workon made a variable copy of projlist before calling this
   % function, then passed the variable copy to setprojectactive which rewrote the
   % directory and erased the saved active files. I commented this out for that
   % reason and removed projlist as an input.

   % if nargin == 1
   %    projlist = readprjdirectory;
   % end
   % projindx = getprjidx(projname,projlist);