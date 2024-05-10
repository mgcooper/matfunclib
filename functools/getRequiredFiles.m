function Requirements = getRequiredFiles(targetList, varargin)
   %GETREQUIREDFILES Retrieve requirements for MATLAB functions or toolboxes.
   %
   %  REQUIREMENTS = GETREQUIREDFILES(TARGETLIST)
   %  REQUIREMENTS = GETREQUIREDFILES(_, IGNORELIST=IGNOREFILELIST)
   %  REQUIREMENTS = GETREQUIREDFILES(_, REFERENCELIST=REFERENCEFILELIST)
   %  REQUIREMENTS = GETREQUIREDFILES(_, REQUIREMENTSFILENAME=FILENAME)
   %  REQUIREMENTS = GETREQUIREDFILES(_, SAVEREQUIREMENTSFILE=TRUE)
   %
   %  The use case for this function is to generate a list of required files to
   %  ship with a toolbox. Third party users then run an install script which
   %  reads the requirements list and installs them from GitHub. Alternatively,
   %  the toolbox maintainer uses this to generate the list and install the
   %  requirements into the toolbox. This function does not allow the third
   %  party to generate the requirements list, because the requirements must be
   %  on the local path where this function runs.
   %
   % Description
   %
   %  REQUIREMENTS = GETREQUIREDFILES(TARGETLIST) returns a struct,
   %  REQUIREMENTS, containing a list of all functions and products required by
   %  the function or set of functions specified by TARGETLIST. TARGETLIST can
   %  be a function name, a list of functions, or a folder containing functions.
   %  If TARGETLIST is a folder, the requirements are generated for the list of
   %  all functions contained within all folders and subfolders of TARGETLIST.
   %
   %  REQUIREMENTS = GETREQUIREDFILES(_, 'IGNORELIST', IGNORE) ignores members
   %  of TARGETLIST that are present in IGNORE. If TARGETLIST is a list of
   %  files, matching files in IGNORE are ignored. If TARGETLIST is a folder or
   %  list of folders, matching folders (and subfolders) are ignored. Note that
   %  this argument is used to ignore files and folders when generating the
   %  requirements of TARGETLIST. The intended use case is to ignore folders or
   %  contained within a project when TARGETLIST is the project path.
   %
   %  REQUIREMENTS = GETREQUIREDFILES(_, 'REFERENCELIST', REFERENCE)
   %  identifies dependencies of TARGETLIST that are not present in REFERENCE.
   %  This can be used to determine the external dependencies of TARGETLIST by
   %  excluding those dependencies that are already satisfied by REFERENCE.
   %
   % Inputs
   %
   % TARGETLIST
   %  A char or string specifying a function, a list of functions, or a folder
   %  of functions. If a list, it can be a cell array or a string array. File
   %  names may be fully qualified paths or just file names. If just names,
   %  files should be on the MATLAB path or the current folder. If a folder is
   %  specified, it should be a single folder, but all subfolders will be
   %  considered.
   %
   % REFERENCELIST
   %  A function, list of functions, or path to a folder containing functions
   %  that are considered as already meeting the TARGETLIST requirements. These
   %  functions are treated as "satisfied," and the REQUIREMENTS structure will
   %  list only those requirements of TARGETLIST that are not also present in
   %  REFERENCELIST. This is particularly useful when identifying dependencies
   %  that are external to a toolbox or a particular project setup.
   %
   % IGNORELIST
   %  A function, list of functions, or path to a folder containing functions
   %  contained within REFERENCELIST that are ignored when generating the
   %  TARGETLIST requirements. Use this argument to ignore reference (project,
   %  toolbox) folders that do not need to be distributed.
   %
   % Example Syntax
   %
   %  Requirements = getRequiredFiles('getRequiredFiles');
   %  Requirements = getRequiredFiles(_, reference=toolbox_path);
   %  Requirements = getRequiredFiles(_, reference=function_path);
   %  Requirements = getRequiredFiles(_, requirementsFileName='requirements');
   %  Requirements = getRequiredFiles(_, saveRequirementsFile=true);
   %
   % Matt Cooper, 23-Dec-2022, https://github.com/mgcooper
   %
   % See also: installRequiredFiles, getFunctionConflicts

   % Parse inputs
   [targetFiles, referenceFiles, requirementsFileName, saveRequirementsFile] = ...
      parseinputs(targetList, mfilename, varargin{:});

   % Call codetools.requiredFilesAndProducts on the file list
   [requiredFiles, requiredProducts] = processFileList(targetFiles);

   % Find missing files (required files not included in the reference list)
   missingFiles = setdiff(requiredFiles, referenceFiles);
   missingFiles = string(missingFiles);
   requiredFiles = string(requiredFiles);

   if saveRequirementsFile
      save(requirementsFileName, 'requiredFiles', 'missingFiles')
   end

   % Return the file lists in a struct
   Requirements.missingFiles = missingFiles;
   Requirements.requiredFiles = requiredFiles;
   Requirements.requiredProducts = requiredProducts;
end

%% Local Functions
function [requiredFiles, requiredProducts] = processFileList(fileList)

   % requiredFilesAndProducts will error if a file has syntax errors. Likely
   % in other cases too. So use try-catch and return empty if it fails.
   try
      [requiredFiles, requiredProducts] = ...
         matlab.codetools.requiredFilesAndProducts(fileList);
      requiredFiles = unique(transpose(requiredFiles));
   catch e
      if strcmp(e.identifier, 'MATLAB:depfun:req:BadSyntax')
         warning('GETREQUIREDFILES: TARGETLIST files contain invalid syntax.')
      end
      rethrow(e)
   end
end

%% Input Parsing
function [targetFiles, referenceFiles, requirementsFileName, ...
      saveRequirementsFile] = parseinputs(targetList, mfuncname, varargin)

   parser = inputParser;
   parser.FunctionName = mfuncname;
   parser.CaseSensitive = true;
   parser.KeepUnmatched = true;

   parser.addRequired('targetList', @ischarlike);
   parser.addParameter('ignoreList', '', @ischarlike);
   parser.addParameter('referenceList', '', @ischarlike);
   parser.addParameter('requirementsFileName', 'requirements.mat', @ischarlike);
   parser.addParameter('saveRequirementsFile', false, @islogical);
   parser.parse(targetList, varargin{:});

   % Retreive the arguments
   ignoreList = parser.Results.ignoreList;
   referenceList = parser.Results.referenceList;
   requirementsFileName = parser.Results.requirementsFileName;
   saveRequirementsFile = parser.Results.saveRequirementsFile;

   % This works for files/folders passed as char or cellstr lists
   targetList = string(targetList);
   ignoreList = string(ignoreList);
   referenceList = string(referenceList);

   % Validate each member of the target file / folder list
   targetList = string(cellfun(@validateFileList, targetList, 'Uniform', false));

   % Decided this does not need to be validated.
   % ignoreList = string(cellfun(@validateFileList, ignoreList, 'Uniform', false));

   % If target is a folder, convert to file list
   [targetFiles, referenceFiles] = prepareFileLists(...
      targetList, referenceList, ignoreList);
end

function [targetFiles, referenceFiles, ignoreFiles] = prepareFileLists(...
      targetList, referenceList, ignoreList)

   % Generate a list of target filenames
   if all(isfolder(targetList))
      if numel(targetList) > 1
         error('operate one folder at a time')
      end
      targetFiles = fileListFromFolderList(targetList);
   else
      % all(isfile(targetList))
      targetFiles = targetList;
   end

   % Generate a list of "reference" filenames (nominally files included with the
   % project or toolbox which therefore are satisfied by default).
   if all(isfolder(referenceList))
      referenceFiles = fileListFromFolderList(referenceList);

   else % all(isfile(referenceList)) or referenceList == ""
      referenceFiles = referenceList;
   end

   % Generate a list of filenames to ignore
   if all(isfolder(ignoreList))
      ignoreFiles = fileListFromFolderList(ignoreList);

   else % all(isfile(ignoreList)) or ignoreFiles == ""
      ignoreFiles = ignoreList;
   end

   % Remove the ignored file list from the target list.
   targetFiles = setdiff(targetFiles, ignoreFiles);

   % Add the target to the the reference list, so it isn't included in the
   % missing requirements.
   referenceFiles = vertcat(referenceFiles, targetFiles);

   % filenames to ignore - not implemented
   % ignore = {'readme','test','temp'};
   % target = target(~contains(target, ignore));
end

function fileList = fileListFromFolderList(folderList)
   fileList = cell(numel(folderList), 1);
   for n = 1:numel(folderList)
      fileList{n} = listfiles(folderList(n), ...
         "subfolders", true, "mfiles", true, "matfiles", true, ...
         "aslist", true, "fullpath", true, "asstring", true);
   end
   fileList = vertcat(fileList{:});
end

function fileList = validateFileList(fileList)

   if isempty(fileList)
      return
   end

   % If a full file or folder path is provided and exists, use it directly.
   if not(isfile(fileList)) && not(isfolder(fileList))
      % Otherwise, if target is not a full path to an existing file or folder,
      % try to provide specific feedback:

      if isfullfile(fileList)
         % If a full file path was passed in but doesn't exist
         error('File does not exist or cannot be found.');

      elseif ispathlike(fileList)
         % If a full folder path was passed in but doesn't exist
         error('Folder does not exist or cannot be found.');

      else
         % Try to find it as a function on the MATLAB path, accounting for edge
         % cases where 'which' locates a file that 'isfile' does not. This can
         % occur if TARGETLIST is a function name with no extension, and the pwd()
         % contains the function file but is not on path - here, isfile(target)
         % will be false, but which(target) will find the full path. This might
         % also occur inside private/ directories.

         fileList = which(fileList);

         if isempty(fileList)
            % One last attempt
            fileList = which(strcat(fileList, '.m'));
         end

         if isempty(fileList)
            error('Function does not exist on the MATLAB path.');
         end
      end
   end
end
