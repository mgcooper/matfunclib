function [requirementsList, urlList] = resolveDependencies(requiredFiles, Opts)
   %RESOLVEDEPENDENCIES Download required dependencies from Github.
   %
   % resolveDependencies(requiredFiles)
   % resolveDependencies(requiredFiles, "projectFolder", folder)
   % resolveDependencies(requiredFiles, "requirementsFile", file)
   % resolveDependencies(requiredFiles, "saveRequirementsFile", true)
   % resolveDependencies(requiredFiles, "localSourceFolder", folder)
   % resolveDependencies(requiredFiles, "remoteRepoName", reponame)
   % resolveDependencies(requiredFiles, "remoteBranch", branchname)
   % resolveDependencies(requiredFiles, "GitHubUserName", username)
   % resolveDependencies(requiredFiles, "installMissing", true)
   %
   % Input Arguments:
   % 
   % requiredFiles - the target function that other functions depend on.
   % projectFolder - folder that needs the required files.
   % localSourceFolder - folder with local versions of the dependencies.
   % remoteRepoName - Github repo for the localSourceFolder.
   % remoteBranch - Branch to use when downloading from the remote Github repo.
   %
   % See also: getDependencies

   arguments
      requiredFiles
      Opts.projectFolder = pwd()
      Opts.requirementsFile = 'requirements.mat'
      Opts.saveRequirementsFile = true
      Opts.localSourceFolder = getenv('MATLABFUNCTIONPATH')
      Opts.remoteRepoName = "matfunclib"
      Opts.remoteBranch = "main"
      Opts.GitHubUserName = getenv('GITHUB_USER_NAME')
      Opts.installMissing (1,1) logical = false
   end

   % Retrieve the Github user name
   if isempty(Opts.GitHubUserName)
      error('Set "GitHubUserName" or environment variable "GITHUB_USER_NAME"')
   else
      GITHUB_USER_NAME = Opts.GitHubUserName;
   end

   % Note: for general use, this should be userpath or MATLABPATH, I think.
   if isempty(Opts.localSourceFolder)
      error('Set "localSourceRepo" or environment variable "MATLABFUNCTIONPATH"')
   else
      localsource = Opts.localSourceFolder;
   end

   if isempty(Opts.remoteRepoName)
      error('Set "remotesource" or environment variable "MATLABFUNCTIONPATH"')
   else
      GITHUB_URL = 'https://raw.githubusercontent.com/';
      remotesource = strcat(GITHUB_URL, GITHUB_USER_NAME, '/', ...
         Opts.remoteRepoName, '/', Opts.remotebranch);

      % This works too:
      %GITHUB_URL = 'https://github.com/';
      %remotesource = strcat(GITHUB_URL, GITHUB_USER_NAME, '/', ...
      %   Opts.remoteRepoName, '/raw/', Opts.remotebranch);
   end

   % Pull out required args and remaining optional args
   projectFolder = Opts.projectFolder;
   requirementsFile = Opts.requirementsFile;

   % Remember current folder and go to folder for external dependencies
   job = withcd(projectFolder);

   % Get required files - Commented this out in favor of passing them in from
   % getDependencies, but left for now to decide if this should be permanent.
   % Dependencies = getDependencies(requiredFiles);
   % requiredFiles = Dependencies.requiredFiles;

   % Build a url list for the remote files
   [requirementsList, urlList] = remoteDependencyList(requiredFiles, ...
      projectFolder, requiredFiles, localsource, remotesource);

   if Opts.installMissing
      savePath = fullfile(projectFolder, "dependencies");
      fileList = savePath + filesep + requirementsList;
      if ~isfolder(savePath)
         mkdir(savePath)
      end
      outFileList = strings(size(requirementsList));
      for n = 1:numel(requirementsList)
         try
            outFileList(n) = websave(fileList(n), urlList(n));
         catch ME
            warning('Failed to download file: %s\nReason: %s', requirementsList(n), ME.message);
         end
      end
   end
end

%% Local Functions

function [requiredFiles, requiredProducts] = findDependencies(functionName)

   [requiredFiles, requiredProducts] = ...
      matlab.codetools.requiredFilesAndProducts(functionName);

   requiredFiles = transpose(requiredFiles);
   %requiredFiles = cell2table(requiredFiles, 'VariableNames', ...
   %   {'RequiredFiles'});
end

function [requirementsList, urlList] = remoteDependencyList(functionName, ...
      projectFolder, requiredFiles, localsource, remotesource)
   %REMOTEDEPENDENCYLIST Get a list of remote url's to function dependencies.

   % This operates on one file at a time

   [requirementsList, urlList] = deal(strings(length(requiredFiles), 1));

   % For each dependency
   for ifile = 1:length(requiredFiles)

      % Get the file name with extension
      [requiredFilePath, requiredFileName, ext] = fileparts(requiredFiles{ifile});
      requiredFileName = strcat(requiredFileName, ext);

      if skipfile(functionName, projectFolder, requiredFileName, ...
            requiredFilePath, requirementsList)
         continue
      end

      % If the required file exists in the local source repo, add it to the
      % requirementsList and build a full path to the remote file.
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
         urlList(ifile) = remotesource + '/' + relativePath + '/' + requirementsList(ifile);
      end
   end
   requirementsList(requirementsList == "") = [];
   urlList(urlList == "") = [];
   assert(all(endsWith(urlList, requirementsList)))
end

function tf = skipfile(functionName, projectFolder, requiredFileName, ...
      requiredFilePath, requirementsList)

   [~, ~, ext] = fileparts(requiredFileName);

   % skip this file if it is the target function, a mex file, already found,
   % or already satisfied b/c it exists in the projectFolder.

   tf = ...
      strcmp(requiredFileName, functionName) | ...
      strcmp(ext, '.mex') | ...
      any(strcmpi(requiredFileName, requirementsList)) | ...
      contains(requiredFilePath, projectFolder);
end
