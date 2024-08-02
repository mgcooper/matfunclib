function msg = copytoolboxtemplate(projectname, opts)
   %COPYTOOLBOXTEMPLATE Copy toolbox template to project folder.
   %
   %  MATLAB_PROJECTS_PATH/projectname.
   %
   % See also

   arguments
      projectname (1, :) char
      opts.safecopy (1, 1) logical = false
      opts.forcecopy (1, 1) logical = false
   end

   % NOTE: safecopy means copy into a tempdir inside the destination path.
   % forcecopy means copy into the project folder even if it exists (should only
   % be done if its empty, and may be blocked by copyfile anyway). If neither
   % are set it means just copy the template to the destination. But if safecopy
   % is true, then set forcecopy false.
   if opts.safecopy
      opts.forcecopy = false;
   end

   % Set required paths
   PROJECT_NAME = projectname;
   MATLAB_PROJECTS_PATH = getenv('MATLAB_PROJECTS_PATH');
   TOOLBOX_TEMPLATE_PATH = getenv('MATLAB_TOOLBOX_TEMPLATE_PATH');

   if isempty(TOOLBOX_TEMPLATE_PATH)
      eid = ['custom:' mfilename ':toolboxTemplatePathUndefined'];
      msg = 'set MATLAB_TOOLBOX_TEMPLATE_PATH environment variable';
      error(eid, msg);
   end

   % Determine if PROJECTNAME 1) is a fullpath, 2) points to an existing project
   % folder, and 3) is an existing project. If not, make the folder and copy the
   % toolbox template there.

   % These are designed for the case where projectname is a full path. They
   % confirm if 1) the path is to a folder within MATLAB_PROJECTS_PATH
   % (PROJECT_PARENT_ISVALID), and 2) if the projectname folder already exists.

   PROJECT_PARENT_EXISTS = false;
   PROJECT_FOLDER_EXISTS = false;

   WAS_COPIED = false;

   if isempty(fileparts(PROJECT_NAME))
      % PROJECT_NAME is a char not full path, build the full path. This is the
      % simplest case b/c it enforces MATLAB_PROJECTS_PATH as the parent.

      PROJECT_FOLDER_PATH = fullfile(MATLAB_PROJECTS_PATH, PROJECT_NAME);
      PROJECT_FOLDER_EXISTS = isfolder(PROJECT_FOLDER_PATH);
      PROJECT_PARENT_EXISTS = true; % it was just set to MATLAB_PROJECTS_PATH

      if not(PROJECT_FOLDER_EXISTS)
         % It's safe to copy the toolbox/ template to the projectname/ folder.
         copyfile(TOOLBOX_TEMPLATE_PATH, PROJECT_FOLDER_PATH)
         WAS_COPIED = true;
      end
   else
      % This case is more complicated than it may seem. It's necessary to first
      % check if the project folder exists. If so, check if its empty. If not,
      % check if the parent folder exists and if so, make the project there.

      % Check if PROJECT_NAME is a full path.
      PROJECT_FOLDER_EXISTS = isfolder(PROJECT_NAME);
      PROJECT_PARENT_EXISTS = isfolder(fileparts(PROJECT_NAME));

      % Assign PROJECT_NAME to the PROJECT_FOLDER_PATH and vise versa.
      PROJECT_FOLDER_PATH = PROJECT_NAME;
      [~, PROJECT_NAME] = fileparts(PROJECT_FOLDER_PATH);

      % If it exists, this is likely a mistake, unless the folder is empty.
      if PROJECT_FOLDER_EXISTS

         % Use this to investigate further.
         % [isInDirectory, hasProjectFolder] = isproject(PROJECT_NAME);

         EXISTING_FOLDER_ISEMPTY = ...
            numel(rmdotfolders(dir(PROJECT_FOLDER_PATH))) == 0;

         if opts.forcecopy || EXISTING_FOLDER_ISEMPTY
            % Copy the toolbox template into the (empty) project folder
            copyfile(TOOLBOX_TEMPLATE_PATH, PROJECT_FOLDER_PATH)
            WAS_COPIED = true;

         elseif opts.safecopy
            % Copy the toolbox template into a temp folder
            PROJECT_FOLDER_PATH = tempfile(PROJECT_FOLDER_PATH);
            copyfile(TOOLBOX_TEMPLATE_PATH, PROJECT_FOLDER_PATH);
            WAS_COPIED = true;

            warning( ...
               'Performing safe copy of toolbox template to temp path:\n %s', ...
               PROJECT_FOLDER_PATH)
         else
            % Return an error
            error('project %s exists and is not empty, aborting', PROJECT_NAME)
         end

      elseif PROJECT_PARENT_EXISTS
         % This means the path is valid and the project folder does not exist.
         % This is the most straightforward case when PROJECT_NAME was passed in
         % as a full path. If here, PROJECT_FOLDER_EXISTS is false, so copy the
         % template directly to the new project path.

         % create the project by copying the toolbox template to the folder
         copyfile(TOOLBOX_TEMPLATE_PATH, PROJECT_FOLDER_PATH)
         WAS_COPIED = true;
      end
   end

   msg.WAS_COPIED = WAS_COPIED;
   msg.PROJECT_FOLDER_EXISTS = PROJECT_FOLDER_EXISTS;

   % If here, the copy was successful. Delete the .prj file and sandbox/ folder.
   %
   % NOTE: If safecopy==true, PROJECT_FOLDER_PATH is explicitly reassigned to a
   % temppath. This is necessary. Once here, PROJECT_FOLDER_PATH must be the
   % actual destination where the template was copied.

   if WAS_COPIED
      % Remove the ToolboxTemplate.prj file and sandbox/ folder
      deleteUnwantedFiles(TOOLBOX_TEMPLATE_PATH, PROJECT_FOLDER_PATH)
   else
      warning(['Toolbox template was not copied. Confirm the following:\n' ...
         ' source: %s \n destination: %s'], ...
         TOOLBOX_TEMPLATE_PATH, PROJECT_FOLDER_PATH)
   end

   % % Not implemented, but an idea - either copy the template, or do nothing
   % function copyOnCleanup(docopy, TOOLBOX_TEMPLATE_PATH, PROJECT_FOLDER_PATH)
   %
   % ifelse(docopy, copyfile(TOOLBOX_TEMPLATE_PATH, PROJECT_FOLDER_PATH), [])
end

function deleteUnwantedFiles(TOOLBOX_TEMPLATE_PATH, PROJECT_FOLDER_PATH)

   % When the toolbox is copied, several files are copied which should be
   % deleted from the new project:
   %
   % ToolboxTemplate.prj
   % sandbox/

   previousState = recycle("on");
   cleanupJob = onCleanup(@() recycle(previousState));

   % Confirm the actual template path has not been set to the destination path,
   % e.g., due to rewritten code in the main function overlooking the potential
   % for this critical error.
   assert(~strcmp(TOOLBOX_TEMPLATE_PATH, PROJECT_FOLDER_PATH))

   % Double check against the env var.
   assert(~strcmp(getenv('MATLAB_TOOLBOX_TEMPLATE_PATH'), PROJECT_FOLDER_PATH))

   % This is the file we will delete.
   copiedProjectFile = fullfile(PROJECT_FOLDER_PATH, 'ToolboxTemplate.prj');

   % Confirm the copied file exists, then delete it (send to recycle bin).
   assert(isfile(copiedProjectFile))
   delete(copiedProjectFile)

   %%%% Part 2: the sandbox/ folder

   sandboxFolder = fullfile(PROJECT_FOLDER_PATH, 'sandbox');
   if isfolder(sandboxFolder)

      % TODO: Ask the user to confirm by pressing 'y'? Shouldn't be necessary.
      % Only concern is the edge case where the project already exists. BUT
      % THATS WHAT SAFECOPY IS FOR. This function is called by mkproject which
      % checks if the destination exists and if so, safecopy copies the template
      % to a tempdir (PROJECT_FOLDER_PATH will be a tempdir inside the destination).

      [status, message, ~] = rmdir(sandboxFolder, 's');

      if status
         % Success. Make a new, empty sandbox folder.
         mkdir(sandboxFolder)
      else
         % Failure. Print the message.
         disp(message)
      end
   end
end
