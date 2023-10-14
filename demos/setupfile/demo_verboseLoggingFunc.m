function demo_verboseLoggingFunc(folder, options)
%DEMO_VERBOSELOGGINGFUNC demo verbose logging

% the purpose of this function is to demonstrate a neat way to verbosely log
% messages and send to the console.

arguments
   folder (1,:) string {mustBeFolder} = string.empty
   options.Silent (1,1) logical = false
end

if options.Silent
   printIfVerbose = @(varargin) 0;
else
   printIfVerbose = @(message)fprintf("%s", message);
end

failures = MException.empty;

% get all sub folders
subfolderList = dir(fullfile(foldername, '**/*'));
subfolderList(strncmp({subfolderList.name}, '.', 1)) = [];
subfolderList = subfolderList([subfolderList.isdir]);

for k = 1 : numel(subfolderList)
   [~, folderName] = fileparts(folder);
   subfolder = subfolderList{k, "Location"};

   printIfVerbose("Updating " + folderName + " ... ");
   try
      mustBeFolder(subfolder);
      isPackage = isPackageFolder(subfolder);
      if isPackage
         printIfVerbose("package folder found");
      else
         printIfVerbose("package folder not found");
      end
   catch updateError
      printIfVerbose("<strong>FAILED</strong>");
      thisFailure = MException("MFUNCLIB:functools:PackageUpdateFailure", ...
         "%s", "Failed to locate package at " + subfolder);
      thisFailure = addCause(thisFailure, updateError);
      failures(end + 1) = thisFailure; %#ok<AGROW>
   end
   printIfVerbose(newline);
end
printIfVerbose(newline);


if (~isempty(failures))

   compositeError = MException("MFUNCLIB:functools:UpdateFailureSummary", ...
      "Failed to locate one or more packages.");
   for failure = failures
      compositeError = addCause(compositeError, failure);
   end
   throw(compositeError);
end

printIfVerbose("Updates complete." + newline);

end

% I did not examine this in as much detail or customize it, but it looks useful
function answer = continueWithPackagesUpdate(packages, options)
arguments
    packages (:,1) string { mustBeNonempty }
    options.WarnAboutReinstallation (1,1) logical = false
end
    % Only called when Silent==false
    formatted = newline + "    " + packages;
    disp("The following packages will be updated: " + join(formatted))
    if (options.WarnAboutReinstallation)
        disp("Updates will apply to package installation locations, " + ...
            "which may not correspond to the original source.")
        disp("Additionally, changes will <strong>not</strong> take effect until " + ...
            "packages are uninstalled, then reinstalled.")
    end
    textResponse = input("Update R2022b packages to R2023a? [YES/no]: ", "s");
    answer = matches(textResponse, "" | "yes" | "y", IgnoreCase=true);
    fprintf(newline);
end