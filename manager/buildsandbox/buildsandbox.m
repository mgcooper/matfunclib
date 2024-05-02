function Info = buildsandbox(funcname, params)
   %BUILDSANDBOX Find and copy function dependencies to sandbox folder.
   %
   %  Info = buildsandbox(funcname)
   %  Info = buildsandbox(funcname, 'dryrun', true)
   %  Info = buildsandbox(funcname, 'pathname', pathstring)
   %  Info = buildsandbox(funcname, 'strexclude', strexclude)
   %
   % See also: getDependencies

   % PARSE INPUTS
   arguments
      funcname char
      params.dryrun logical = false
      params.pathname char = fullfile(pwd, 'sandbox')
      params.strexclude char = ''
   end
   [dryrun, pathname, strexclude] = deal(params.dryrun, ...
      params.pathname, params.strexclude);

   % MAIN FUNCTION

   % append sandbox/ to the pathname if it isn't already
   if not(contains(pathname, 'sandbox'))
      pathname = fullfile(pathname, 'sandbox');
      if dryrun
         warning('dryrun, actual run will append sandbox/ to pathname');
      else
         warning('appending sandbox/ to pathname');
      end
   end

   % create the sandbox directory if it does not exist
   if not(isfolder(pathname))
      if dryrun
         warning('dryrun, actual run will create pathname');
      else
         warning('creating pathname');
         mkdir(pathname);
      end
   end

   % get the list of required code
   [fList, pList] = matlab.codetools.requiredFilesAndProducts(funcname);

   fList = transpose(fList);   % file list
   pList = transpose(pList);   % product list

   Info.filelist = fList;
   Info.productlist = pList;

   % init the new folders created and files copied
   Info.newfolders = {''};
   Info.filescopied = {''};
   Info.filesexcluded = {''};

   % use this to str match json files
   fjson = 'functionSignatures.json';

   for n = 1:numel(fList)

      srcFileFullPath = fList{n};

      [srcDirPath,srcFileName,srcFileExt] = fileparts(srcFileFullPath);

      % % i added this b/c i got unexpected files from the "cupid" toolbox, and
      % thought they were built-in toolboxes, but they weren't so probably a
      % mixup in file names. keep for reference but in general, we want add-ons
      % % don't copy toolboxes
      % if contains(thisDir,'MATLAB Add-Ons')
      %    continue
      % end

      srcFileName = strcat(srcFileName, srcFileExt);

      srcDirList = dir(fullfile(srcDirPath));

      % remove '.' and '..' files
      srcDirList(strncmp({srcDirList.name}, '.', 1)) = [];

      % TODO: Replace with fileparts
      % get the parent folder name
      idx = strfind(srcDirPath, '/');
      srcDirName = srcDirPath(idx(end)+1:end);

      % assume we want to copy the dependencies to pathname
      newDirPath = pathname;

      % unless they are in a named folder with a json file
      if any(contains({srcDirList.name}, fjson))

         % append the directory name to the new parent path
         newDirPath = fullfile(pathname, srcDirName);

         if not(isfolder(newDirPath))

            Info.newfolders = unique([Info.newfolders; newDirPath]);

            % make the new parent folder if it does not exist
            if not(dryrun)
               mkdir(newDirPath);
            end
         end

         % copy the json file if it hasn't already been copied
         if not(isfile(fullfile(newDirPath, fjson)))

            oldjson = fullfile(srcDirPath,fjson);
            newjson = fullfile(newDirPath,fjson);
            Info.filescopied = unique([Info.filescopied;newjson]);

            % copy the file if it's not a trial
            if not(dryrun)
               copyfile(oldjson, newjson);
            end
         end

         % or if the file is a requested exclude file, copy to 'exclude'
      elseif contains(fullfile(srcDirPath,srcFileName), strexclude) ...
            && not(isempty(strexclude))

         newDirPath = fullfile(pathname, 'exclude');

         if not(isfolder(newDirPath))
            mkdir(newDirPath);
         end

         fexclude = fullfile(newDirPath, srcFileName);

         Info.filesexcluded = unique([Info.filesexcluded; fexclude]);
      end

      oldfile = fullfile(srcDirPath, srcFileName);
      newfile = fullfile(newDirPath, srcFileName);
      Info.filescopied = unique([Info.filescopied; newfile]);

      if not(dryrun)
         % copy the file
         copyfile(oldfile, newfile);
      end
   end

   if isempty(strexclude)
      % can update this if more info is worth adding
      Info.msg = 'success';
   else
      rmpath(genpath(fullfile(pathname, 'exclude')));
      Info.msg = 'excluded files copied to /exclude, remove or rename if desired';
      disp(Info.msg);
   end
end
