function msg = copytoolboxtemplate(projectname, opts)
   %COPYTOOLBOXTEMPLATE Copy toolbox template to MATLABPROJECTPATH/projectname.
   %
   %
   % See also

   arguments
      projectname (1, :) char
      opts.forcecopy (1, 1) logical = false
      opts.safecopy (1, 1) logical = false
   end

   % Set required paths
   PROJECT_NAME = projectname;
   MATLAB_PROJECTS_PATH = getenv('MATLAB_PROJECTS_PATH');
   MATLAB_TOOLBOX_TEMPLATE_PATH = getenv('MATLAB_TOOLBOX_TEMPLATE_PATH');

   % Build the full path to the toolbox template
   tbxtemplate = MATLAB_TOOLBOX_TEMPLATE_PATH;

   if isempty(tbxtemplate)
      eid = ['custom:' mfilename ':toolboxTemplatePathUndefined'];
      msg = 'set MATLAB_TOOLBOX_TEMPLATE_PATH environment variable';
      error(eid, msg);
   end

   % Determine if PROJECTNAME 1) is a fullpath, 2) points to an existing project
   % folder, and 3) is an existing project. If not, make the folder and copy the
   % toolbox template there.

   % These are designed for the case where projectname is a full path. They
   % confirm if 1) the path is to a folder within MATLAB_PROJECTS_PATH
   % (isValidParentPath), and 2) if the projectname folder already exists.
   isValidParentPath = false;
   isExistingProject = false;

   WAS_COPIED = false;

   if isempty(fileparts(PROJECT_NAME))
      % PROJECT_NAME is a char not full path, build the full path
      tbxpath = fullfile(MATLAB_PROJECTS_PATH, PROJECT_NAME);

      isValidParentPath = true;
      isExistingProject = isfolder(tbxpath);

      % Copy the toolbox template, after one more check
      if ~isExistingProject
         copyfile(tbxtemplate, tbxpath)
         WAS_COPIED = true;
      end
   else
      %PROJECT_NAME could be a full path

      % Check if PROJECT_NAME is a valid project folder
      isValidParentPath = strcmp(fileparts(PROJECT_NAME), MATLAB_PROJECTS_PATH);

      % Check if tbxname is an existing project folder
      isExistingProject = isValidParentPath && isfolder(PROJECT_NAME);

      % Removed the if around this. There's no harm in setting these, the
      % side effects only occur if the path is valid, and this way tbxpath can
      % be used in the final ~WAS_COPIED warning message. Note that the
      % PROJECT_NAME can be a full path to an existing project, but it could be
      % an "invalid" parent path if its not inside MATLAB_PROJECTS_PATH.

      % if isValidParentPath || isExistingProject
      tbxpath = PROJECT_NAME;
      [~, tbxname] = fileparts(tbxpath);
      % end

      % If its an existing project, this is likely a mistake
      if isExistingProject

         % Use this to investigate further.
         % [isInDirectory, hasProjectFolder] = isproject(tbxname);

         if numel(rmdotfolders(dir(tbxpath))) == 0 || opts.forcecopy == true
            % Copy the toolbox template into the (empty) project folder
            copyfile(tbxtemplate, tbxpath)
            WAS_COPIED = true;

         elseif opts.safecopy == true
            % Copy the toolbox template into a temp folder
            tbxpath = tempfile(tbxpath);
            copyfile(tbxtemplate, tbxpath);
            WAS_COPIED = true;
         else
            % Return an error
            error('project %s exists and is not empty, aborting', PROJECT_NAME)
         end

      elseif isValidParentPath
         % This means the path is valid but the project folder does not exist

         % create the project by copying the toolbox template to the folder
         copyfile(tbxtemplate, tbxpath)
         WAS_COPIED = true;
      end
   end

   msg.WAS_COPIED = WAS_COPIED;
   msg.isValidProjectPath = isValidParentPath;
   msg.isExistingProject = isExistingProject;

   % If here, the copy was successful. Delete the sandbox/ folder.
   % NOTE: in one case above, tbxpath is reset to a temp path. Any similar
   % resets must be made so tbxpath here is the actual final one.
   if WAS_COPIED

      if isfolder(fullfile(tbxpath, 'sandbox'))
         % TODO: Ask the user to confirm by pressing 'y'. For now, just delete the
         % files in this folder manually.
      end
   else
      warning(['Toolbox template was not copied. Confirm the following:\n' ...
         ' source: %s \n destination: %s'], tbxtemplate, tbxpath)
   end

   % % Not implemented, but an idea - either copy the template, or do nothing
   % function copyOnCleanup(docopy, tbxtemplate, tbxpath)
   %
   % ifelse(docopy, copyfile(tbxtemplate, tbxpath), [])
end
