function Info = getDependencies(target, varargin)
   %GETDEPENDENCIES Get a list of functions required by a function.
   %
   %  INFO = GETDEPENDENCIES(TARGET) Returns INFO, a struct containing a list of
   %  functions and products required to run the function or functions specified
   %  by the function(s) or folder of functions TARGET. 
   %
   %  INFO = GETFUNCTIONDEPENDENCIES(TARGET, 'REFERENCEPATH', REFPATH) Compares
   %  the required functions in flist to functions in folder specified by
   %  'refpath' to indicate if required files are missing.
   % 
   % TARGET - the target function, list of functions, or folder containing
   % functions that other functions depend upon. TARGET can be a single
   % char or string, or a cell array or string array of targets. If TARGET is a
   % filename or list of filenames, they can be fullly qualified paths or file
   % names, but if they are not full paths, the files must be on the matlab path
   % or this function must be called from within the folder they are in for
   % expected behavior. If TARGET is a folder name, it should be a single
   % folder.
   %
   % Example
   %
   %
   % Matt Cooper, 23-Dec-2022, https://github.com/mgcooper
   %
   % See also: resolveDependencies, getFunctionConflicts

   % parse inputs
   [fileList, referenceList] = parseinputs(target, mfilename, varargin{:});

   % call requiredFilesAndProducts on the file list
   [requiredFiles, requiredProducts] = processFileList(fileList);

   % Return the file lists in a struct
   Info.requiredFiles = requiredFiles;
   Info.requiredProducts = requiredProducts;

   % if a reference path is provided, find missing functions
   if isempty(referenceList)
      Info.missingFiles = 'unknown';
   else
      Info.missingFiles = setdiff(requiredFiles, referenceList);
   end
end


%% subfunctions
function [requiredFiles, requiredProducts] = processFileList(fileList)

   % requiredFilesAndProducts will error if a file has syntax errors. Likely in
   % other cases too. So use try-catch and return empty if it fails.
   try
      [requiredFiles, requiredProducts] = ...
         matlab.codetools.requiredFilesAndProducts(fileList);
      requiredFiles = unique(transpose(requiredFiles));
   catch
      requiredFiles = {};
      requiredProducts = {};
   end
   % requiredFiles = cell2table(requiredFiles,'VariableNames',{'RequiredFiles'});
end

%% input parsing
function [targetList, referenceList] = parseinputs(target, mfuncname, varargin)

   parser = inputParser;
   parser.FunctionName = mfuncname;
   parser.CaseSensitive = true;
   parser.KeepUnmatched = true;

   parser.addRequired('target', @ischarlike);
   parser.addParameter('referencePath', '', @ischarlike);
   parser.parse(target, varargin{:});

   referencePath = parser.Results.referencePath;

   % This works for char file / folder paths or cellstr lists
   target = string(target);

   % validate each member of the target file / folder list
   target = cellfun(@validateFileList, target, 'Uniform', false);

   % If target is a folder, convert to file list
   [targetList, referenceList] = prepareFileLists(target, referencePath);
end

%%
function [targetList, referenceList] = prepareFileLists(target, referencePath)

   if all(isfolder(target))
      if numel(target) > 1
         error('operate one folder at a time')
      end
      targetList = listfiles(target, "subfolders", true, ...
         "mfiles", true, "aslist", true, "fullpath", true);
   else
      targetList = target;
   end

   % filenames to ignore
   % ignore = {'readme','test','temp'};
   % target = target(~contains(target, ignore));

   if isempty(referencePath)
      referenceList = referencePath;
   else
      referenceList = listfiles(referencePath, "subfolders", true, ...
         "mfiles", true, "aslist", true, "fullpath", true);
   end
end

%%
function target = validateFileList(target)

   % If a full file or folder path is provided and exists, use it directly.
   if ~isfile(target) && ~isfolder(target)
      % Otherwise, if target is not a full path to an existing file or folder:

      % If a full file path was passed in but doesn't exist
      if isfullfile(target)
         error('File does not exist or cannot be found.');

         % If a full folder path was passed in but doesn't exist
      elseif ispathlike(target)
         error('Folder does not exist or cannot be found.');

      else
         % Try to find it as a function on the MATLAB path
         % NOTE: you would think 'which' should never find a function that
         % 'isfile' does not find. However, there are possible exceptions.
         % For example, if 'target' is a function name with no extension, and
         % the pwd() contains the function but is not on path, then
         % isfile(target) will be false, but which(target) will find the full
         % path. This might also occur inside private/ directories.

         target = which(target);

         if isempty(target)
            % One last attempt
            target = which(strcat(target, '.m'));
         end

         if isempty(target)
            error('Function does not exist on the MATLAB path.');
         end
      end
   end
end

%{

Below here is deprecated. getDependencies was written under the assumption
codetools.requiredFilesAndProducts operates on one function at a time and it was
necessary to loop over all files in the project, but it accepts a list of
interdependent files and finds all dependencies. The only reason I can think to
keep the stuff below around is in case looping over each file and using
'toponly', skipping found files along the way, is somehow faster than passing
the entire list to requiredFilesAndProducts, but hopefully
requiredFilesAndProducts does something like that but in a more efficient    
manner than what I could do using the loop here with 'toponly'. 

%%
function [requiredFiles, requiredProducts] = getDependencies(fileList)

   numfiles = numel(fileList);

   testallfiles = false;

   if testallfiles == true

      % might just need to call it on the entire file list
      [requiredFiles, requiredProducts] = processFileList(fileList);

   else

      [requiredFiles, requiredProducts] = deal(cell(numfiles, 1));

      for ifile = 1:numfiles

         % Not implemented. This is from resolveDependencies, which operates on
         one % file at a time, and keeps a list of requirements in
         requirementsList, so % it can check if the requirement is already in
         the list, and it also has % the projectFolder, so it can check if the
         requirement is satisfied.
         
         % if skipfile(filelist{ifile}, projectFolder, requiredFileName, ...
         %       requiredFilePath, requirementsList)
         %    continue
         % end
         [flist, plist] = processFileList(fileList{ifile});
         %          if contains(targetList{ifile}, ignore)
         %             continue
         %          else
         %             [flist, plist] = processOneFile(targetList{ifile});
         %          end
         if ~isempty(flist)
            requiredFiles{ifile} = flist;
         end
         if ~isempty(plist)
            requiredProducts{ifile} = plist;
         end
      end
      requiredFiles = vertcat(requiredFiles{:});

      % Required products will contain many duplicates and possibly empties
      requiredProducts = requiredProducts(~cellfun(@isempty, requiredProducts));
      requiredProducts = vertcat(requiredProducts{:});
      requiredProducts = struct2table(requiredProducts);
      requiredProducts = unique(requiredProducts, 'rows');

   end
end

%%
function tf = skipfile(functionName, projectFolder, requiredFileName, ...
      requiredFilePath, requirementsList)

   % skip this file if it is the target function, a mex file, already found,
   % or already satisfied b/c it exists in the projectFolder.

   [~, ~, ext] = fileparts(requiredFileName);
   tf = ...
      strcmp(requiredFileName, functionName) | ...
      strcmp(ext, '.mex') | ...
      any(strcmpi(requiredFileName, requirementsList)) | ...
      contains(requiredFilePath, projectFolder);
end

%%
function missingFiles = getMissingDependencies(requiredFiles, referenceList)
   % This is only needed if referenceList is a list of filenames w/o full-path.
   % If referenceList is a list of fullfile paths, then setdiff as in the main
   % function is all that is needed.
   isMissing = false(numel(requiredFiles), 1);
   for n = 1:numel(requiredFiles)
      [~, fname, fext] = fileparts(requiredFiles{n});
      isMissing(n) = ~ismember([fname, fext], referenceList);
   end
   missingFiles = requiredFiles(isMissing);
end
%}
