function [requirementsList, urlList] = installRequiredFiles(requiredFiles, kwargs)
   %INSTALLREQUIREDFILES Install required files from Github.
   %
   %  INSTALLREQUIREDFILES(REQUIREDFILES)
   %  INSTALLREQUIREDFILES(PROJECTPATH=PATHNAME)
   %  INSTALLREQUIREDFILES(REQUIREMENTSFILE=FILENAME)
   %
   %  INSTALLREQUIREDFILES(_, INSTALLPATH=PATHNAME)
   %  INSTALLREQUIREDFILES(_, LOCALSOURCEPATH=PATHNAME)
   %  INSTALLREQUIREDFILES(_, IGNOREFOLDER=FOLDERNAME)
   %  INSTALLREQUIREDFILES(_, REMOTEREPONAME=REPONAME)
   %  INSTALLREQUIREDFILES(_, REMOTEBRANCH=BRANCHNAME)
   %  INSTALLREQUIREDFILES(_, GITHUBUSERNAME=USERNAME)
   %  INSTALLREQUIREDFILES(_, DRYRUN=TRUE)
   %
   % Description
   %
   %  The use case for this function is to install a list of required files
   %  from GitHub. The list could be shipped with a toolbox, and third party
   %  users run an install script which reads the requirements list and installs
   %  them from GitHub. Alternatively, the toolbox maintainer can use this
   %  function to package the requirements with the toolbox.
   %
   % Input Arguments
   %
   %  The following arguments control what files get installed: Either a
   %  pre-existing list of requirements (REQUIREDFILES or REQUIREMENTSFILE), or
   %  a list of requirements generated internally by this function for a
   %  specific project folder (PROJECTPATH), optionally ignoring any
   %  requirements for files contained in IGNOREFOLDER.
   %
   %  REQUIREDFILES - (optional, positional) a list of required functions. If
   %  not provided or if empty, the requirements are read from
   %  REQUIREMENTSFILE when one is supplied; otherwise the requirements for
   %  all files in the PROJECTPATH folder are installed.
   %
   %  PROJECTPATH - (optional, name-value) a full path (scalar text) to a
   %  folder. Requirements for all files within this folder are generated and
   %  installed. In this bootstrapped-toolbox copy the default PROJECTPATH is
   %  the project root resolved by projectpath(), and the default install
   %  location is the "dependencies" subfolder of the toolbox folder resolved
   %  by toolboxpath(). Specify the optional INSTALLPATH argument to control
   %  where dependencies are installed.
   %
   %  REQUIREMENTSFILE - (optional, name-value) a full path to a file containing
   %  a list of required files. Two formats are supported: a .mat file
   %  containing a variable named "missingFiles" (preferred) or
   %  "requiredFiles" (the format GETREQUIREDFILES writes when called with
   %  SAVEREQUIREMENTSFILE=TRUE), or a plain-text file with one file name or
   %  path per line (blank lines and lines starting with # are ignored). If
   %  REQUIREDFILES is also supplied (non-empty), it takes precedence and
   %  REQUIREMENTSFILE is ignored.
   %
   %  NOTE: If none of the three arguments above are supplied, the default
   %  behavior installs the requirements of the project root resolved by
   %  projectpath() into the toolbox "dependencies" folder resolved by
   %  toolboxpath().
   %
   %  IGNOREFOLDER - A folder or array of folder names to be ignored when
   %  generating the list of requirements for the PROJECTPATH folder.
   %  IGNOREFOLDER should contain a single folder name or array of folder names
   %  which are subfolders of PROJECTPATH. Use this option to ignore a scratch/
   %  or testbed/ or sandbox/ or examples/ folder which is not under source
   %  control and is not distributed with the toolbox or project.
   %
   %  These arguments control how the requirements are found and/or resolved:
   %
   %  LOCALSOURCEPATH - folder with local versions of the required files.
   %  REMOTEREPONAME - remote (Github) repo for the localSourcePath.
   %  REMOTEBRANCH - branch to use when downloading from the remote Github repo.
   %  GITHUBUSERNAME - GitHub username for the REMOTEREPONAME.
   %
   %  These arguments control if and where files are installed:
   %
   %  INSTALLPATH - full path to location where files are installed. The default
   %  value is a folder named "dependencies" in the toolbox folder.
   %  DRYRUN - logical flag controlling whether files are installed. If true,
   %  nothing is downloaded; the resolved file and url lists are returned and
   %  printed to the screen. The default value is false (files are installed).
   %
   % See also: getRequiredFiles

   arguments
      %%% The following arguments control what gets installed:
      requiredFiles (:, :) string {mustBeText} ...
         = []

      kwargs.requirementsFile (1, :) string {mustBeTextScalar} ...
         = ""

      kwargs.projectPath (1, :) string {mustBeFolder} ...
         = projectpath()

      kwargs.ignoreFolder (1, :) string ...
         = "testbed"

      %%% The following arguments control how requirements are found:
      kwargs.localSourcePath (1, :) {mustBeFolder} ...
         = getenv('MATLAB_FUNCTION_PATH')

      kwargs.remoteRepoName (1, :) string {mustBeTextScalar} ...
         = "matfunclib"

      kwargs.remoteBranch (1, :) string {mustBeTextScalar} ...
         = "main"

      kwargs.GitHubUserName (1, :) string {mustBeTextScalar} ...
         = getenv('GITHUB_USER_NAME')

      %%% The following arguments control where and if files get installed:

      % installPath default is derived in parseargs (the toolbox
      % "dependencies" folder); the "" sentinel distinguishes "not supplied"
      % from an explicit path.
      kwargs.installPath (1, :) string {mustBeTextScalar} ...
         = ""

      kwargs.dryrun (1, 1) logical {mustBeNumericOrLogical} ...
         = false
   end

   [projectPath, ignoreFolder, localSourcePath, remoteSourcePath, ...
      requirementsFile, installPath] = parseargs(kwargs);

   % Remember current folder and go to folder for external dependencies.
   % The job cleanup object restores pwd: explicitly via the delete(job)
   % below on the normal path, or at scope exit if an error is thrown.
   job = withcd(projectPath);

   % Find the required files: an explicit list wins, then a requirements
   % file, then generation from the project folder.
   if all(isempty(requiredFiles))
      if strlength(requirementsFile) > 0
         requiredFiles = readRequirementsFile(requirementsFile);
      else
         % referenceList is the project itself: its own files count as
         % satisfied, independent of which manager project is active.
         requiredFiles = getRequiredFiles(projectPath, ...
            "ignoreList", ignoreFolder, "referenceList", projectPath);
         requiredFiles = requiredFiles.missingFiles;
      end
   end

   % Build a url list for the remote files
   [requirementsList, urlList] = remoteDependencyList( ...
      requiredFiles, projectPath, localSourcePath, remoteSourcePath);

   % Option to install the missing requirement locally
   fileList = installPath + filesep + requirementsList;
   if not(kwargs.dryrun)

      if ~isfolder(installPath)
         mkdir(installPath)
      end
      for n = 1:numel(requirementsList)
         try
            websave(fileList(n), urlList(n));
         catch ME
            warning('Failed to download file: %s\nReason: %s', ...
               requirementsList(n), ME.message);
         end
      end
   else
      fprintf(1, "\n Files will be installed to: \n %s \n", installPath)
      fprintf(1, "\n The following files will be installed: \n")
      disp(urlList)
   end

   % Restore the original working directory.
   delete(job)
end

%% Local Functions
function [projectPath, ignoreFolder, localSourcePath, ...
      remoteSourcePath, requirementsFile, installPath] = parseargs(kwargs)

   % Retrieve the Github user name
   if isempty(kwargs.GitHubUserName)
      error('Set "GitHubUserName" or environment variable "GITHUB_USER_NAME"')
   else
      GITHUB_USER_NAME = kwargs.GitHubUserName;
   end

   % Note: for general use, this should be userpath or MATLABPATH, I think.
   if isempty(kwargs.localSourcePath)
      localSourcePath = userpath();
   else
      localSourcePath = kwargs.localSourcePath;
   end

   if isempty(kwargs.remoteRepoName)
      error(['Set "remoteRepoName" to the GitHub repository ' ...
         'which hosts the required files'])
   else
      GITHUB_URL = 'https://raw.githubusercontent.com/';
      remoteSourcePath = strcat(GITHUB_URL, GITHUB_USER_NAME, '/', ...
         kwargs.remoteRepoName, '/', kwargs.remoteBranch);

      % This works too:
      %GITHUB_URL = 'https://github.com/';
      %remotesource = strcat(GITHUB_URL, GITHUB_USER_NAME, '/', ...
      %   Opts.remoteRepoName, '/raw/', Opts.remotebranch);
   end

   % Pull out required args and remaining optional args
   projectPath = kwargs.projectPath;
   requirementsFile = kwargs.requirementsFile;

   % Derive the documented installPath default (the toolbox "dependencies"
   % folder) when the caller did not supply one. This bootstrapped-copy
   % default intentionally differs from the matfunclib canonical, which
   % derives it from PROJECTPATH.
   if strlength(kwargs.installPath) == 0
      installPath = fullfile(toolboxpath(), "dependencies");
   else
      installPath = kwargs.installPath;
   end

   % Full path to ignore folder
   ignoreFolder = fullfile(projectPath, kwargs.ignoreFolder);
end

function requiredFiles = readRequirementsFile(requirementsFile)
   %READREQUIREMENTSFILE Read a required-files list from a requirements file.
   %
   % Supports the .mat format written by getRequiredFiles
   % (saveRequirementsFile=true), preferring its "missingFiles" variable and
   % falling back to "requiredFiles", and plain text with one entry per line
   % (blank lines and #-comment lines ignored).

   if ~isfile(requirementsFile)
      error('installRequiredFiles:requirementsFileNotFound', ...
         'requirementsFile not found: %s', requirementsFile)
   end

   [~, ~, ext] = fileparts(requirementsFile);
   if strcmpi(ext, '.mat')
      vars = load(requirementsFile);
      if isfield(vars, 'missingFiles')
         requiredFiles = string(vars.missingFiles);
      elseif isfield(vars, 'requiredFiles')
         requiredFiles = string(vars.requiredFiles);
      else
         error('installRequiredFiles:badRequirementsFile', ...
            ['requirementsFile %s must contain a variable named ' ...
            '"missingFiles" or "requiredFiles"'], requirementsFile)
      end
   else
      % Plain text: one file per line; ignore blanks and # comments.
      requiredFiles = strtrim(readlines(requirementsFile));
      requiredFiles(requiredFiles == "") = [];
      requiredFiles(startsWith(requiredFiles, "#")) = [];
   end
   requiredFiles = reshape(requiredFiles, 1, []);
end

function [requirementsList, urlList] = remoteDependencyList( ...
      requiredFiles, projectPath, localsource, remotesource)
   %REMOTEDEPENDENCYLIST Get a list of remote url's to function dependencies.

   % This operates on one file at a time

   [requirementsList, urlList] = deal(strings(length(requiredFiles), 1));

   % For each dependency
   for ifile = 1:length(requiredFiles)

      % Get the file name with extension
      [requiredFilePath, requiredFileName, ext] = fileparts(requiredFiles{ifile});
      requiredFileName = strcat(requiredFileName, ext);

      if skipfile(requiredFileName, requiredFilePath, ...
            requirementsList, projectPath)
         continue
      end

      % If the required file exists in the local source repo, add it to the
      % requirementsList and build a full path to the remote file.

      % This was in the icemodel version:
      % Note - this is problematic if the requiredFiles contain files which are
      % not in localSourcePath e.g. if one project depends on another. So this
      % needs to be refactored to work with localSourcePaths (plural).

      if contains(requiredFilePath, localsource)

         % Add file names to list of external depencies
         requirementsList(ifile) = requiredFileName;

         % Get the subfolder path relative to the top-level source repo
         relativePath = erase(requiredFilePath, localsource);
         relativePath = strrep(relativePath, filesep , '/');
         if relativePath(1) == filesep
            relativePath = relativePath(2:end);
         end

         % Use '/' not fullfile b/c fullfile is platform specific
         urlList(ifile) = remotesource + '/' + relativePath + '/' ...
            + requirementsList(ifile);
      end
   end
   requirementsList(requirementsList == "") = [];
   urlList(urlList == "") = [];
   assert(all(endsWith(urlList, requirementsList)))
end

function tf = skipfile(requiredFileName, requiredFilePath, ...
      requirementsList, projectPath)

   [~, ~, ext] = fileparts(requiredFileName);

   % skip this file if it is the target function, a mex file, already found,
   % or already satisfied b/c it exists in the projectPath.
   tf = ...
      strcmp(ext, '.mex') | ...
      any(strcmpi(requiredFileName, requirementsList)) | ...
      contains(requiredFilePath, projectPath);
end
