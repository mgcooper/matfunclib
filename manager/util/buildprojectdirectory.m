function varargout = buildprojectdirectory(varargin)
   %BUILDPROJECTDIRECTORY Build project directory file.
   %
   %  projectlist = buildprojectdirectory()
   %  projectlist = buildprojectdirectory('dryrun')
   %  projectlist = buildprojectdirectory('rebuild')
   %  projectlist = buildprojectdirectory('rebuild', 'dryrun')
   %
   % Description
   %
   %  This function creates the project directory. Use it to setup a directory
   %  from scratch, or rebuild one after changing the project parent path. Note
   %  that this is called by "addproject", which is called by "mkproject", thus
   %  everytime a new project is created, this function is called.
   %
   %  Notes on moving projects or changing the project parent path:
   %
   %  If a project is moved, or the MATLABPROJECTPATH environment variable is
   %  changed, use the 'rebuild', 'dryrun' option to dryrun the new directory.
   %  When 'rebuild' is used, only the name, folder, and other atts created by
   %  the dir function are updated. The other atts (activefiles, activeproject,
   %  activefolder, and linkedproject) are copied over from the old list.
   %
   %  The next time a project is opened using "workon", the "reopenfiles"
   %  method, used to reopen project files, will find the files if they exist on
   %  the matlab path, even though their full path has changed, because it uses
   %  "which" with the filename. Thus the activefiles self-repair themselves to
   %  an extent. To be absolutely certain the activefiles are reset, ensure all
   %  possible locations are on the matlab path. You can always check the
   %  backed-up directories if needed.
   %
   %  PROJECTLIST = BUILDPROJECTDIRECTORY('DRYRUN') builds a projectlist
   %  directory that would be saved in the `PROJECTDIRECTORYPATH` folder but
   %  does not save it. Use this to build the project directory from scratch
   %  using the folders in the directory set by the MATLABPROJECTPATH
   %  environment variable. If a USERPROJECTPATH environment variable exists,
   %  folders in that directory will also be added to the project list. Internal
   %  note: the .csv file is not used, modified, saved, deleted, in any way.
   %
   %  BUILDPROJECTDIRECTORY() without any input or output arguments builds a
   %  project directory file named `projectdirectory.mat` and saves it in the
   %  `PROJECTDIRECTORYPATH` folder.
   %
   %  PROJECTLIST = BUILDPROJECTDIRECTORY() returns the project list saved in
   %  projectdirectory.mat.
   %
   %  PROJECTLIST = BUILDPROJECTDIRECTORY('REBUILD') rebuilds the project
   %  directory from scratch, retaining the `activefiles` property of the
   %  current directory for projects that exist in the existing and rebuilt
   %  directory.
   %
   %  PROJECTLIST = BUILDPROJECTDIRECTORY('REBUILD', 'DRYRUN') returns the
   %  project list that would be saved but does not save it.
   %
   % See also: workon, workoff, addproject, manager
   %
   % Updates
   % 19 Jan 2023 - appended projname to projectlist.activefolder and renamed
   % projectlist.folder to projectlist.parentfolder
   % 19 Jan 2023 - added 'activefolder' attribute to allow projects associated
   % with folders other than their namesake
   % 23 Nov 2022 - add projects in USERPROJECTPATH using appendprojects
   % 23 Nov 2022 - remove entries that are not directories

   % NOTE: I started to add a method to "repairpaths" if I move a project and
   % other projects have files from it in their activefiles attribute (or if
   % files are moved in general). But if the files are anywhere on the path and
   % have a unique name (or are found by which first), then reopenfiles will
   % find them and open them next time the project is activated, and then the
   % directory will be updated when workoff is called or finish.

   % parse inputs
   switch nargin
      case 1
         % the first option is either 'rebuild' or 'dryrun'
         validatestring(varargin{1},{'rebuild','dryrun'},mfilename,'option',1);
      case 2
         % if the first option is 'rebuild', the second option can be 'dryrun'.
         validatestring(varargin{2},{'dryrun'},mfilename,'option',2);
   end

   % Set the options to true or false.
   opts = optionParser({'rebuild','dryrun'},varargin(:));

   % Warn if no rebuild or dryrun options are passed in.
   if nargin == 0
      opts = buildwarning(opts);
   end

   % Read the directory into memory.
   fname = fullfile(getenv('PROJECTDIRECTORYPATH'), 'projectdirectory.mat');

   % Build the project list (opts.rebuild==true uses the rebuild option).
   projectlist = buildprojectlist(opts);

   % Save the project directory.
   if not(opts.dryrun)
      save(fname, 'projectlist');
   end

   % Return the project directory list.
   if nargout == 1
      varargout{1} = projectlist;
   end
end

%%
function opts = buildwarning(opts)

   msg1 = 'Building project directory.';
   msg2 = 'Warning: this will overwrite the existing directory if it exists.';
   msg3 = 'Use option ''rebuild'' to rebuild the project directory and preserve existing directory attributes.';
   msg4 = 'Press ''y'' to continue saving the new directory, or any other key to abort.';
   msg = [newline msg1 newline msg2 newline msg3 newline msg4 newline];

   commandwindow;
   str = input(msg,'s');

   if string(str) == "y"
      opts.dryrun = false;
   else
      opts.dryrun = true;
   end
end

%%
function projectlist = buildprojectlist(opts)

   projectpath = getenv('MATLABPROJECTPATH');
   projectlist = getlist(projectpath,'*');
   projectlist = struct2table(projectlist);
   projectlist = appendprojects(projectlist); % 23 Nov 2022
   projectlist = projectlist(logical(projectlist.isdir), :); % 23 Nov 2022

   % Decided to hold off on this b/c the catting of folder and name may be
   % scattered throughout other functions. Could add a 'projectfolder' attribute.
   % rename 'folder' to 'parentfolder'
   % projectlist = renamevars(projectlist,'folder','parentfolder');

   % Add a 'default' project.
   defaultproj = projectlist(end,:);
   defaultproj.name = {'default'};
   try
      % Note: $HOME/MATLAB not matfunclib. This is the 'default' project.
      defaultproj.folder = getenv('MATLABUSERPATH');
   catch
      defaultproj.folder = userpath;
   end
   projectlist = [projectlist; defaultproj];

   % Add empty custom attributes: 'activefiles', 'activeproject',
   % 'activefolder', and 'linkedproject'. The others are created by dir().
   index = 1:size(projectlist, 1);
   projectlist.activefiles(index) = {''};
   projectlist.activeproject(index) = false;
   projectlist.activefolder = fullfile(projectlist.folder, projectlist.name);
   projectlist.linkedproject(index) = {''};

   % IF FIRST TIME WE'RE DONE HERE SO FOR DRYRUN OR DEBUGGING CHECK PROJECTLSIT

   % "rebuild" option preserves the existing custom attributes.
   if opts.rebuild
      projectlist = rebuildprojectlist(projectlist);
   end
end

%%
function projectlist = appendprojects(oldprojectlist)

   % Temporary update - use this path as an alternate instead
   projectpath = getenv('MATLAB_PROJECTS_PATH');
   if ~isempty(projectpath)
      projectlist = getlist(projectpath, '*');
      projectlist = struct2table(projectlist);
      projectlist = [oldprojectlist; projectlist];
   else
      projectlist = oldprojectlist;
   end
end

%%
function newlist = rebuildprojectlist(newlist)

   % These are the attributes which are transferred from old to new list.
   keepatts = {'activefiles','activeproject','activefolder','linkedproject'};

   % Read the current project directory
   oldlist = readprjdirectory(getprjdirectorypath);

   % find projects in both the old and new directories
   for n = 1:numel(keepatts)

      thisatt = keepatts{n};

      for m = 1:size(newlist,1)

         % Check if this project name exists in the old list.
         if ismember(newlist.name(m), oldlist.name)

            % Find the index on the old list, to retrieve the attrs.
            idx_old = find(ismember(oldlist.name, newlist.name(m)));
            idx_new = find(ismember(newlist.name, oldlist.name(m)));

            % This checks if both the name and the folder match. If duplicate
            % project names are allowed, this can be used to determine if the
            % duplicate projects exist in different folders, and let it pass ...
            % or actually I think this was used to prevent copying over
            % attributes from one to the other, and I had the note:
            % "but it interferes with the case where the projects folder was
            % moved or redefined"
            % I am not sure why this was commented out for that case need to
            % review the logic
            % idx = find(ismember(oldlist.name, newlist.name(m)) & ...
            %   ismember(oldlist.folder, newlist.folder(m)));

            if numel(idx_old) > 1
               % This occurred most recently when there was a "snowmodel" folder
               % in both myprojects/matlab and MATLAB/projects. I resolved it by
               % manually combining the two folders into the MATLAB/projects
               % folder and manually removing the myprojects/matlab/snowmodel
               % entry from the projectdirectory.mat file. This shows that there
               % needs to be a "pruneprojects" or similar option to rebuild the
               % projectdirectory file which specifically checks for entries
               % with folders which no longer exist (since I deleted the
               % myprojects/matlab/snowmodel folder but still got the error here
               % b/c the entry still existed in projectdirectory.mat). But this
               % could still have the same problem that this section originally
               % addressed which is the case where the MATLAB_PROJECTS_PATH
               % changes, there's a chicken and egg issue, since the
               % "pruneprojects" described above would find the folders dont
               % exist b/c they're in the new folder.

               % I started to add this but I think what is actually needed is to
               % determine if the duplicate projects have "keepatts" b/c what we
               % are trying to avoid is copying over the wrong attributes ...
               if numel(idx_new) > 1

               else
                  % Issue an error to handle duplicates on a case by case basis
                  % until a robust method is worked out.
                  error('duplicate projects found')
               end

            elseif numel(idx_old) == 0
               continue

            elseif numel(idx_old) == 1

               newlist.(thisatt)(m) = oldlist.(thisatt)(idx_old);
            end
         end
      end
   end

   % Now that the attrs have been transferred from the old list to the new list,
   % check if any projects exist in the old list which have non-empty attrs but
   % are not in the new list. This occurred when the project folders were
   % redefined (USERPROJECTPATH was replaced with MATLAB_PROJECTS_PATH), and one
   % project was left behind in USERPROJECTPATH.
   in_old_not_new = ~ismember(oldlist.name, newlist.name);

   % NOTE: Need to NOT rebuild on new computer until all projects exist, at
   % minimum the folders e.g. 'baseflow' exists on work but not personal
   % computer, so it

   activestate = oldlist.activeproject;
   activefiles = oldlist.activefiles;
   linkedprojs = oldlist.linkedproject;

   % NOTE: 'activefolder' is not updated above. This is the only "keepatts" not
   % updated. Cannot remember why. Maybe when redefining USERPOJECTSPATH (or
   % whichever env var it was) that was needed. But when I moved
   % myprojects/matlab to work/projects/matlab, and tried rebuilding, this was
   % problematic b/c the activefolder needs to be updated for stuff like
   % cdproject to work.


   if any(in_old_not_new & activestate)
      error('currently active project missing from new directory')
   end

   % This finds old projects with non-empty attrs missing from new
   keep = in_old_not_new & ...
      ( in_old_not_new & cellfun(@(c) ~isempty(c), activefiles) ...
      | in_old_not_new & cellfun(@(c) ~isempty(c), linkedprojs) );

   newlist = [newlist; oldlist(keep, :)];

   % This could almost be sufficient to achieve the entire operation, but since
   % "newlist" has the new folder, but oldlist has the attrs, it's still a few
   % more steps to combine them from here, so I just retained the loop above.
   %
   % in_old_and_new = ismember(oldlist.name, newlist.name);
   % keep = in_old_and_new ...
   %    | in_old_not_new & cellfun(@(c) ~isempty(c), activefiles) ...
   %    | in_old_not_new & cellfun(@(c) ~isempty(c), linkedprojs);
end
