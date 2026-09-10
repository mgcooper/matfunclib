function [requirementsList, urlList, failedList, skippedList] = ...
      installRequiredFiles(requiredFiles, kwargs)
   %INSTALLREQUIREDFILES Install required files from GitHub or a local checkout.
   %
   %  INSTALLREQUIREDFILES(REQUIREDFILES)
   %  INSTALLREQUIREDFILES(PROJECTPATH=PATHNAME)
   %  INSTALLREQUIREDFILES(REQUIREMENTSFILE=FILENAME)
   %
   %  INSTALLREQUIREDFILES(_, INSTALLPATH=PATHNAME)
   %  INSTALLREQUIREDFILES(_, LOCALSOURCEPATH=PATHNAME)
   %  INSTALLREQUIREDFILES(_, IGNOREFOLDER=FOLDERNAME)
   %  INSTALLREQUIREDFILES(_, REFERENCELIST=PATHNAME)
   %  INSTALLREQUIREDFILES(_, REMOTEREPONAME=REPONAME)
   %  INSTALLREQUIREDFILES(_, REMOTEBRANCH=BRANCHNAME)
   %  INSTALLREQUIREDFILES(_, GITHUBUSERNAME=USERNAME)
   %  INSTALLREQUIREDFILES(_, SOURCE="local")
   %  INSTALLREQUIREDFILES(_, DRYRUN=TRUE)
   %
   % Description
   %
   %  The use case for this function is to install a list of required files
   %  from GitHub, or from a local checkout of the repository that holds
   %  them. The list could be shipped with a toolbox, and third party
   %  users run an install script which reads the requirements list and installs
   %  them from GitHub. Alternatively, the toolbox maintainer can use this
   %  function to package the requirements with the toolbox. SOURCE="local"
   %  copies them from the checkout beside it.
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
   %  path per line (blank lines and lines starting with # are ignored). A
   %  path relative to LOCALSOURCEPATH, such as "lib/name.m" or "./name.m"
   %  for a file at its root, names that one file; a bare name is looked
   %  up under LOCALSOURCEPATH and must be unique there. If REQUIREDFILES
   %  is also supplied (non-empty), it takes precedence and REQUIREMENTSFILE
   %  is ignored.
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
   %  REFERENCELIST - (optional, name-value) a folder whose files count as
   %  satisfied, so they are never installed. The default is PROJECTPATH.
   %  Name a folder above PROJECTPATH to vendor the requirements of one
   %  subfolder while the rest of the toolbox counts as present.
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
   %  SOURCE - "remote" (default) downloads each file from the GitHub
   %  repository with websave, which needs GITHUBUSERNAME. "local" copies
   %  each file with copyfile from the working copy under LOCALSOURCEPATH,
   %  with no network and no GITHUBUSERNAME. A maintainer vendors a
   %  toolbox's requirements this way from the checkout beside it.
   %  DRYRUN - logical flag controlling whether files are installed. If true,
   %  nothing is downloaded; the resolved file and url lists are returned and
   %  printed to the screen. The default value is false (files are installed).
   %
   % Output Arguments
   %
   %  REQUIREMENTSLIST - the file names installed, one per row. A file
   %  whose install failed is warned about and left out. With DRYRUN, the
   %  files that would be installed.
   %  URLLIST - the source of each file: its GitHub raw URL for
   %  SOURCE="remote", or its path under LOCALSOURCEPATH for SOURCE="local".
   %  FAILEDLIST - the file names whose install failed, one per row, so a
   %  caller can treat an incomplete install as an error.
   %  SKIPPEDLIST - the required file names that resolved nowhere under
   %  LOCALSOURCEPATH, or in several places, one per row. Each was warned
   %  about and left out. A MATLAB file under matlabroot is not listed.
   %
   % Resolving a file under LOCALSOURCEPATH
   %
   %  The installer uses a required file from LOCALSOURCEPATH when the
   %  file's resolved path lies under it. It looks a file up by name under
   %  LOCALSOURCEPATH when the file resolves elsewhere on the path (a copy
   %  in another library that shadows the LOCALSOURCEPATH copy) or is a
   %  bare name with no path. One match is used. The installer skips a name
   %  with no match under LOCALSOURCEPATH and warns, unless the name is a
   %  MATLAB file under matlabroot. It skips a name with several matches
   %  and warns with a list of them.
   %
   % See also: getRequiredFiles, undersource

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

      % "" means projectPath. parseargs resolves the default once
      % projectPath is known.
      kwargs.referenceList (1, :) string {mustBeTextScalar} ...
         = ""

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

      % "remote" downloads with websave. "local" copies the working copy
      % under localSourcePath.
      kwargs.source (1, 1) string ...
         {mustBeMember(kwargs.source, ["remote", "local"])} = "remote"

      kwargs.dryrun (1, 1) logical {mustBeNumericOrLogical} ...
         = false
   end

   % bindhelpers binds the functions this call depends on to handles
   % first, from this file's own folder. A file of the same name in the
   % caller's working folder (which may be the project being installed
   % into) then cannot shadow them.
   helpers = bindhelpers();

   % parseargs resolves every folder argument to an absolute, alias-free
   % path, so nothing below depends on the working folder and the
   % installer never changes it. A relative path resolves against the
   % caller's folder, and the project folder is never made current.
   [projectPath, ignoreFolder, localSourcePath, remoteSourcePath, ...
      requirementsFile, installPath, referenceList] = parseargs(kwargs, helpers);

   % Find the required files: an explicit list wins, then a requirements
   % file, then generation from the project folder.
   if all(isempty(requiredFiles))
      if strlength(requirementsFile) > 0
         requiredFiles = readRequirementsFile(requirementsFile, helpers);
      else
         % referenceList is the project itself unless the caller named a
         % folder: its files count as satisfied, independent of which
         % manager project is active. The walk runs with this file's
         % folder current, so the helpers getRequiredFiles calls by name
         % (listfiles among them) cannot resolve to a file in the
         % caller's folder either.
         job = changefolder(fileparts(mfilename('fullpath')));
         requiredFiles = helpers.getRequiredFiles(projectPath, ...
            "ignoreList", ignoreFolder, "referenceList", referenceList);
         delete(job)
         requiredFiles = requiredFiles.missingFiles;
      end
   end

   % Build the source list: a url per file for the remote files, and the
   % local path per file under localSourcePath.
   [requirementsList, urlList, localList, skippedList] = ...
      remoteDependencyList(requiredFiles, projectPath, localSourcePath, ...
      remoteSourcePath, helpers, probefoldscase(installPath, helpers));

   % The second output names where each file came from, so a local install
   % reports the paths it copied.
   if kwargs.source == "local"
      urlList = localList;
   end

   % Option to install the missing requirement locally
   fileList = installPath + filesep + requirementsList;
   failedList = strings(0, 1);
   if not(kwargs.dryrun)

      if ~helpers.isfolder(installPath)
         helpers.mkdir(installPath)
      end
      % A file landed when this call wrote it and a file is there
      % afterwards. A destination that existed before and survived a
      % failed overwrite is not this call's, so the existence test alone
      % would report it as landed.
      landed = false(size(requirementsList));
      for n = 1:numel(requirementsList)
         % Each transfer lands in a staging file inside a fresh staging
         % folder under the destination folder. The file moves into place
         % only after it is complete and writable. A transfer that throws
         % part way, or a later step that fails, leaves no partial file at
         % the destination and never removes a file that was there before
         % this call. tempname reserves the folder as unused, so the
         % staging file can collide with nothing. The staging file keeps
         % the destination's name, and with it the extension websave would
         % otherwise append from the url.
         stagingDir = string(helpers.tempname(installPath));
         stagingFile = fullfile(stagingDir, requirementsList(n));
         % The guard exists before the first write, so an interrupted
         % transfer leaves no staging folder behind either. It removes the
         % whole staging folder, so a file websave named differently from
         % the staging name goes with it.
         guard = onCleanup(@() removestaging(stagingDir, helpers));
         try
            helpers.mkdir(stagingDir)
            % copyfile and websave write into a folder of the destination
            % name, which would leave a nested copy nothing lists. A
            % folder in the way is a failure before any write. The test
            % raises an error, not an assert, so a caller-folder assert.m
            % cannot turn it off.
            if helpers.isfolder(fileList(n))
               error('installRequiredFiles:folderInTheWay', ...
                  'a folder is in the way at %s', fileList(n))
            end

            % A local copy needs no network. copyfile keeps the source
            % file read-only when it is, so clear that on the copy. The
            % name websave returns is the file it wrote, which is the
            % staging name unless websave changed it.
            if kwargs.source == "local"
               helpers.copyfile(localList(n), stagingFile, 'f');
               helpers.fileattrib(stagingFile, '+w');
            else
               stagingFile = string(helpers.websave(stagingFile, urlList(n)));
            end
            helpers.movefile(stagingFile, fileList(n), 'f');
            landed(n) = helpers.isfile(fileList(n));
            reason = "no file at the destination";
         catch ME
            reason = ME.message;
         end

         % Whatever failed, the staging folder must not stay behind:
         % nothing lists it, and a later run would not clear it.
         delete(guard)

         % The file test after the call catches a write that raised no
         % error and still left no file.
         if ~landed(n)
            warning('installRequiredFiles:installFailed', ...
               'Failed to install file: %s\nReason: %s', ...
               requirementsList(n), reason);
         end
      end

      % Report what landed, not what was planned. The loop above warned
      % about a file that failed, so it must not appear as installed.
      failedList = reshape(requirementsList(~landed), [], 1);
      requirementsList = reshape(requirementsList(landed), [], 1);
      urlList = reshape(urlList(landed), [], 1);
   else
      fprintf(1, "\n Files will be installed to: \n %s \n", installPath)
      fprintf(1, "\n The following files will be installed: \n")
      disp(urlList)
   end

   % % This was in a script in icom-msd project which I deleted but wanted to
   % % preserve this snippet. Seems most useful / applicable to this function.
   %
   % % Say fileName is a known dependency, and searchFolders are possible
   % % locations. This shows how to
   % searchFolders = {
   %    '/Users/coop558/MATLAB/projects/icom-msd/project/figures', ...
   %    '/Users/coop558/MATLAB/projects/icom-msd/project/scripts'};
   % fileName = 'riskscore.m';
   %
   % % Obtain the directory struct (will be empty if not found):
   % foundFiles = cellfun(@(folder) ...
   %    dir(fullfile(folder, fileName)), searchFolders, 'UniformOutput', false)
   %
   % % Convert to a logical:
   % foundFiles = ~cellfun('isempty', foundFiles);
end

%% Local Functions
function [projectPath, ignoreFolder, localSourcePath, ...
      remoteSourcePath, requirementsFile, installPath, referenceList] = ...
      parseargs(kwargs, helpers)

   % Retrieve the Github user name. A local install never reads it, so
   % it is required for a remote install only.
   % The arguments block turns an unset environment variable into the
   % string "", which isempty does not treat as empty, so the test is on
   % length.
   if strlength(kwargs.GitHubUserName) == 0 && kwargs.source == "remote"
      error('installRequiredFiles:missingGitHubUserName', ...
         'Set "GitHubUserName" or environment variable "GITHUB_USER_NAME"')
   else
      GITHUB_USER_NAME = kwargs.GitHubUserName;
   end

   % Note: for general use, this should be userpath or MATLABPATH, I think.
   % Without a local source path, the user path stands in: it is where a
   % user's own functions live when no library checkout is named.
   if strlength(string(kwargs.localSourcePath)) == 0
      localSourcePath = userpath();
   else
      localSourcePath = kwargs.localSourcePath;
   end

   % The scan returns absolute, alias-free paths and every comparison is
   % lexical. A relative localSourcePath must be absolute here, and an
   % alias such as macOS "/var" for "/private/var" must be resolved the
   % way the scan resolves it. canonicalfolder does both through cd.
   localSourcePath = canonicalfolder(localSourcePath, helpers);

   % The remote repository name builds the url, which a local install
   % never uses, so it is required for a remote install only.
   if strlength(kwargs.remoteRepoName) == 0 && kwargs.source == "remote"
      error('installRequiredFiles:missingRemoteRepoName', ...
         ['Set "remoteRepoName" to the GitHub repository ' ...
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

   % Pull out required args and remaining optional args. The entry loop
   % compares projectPath with each scanned file's folder, so projectPath
   % is resolved the same way as localSourcePath. getRequiredFiles
   % validates referenceList and runs with this file's folder current, so
   % a relative referenceList is resolved here against the caller's
   % working folder.
   projectPath = canonicalfolder(kwargs.projectPath, helpers);
   requirementsFile = kwargs.requirementsFile;
   referenceList = kwargs.referenceList;
   if strlength(referenceList) == 0
      referenceList = projectPath;
   else
      referenceList = canonicalfolder(referenceList, helpers);
   end

   % Derive the documented installPath default (the toolbox "dependencies"
   % folder) when the caller did not supply one. This bootstrapped-copy
   % default intentionally differs from the matfunclib canonical, which
   % derives it from PROJECTPATH. A caller's path is resolved like the
   % others, so a relative one that does not exist yet is fixed to the
   % caller's folder before it is probed or created.
   if strlength(kwargs.installPath) == 0
      installPath = fullfile(toolboxpath(), "dependencies");
   else
      installPath = canonicalfolder(kwargs.installPath, helpers);
   end

   % Full path to ignore folder
   ignoreFolder = fullfile(projectPath, kwargs.ignoreFolder);
end

function tf = probefoldscase(installPath, helpers)
   %PROBEFOLDSCASE Ask foldscase about INSTALLPATH from this file's folder.
   %
   % foldscase calls tempname, mkdir, fopen, isfile and rmdir by name.
   % With the caller's folder current (the project being installed into),
   % those names could resolve to that project's own files. The probe
   % therefore runs with this file's folder current, the folder the bound
   % helpers were made from.
   job = changefolder(fileparts(mfilename('fullpath')));
   tf = helpers.foldscase(installPath);
   delete(job)
end

function helpers = bindhelpers()
   %BINDHELPERS Handles to the functions this file calls by name, resolved
   % from this file's own folder.
   %
   % A handle keeps the function it resolved to when it was made. Each
   % handle is made with this file's folder as the working folder. The
   % working folder outranks the path, so a same-named file in the
   % caller's folder (which may be the project being installed into) is
   % not captured. A private function of this folder outranks both, which
   % is how the stamped template copy finds the undersource.m,
   % foldscase.m and getRequiredFiles.m beside it. The bound set is every
   % file-system and requirements-reading call this file makes; string
   % and path-text functions are not bound. Three things stay outside
   % this protection. The first is a project folder placed ahead of
   % MATLAB's own toolbox folders on the path. The second is the names
   % MATLAB's own dependency walk, readers, validators and unit-test
   % framework call themselves (cd, pwd, dir, isfile, isfolder, load,
   % fopen, fclose, assert): a project that shadows those breaks MATLAB
   % before it reaches this file. The third is the two lookups that
   % locate this file's folder before any handle exists (mfilename and
   % fileparts), which no earlier binding can cover.

   job = changefolder(fileparts(mfilename('fullpath')));
   helpers = struct( ...
      'undersource', @undersource, ...
      'foldscase', @foldscase, ...
      'copyfile', @copyfile, ...
      'movefile', @movefile, ...
      'websave', @websave, ...
      'fileattrib', @fileattrib, ...
      'isfile', @isfile, ...
      'isfolder', @isfolder, ...
      'dir', @dir, ...
      'tempname', @tempname, ...
      'mkdir', @mkdir, ...
      'delete', @delete, ...
      'load', @load, ...
      'readlines', @readlines, ...
      'getRequiredFiles', @getRequiredFiles, ...
      'fopen', @fopen, ...
      'fclose', @fclose, ...
      'which', @which, ...
      'rmdir', @rmdir);
   delete(job)
end

function removestaging(stagingDir, helpers)
   %REMOVESTAGING Delete a transfer's staging folder, with whatever it holds.
   if helpers.isfolder(stagingDir)
      helpers.rmdir(stagingDir, 's')
   end
end

function job = changefolder(folder)
   %CHANGEFOLDER Change the working folder until JOB is deleted.
   %
   % The cleanup object puts the working folder back when it is deleted
   % or goes out of scope, on the normal path and after an error alike.
   % builtin calls the built-in cd by name, both to change the folder
   % and, with an output, to read the current one (pwd is not a
   % built-in). A file named cd in the working folder therefore cannot
   % shadow the change or its reversal.

   % The cleanup exists before the change is made, so an interrupt
   % between the two cannot leave the caller in another folder.
   here = builtin('cd');
   job = onCleanup(@() builtin('cd', here));
   builtin('cd', folder)
end

function folder = canonicalfolder(folder, helpers)
   %CANONICALFOLDER Absolute, alias-free form of an existing folder.
   %
   % cd resolves a relative path against the working folder and a symbolic
   % link such as macOS "/var" to its target, and cd with an output reports
   % the result. The cleanup object puts the working folder back. A folder
   % that does not exist is resolved through its deepest existing ancestor,
   % with the missing tail appended unchanged. A trailing separator would
   % survive into the relative paths erased from each file's folder, so it
   % goes, except on a file-system root ("/" or "C:\"), whose only
   % separator is the path.

   folder = string(folder);
   if helpers.isfolder(folder)
      job = changefolder(folder);
      folder = string(builtin('cd'));
      delete(job)
   elseif strlength(folder) > 0 && isrelativepath(folder)
      % A missing relative folder is fixed to the working folder it was
      % given against, so it cannot later match a same-named folder
      % elsewhere. An empty folder (a bare file name) stays empty, because
      % it means "look it up".
      folder = canonicalfolder(fullfile(builtin('cd'), folder), helpers);
   else
      % A folder that does not exist is resolved through its deepest
      % existing ancestor. An alias in that ancestor (a missing
      % "/var/.../src/gone" whose source is "/private/var/.../src") then
      % compares as inside the source. The entry loop reports it as
      % missing there and does not match it by name to some other copy.
      [parent, name, ext] = fileparts(striptrailingseparators(folder));
      tail = string(name) + string(ext);
      % The walk stops at a file-system root. A bare drive letter such as
      % "C:" is a root, not a relative folder to fix to the working folder.
      atRoot = strlength(parent) == 0 || parent == folder || ...
         ~isempty(regexp(parent, '^[A-Za-z]:$', 'once'));
      if ~atRoot && strlength(tail) > 0
         folder = fullfile(canonicalfolder(parent, helpers), tail);
      end
   end
   folder = striptrailingseparators(folder);
end

function path = striptrailingseparators(path)
   %STRIPTRAILINGSEPARATORS Drop trailing separators, keeping a root's one.
   %
   % The lookbehind requires a character other than a separator or a drive
   % colon before the run, so "/" and "C:\" keep their separator while
   % "/a/b/" and "C:\a\" lose theirs.

   path = regexprep(string(path), '(?<=[^/\\:])[/\\]+$', '');
end

function path = forwardslashes(path)
   %FORWARDSLASHES One separator and no trailing separator, for comparing
   % or erasing a folder prefix. undersource normalizes the same way.

   path = striptrailingseparators(strrep(string(path), '\', '/'));
end

function tf = isrelativepath(path)
   %ISRELATIVEPATH True when PATH has no leading separator or drive letter.

   % MATLAB string literals take no escapes, so a single backslash is
   % written "\". A drive-relative path such as "C:src" counts as
   % relative; only "C:\" or "C:/" is rooted.
   path = string(path);
   tf = ~startsWith(path, ["/", "\"]) && ...
      isempty(regexp(path, '^[A-Za-z]:[/\\]', 'once'));
end

function requiredFiles = readRequirementsFile(requirementsFile, helpers)
   %READREQUIREMENTSFILE Read a required-files list from a requirements file.
   %
   % Supports the .mat format written by getRequiredFiles
   % (saveRequirementsFile=true), preferring its "missingFiles" variable and
   % falling back to "requiredFiles", and plain text with one entry per line
   % (blank lines and #-comment lines ignored).

   if ~helpers.isfile(requirementsFile)
      error('installRequiredFiles:requirementsFileNotFound', ...
         'requirementsFile not found: %s', requirementsFile)
   end

   [~, ~, ext] = fileparts(requirementsFile);
   if strcmpi(ext, '.mat')
      vars = helpers.load(requirementsFile);
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
      requiredFiles = strtrim(helpers.readlines(requirementsFile));
      requiredFiles(requiredFiles == "") = [];
      requiredFiles(startsWith(requiredFiles, "#")) = [];
   end
   requiredFiles = reshape(requiredFiles, 1, []);
end

function [requirementsList, urlList, localList, skippedList] = ...
      remoteDependencyList(requiredFiles, projectPath, localsource, ...
      remotesource, helpers, foldscase)
   %REMOTEDEPENDENCYLIST Get a list of remote url's to function dependencies.
   %
   % LOCALLIST holds each file's path under LOCALSOURCE, which is the
   % source of a local install and the basis of each url. SKIPPEDLIST
   % holds the names that resolved nowhere under LOCALSOURCE, or in
   % several places, other than MATLAB's own files.

   % This operates on one file at a time

   [requirementsList, urlList, localList, skippedList] = ...
      deal(strings(length(requiredFiles), 1));

   % For each dependency. The loop resolves each entry to one folder and
   % file first, and only then classifies it (satisfied by the project,
   % repeated, colliding, or listed). Every classification compares
   % resolved paths; a lexical test on the raw entry is wrong for
   % aliases, relative folders, and bare names.
   for ifile = 1:length(requiredFiles)

      % Get the file name with extension
      [requiredFilePath, requiredFileName, ext] = fileparts(requiredFiles{ifile});
      requiredFileName = strcat(requiredFileName, ext);

      % A mex file is never vendored. An entry with no file name (one that
      % ends in a separator) names a folder, not a file. The loop reports
      % and skips it and does not resolve it to whatever that folder holds.
      if strcmp(ext, '.mex')
         continue
      end
      if strlength(requiredFileName) == 0
         warning('installRequiredFiles:notUnderLocalSource', ...
            '%s names no file, so it is skipped.', requiredFiles{ifile})
         skippedList(ifile) = string(requiredFiles{ifile});
         continue
      end

      % A wildcard anywhere in the entry is not a path. dir would expand
      % it and the first match would be installed as if it had been named,
      % so the loop reports and skips the entry before any resolution.
      if contains(requiredFiles{ifile}, ["*", "?"])
         warning('installRequiredFiles:notUnderLocalSource', ...
            '%s is a pattern, not a file name, so it is skipped.', ...
            requiredFiles{ifile})
         skippedList(ifile) = requiredFileName;
         continue
      end

      % If the required file exists in the local source repo, add it to the
      % requirementsList and build a full path to the remote file.

      % This was in the icemodel version:
      % Note - this is problematic if the requiredFiles contain files which are
      % not in localSourcePath e.g. if one project depends on another. So this
      % needs to be refactored to work with localSourcePaths (plural).
      %
      % Limitation: one source repository per call. A project whose
      % requirements live in several repositories needs one call per
      % repository, because the lookup below searches one localSourcePath.

      % An entry given relative to the source, such as a requirements-file
      % line "liboctave/isoctave.m", names one file even where the bare
      % name has several copies under the source. The loop anchors it
      % there and nowhere else. The test is lexical (no leading separator
      % or drive) and never consults the working folder, so a same-named
      % folder inside the project cannot capture it. A bare name (no
      % folder part) takes the lookup by name below. A root file is
      % written "./name.m" so it has a folder part and never does.
      anchored = isrelativepath(requiredFiles{ifile}) && ...
         strlength(requiredFilePath) > 0;
      if anchored
         requiredFilePath = fullfile(localsource, requiredFilePath);
      end

      % canonicalfolder resolves an existing folder through the file
      % system, so an alias of the project or source path (macOS "/var"
      % for "/private/var") compares equal to it and no containment test
      % below fails on spelling.
      requiredFilePath = canonicalfolder(requiredFilePath, helpers);

      % An anchored entry names one file. When that file is absent or is
      % a folder, or the entry climbs out of the source with "..", the
      % loop skips it here and never matches it by name to some other
      % copy. isfile makes that decision without enumerating a folder.
      if anchored && (~helpers.undersource(requiredFilePath, localsource) || ...
            ~helpers.isfile(fullfile(requiredFilePath, requiredFileName)))
         warning('installRequiredFiles:notUnderLocalSource', ...
            '%s is not under localSourcePath %s, so it is skipped.', ...
            requiredFiles{ifile}, localsource)
         skippedList(ifile) = requiredFileName;
         continue
      end

      % The project's own file satisfies a full path inside the project,
      % so the loop skips it with no warning. undersource tests on folder
      % boundaries, so a source folder whose name starts with the project
      % folder's name does not count as inside it. A project path whose
      % file is absent names nothing; the loop skips it with a warning
      % and does not match it by name to a copy elsewhere.
      if ~anchored && helpers.undersource(requiredFilePath, projectPath)
         if ~helpers.isfile(fullfile(requiredFilePath, requiredFileName))
            warning('installRequiredFiles:notUnderLocalSource', ...
               '%s is not under localSourcePath %s, so it is skipped.', ...
               requiredFiles{ifile}, localsource)
            skippedList(ifile) = requiredFileName;
         end
         continue
      end

      % findUnderSource looks a file resolved outside localsource, or
      % given as a bare name, up by name under localsource, so a shadowing
      % copy elsewhere on the path does not hide the source repo's copy.
      % For a bare name, the folder the MATLAB path resolves it to serves
      % one purpose only: the test below for a MATLAB file such as
      % "userpath.m", which is MATLAB's own and dropped with no warning.
      % That folder is never a source and never replaces the lookup, so
      % several copies under the source are reported.
      originalPath = string(requiredFilePath);
      if strlength(originalPath) == 0
         originalPath = string(fileparts(helpers.which(requiredFileName)));
      end
      if ~helpers.undersource(requiredFilePath, localsource)
         requiredFilePath = findUnderSource(requiredFileName, ...
            originalPath, localsource, helpers);
      end

      if ~helpers.undersource(requiredFilePath, localsource)
         % Not resolved under the source, and not an existing MATLAB file:
         % the lookup above warned, and the caller can read the name here.
         if ~(helpers.undersource(originalPath, matlabroot) && ...
               helpers.isfile(fullfile(originalPath, requiredFileName)))
            skippedList(ifile) = requiredFileName;
         end
         continue
      end

      % A path under the source whose file is absent, or which names a
      % folder, names nothing to copy or download. The loop skips it like
      % an unknown name and does not report a failed install. isfile
      % decides that before dir runs, because dir on a folder enumerates
      % its contents and does not describe the folder.
      if helpers.isfile(fullfile(requiredFilePath, requiredFileName))
         found = helpers.dir(fullfile(requiredFilePath, requiredFileName));
         found = found(~[found.isdir]);
      else
         found = [];
      end
      if isempty(found)
         warning('installRequiredFiles:notUnderLocalSource', ...
            '%s is not under localSourcePath %s, so it is skipped.', ...
            requiredFiles{ifile}, localsource)
         skippedList(ifile) = requiredFileName;
         continue
      end

      % The name as the file system spells it: on a case-insensitive
      % file system the entry may differ in case from the tracked file,
      % and the repository path in the url is case-sensitive.
      requiredFileName = string(found(1).name);
      resolvedFile = fullfile(requiredFilePath, requiredFileName);

      % A file the lookup placed inside the project (a project that lives
      % under the source) is the project's own and is satisfied.
      if helpers.undersource(requiredFilePath, projectPath)
         continue
      end

      % A repeated entry for the same resolved file is listed once, with
      % no message. Two different source files with one name cannot both
      % land at one destination: the first wins and the loop reports the
      % second. Two names collide at the destination when the file system
      % there treats them as one. The foldscase flag comes from the
      % destination volume itself, not from the host, because a
      % case-sensitive volume can be mounted on macOS and a case-folding
      % one on Linux. "The same file" is a separate question, answered on
      % the source. The resolved paths carry the spelling the source file
      % system reports (cd for the folder, dir for the name), so one file
      % always resolves to one string. A case-sensitive comparison then
      % identifies it, whatever the destination does.
      if foldscase
         prior = find(strcmpi(requiredFileName, requirementsList), 1);
      else
         prior = find(strcmp(requiredFileName, requirementsList), 1);
      end
      samefile = ~isempty(prior) && strcmp(localList(prior), resolvedFile);
      if ~isempty(prior)
         if ~samefile
            warning('installRequiredFiles:duplicateName', ...
               ['%s is already listed from %s, so %s is skipped: two ' ...
               'source files cannot share one destination name.'], ...
               requiredFileName, localList(prior), resolvedFile)
            skippedList(ifile) = requiredFileName;
         end
         continue
      end

      % Add the file name to the list of external dependencies
      requirementsList(ifile) = requiredFileName;
      localList(ifile) = resolvedFile;

      % Get the subfolder path relative to the top-level source repo.
      % Containment was established above, so extractAfter removes the
      % prefix by length on the forward-slash forms. That agrees with the
      % containment test whatever the separators, and on Windows it does
      % not depend on the letter case of either path. A file at the repo
      % root has no subfolder, so its url has no middle segment.
      relativePath = extractAfter(forwardslashes(requiredFilePath), ...
         strlength(forwardslashes(localsource)));
      relativePath = regexprep(relativePath, '^/', '');

      % Use '/' not fullfile b/c fullfile is platform specific
      if strlength(relativePath) == 0
         urlList(ifile) = remotesource + '/' + requirementsList(ifile);
      else
         urlList(ifile) = remotesource + '/' + relativePath + '/' ...
            + requirementsList(ifile);
      end
   end
   % Keep the outputs columns, including the empty ones: deleting every
   % element of a column leaves a 1-by-0 otherwise.
   requirementsList = reshape(requirementsList(requirementsList ~= ""), [], 1);
   urlList = reshape(urlList(urlList ~= ""), [], 1);
   localList = reshape(localList(localList ~= ""), [], 1);
   skippedList = reshape(skippedList(skippedList ~= ""), [], 1);
   assert(all(endsWith(urlList, requirementsList)))
end

function folder = findUnderSource(requiredFileName, resolvedPath, ...
      localsource, helpers)
   %FINDUNDERSOURCE Find one file by name under the local source folder.
   %
   % FOLDER is the folder holding the one match, or "" when there is no
   % match or more than one. The search covers the source first, so a
   % source copy of a name MATLAB also ships wins. Only when the source
   % has no copy does an existing MATLAB file under matlabroot, such as
   % userpath.m, drop out with no warning: it is not a dependency to
   % vendor. A path under matlabroot that names no file is reported like
   % any other miss.

   arguments
      requiredFileName (1, 1) string
      resolvedPath (1, 1) string
      localsource (1, 1) string
      helpers (1, 1) struct
   end

   folder = "";
   found = helpers.dir(fullfile(localsource, '**', requiredFileName));
   found = found(~[found.isdir]);

   if isscalar(found)
      folder = string(found.folder);
   elseif isempty(found)
      if helpers.undersource(resolvedPath, matlabroot) && ...
            helpers.isfile(fullfile(resolvedPath, requiredFileName))
         return
      end
      warning('installRequiredFiles:notUnderLocalSource', ...
         '%s is not under localSourcePath %s, so it is skipped.', ...
         requiredFileName, localsource)
   else
      warning('installRequiredFiles:severalUnderLocalSource', ...
         ['%s has %d copies under localSourcePath, so it is skipped: ' ...
         '%s'], requiredFileName, numel(found), ...
         strjoin(fullfile(string({found.folder}), requiredFileName), ', '))
   end
end
