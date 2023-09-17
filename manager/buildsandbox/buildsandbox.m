function Info = buildsandbox(funcname,varargin)
   %BUILDSANDBOX Find and copy function dependencies to sandbox folder.
   %
   %  Info = buildsandbox(funcname)
   %  Info = buildsandbox(funcname, 'dryrun', true)
   %  Info = buildsandbox(funcname, 'pathsave', pathstring)
   %  Info = buildsandbox(funcname, 'strexclude', strexclude)
   %
   % See also:

   % PARSE INPUTS
   p = magicParser;
   p.FunctionName = mfilename;
   p.addRequired( 'funcname', @ischar);
   p.addParameter('dryrun', false, @islogical);
   p.addParameter('pathsave', fullfile(pwd,'sandbox'),@ischar);
   p.addParameter('strexclude', '', @ischar);
   p.parseMagically('caller');
   pathsave = p.Results.pathsave;

   % MAIN FUNCTION

   % append sandbox/ to the pathsave if it isn't already
   if ~contains(pathsave,'sandbox')
      pathsave = fullfile(pathsave,'sandbox');
      if dryrun == false
         warning('appending sandbox/ to pathsave');
      else
         warning('will append sandbox/ to pathsave');
      end
   end

   % create the sandbox directory if it does not exist
   if ~exist(pathsave,'dir')
      if dryrun == false
         warning('creating pathsave');
         mkdir(pathsave);
      else
         warning('will create pathsave');
      end
   end

   % get the list of required code
   [fList,pList] = matlab.codetools.requiredFilesAndProducts(funcname);

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

      srcFileFullPath   = fList{n};

      [srcDirPath,srcFileName,srcFileExt] = fileparts(srcFileFullPath);

      % % i added this b/c i got unexpected files from the "cupid" toolbox, and
      % thought they were built-in toolboxes, but they weren't so probably a
      % mixup in file names. keep for reference but in general, we want add-ons
      %       % don't copy toolboxes
      %       if contains(thisDir,'MATLAB Add-Ons')
      %          continue
      %       end

      srcFileName = strcat(srcFileName,srcFileExt);

      srcDirList  = dir(fullfile(srcDirPath));

      % remove '.' and '..' files
      srcDirList(strncmp({srcDirList.name}, '.', 1)) = [];

      % get the parent folder name
      idx         = strfind(srcDirPath,'/');
      srcDirName  = srcDirPath(idx(end)+1:end);

      % append trailing / to the source directory paht
      % srcDirPath  = [srcDirPath '/'];
      % commented out 30 Jan 2023 when replacing trailing / with fullfile

      % assume we want to copy the dependencies to pathsave
      newDirPath   = pathsave;

      % unless they are in a named folder with a json file
      if any(contains({srcDirList.name},fjson))

         % append the directory name to the new parent path
         newDirPath = fullfile(pathsave,srcDirName);

         if ~exist(newDirPath,'dir')

            Info.newfolders = unique([Info.newfolders;newDirPath]);

            % make the new parent folder if it does not exist
            if dryrun == false
               mkdir(newDirPath);
            end
         end

         % copy the json file if it hasn't already been copied
         if ~exist(fullfile(newDirPath,fjson),'file')

            oldjson           = fullfile(srcDirPath,fjson);
            newjson           = fullfile(newDirPath,fjson);
            Info.filescopied  = unique([Info.filescopied;newjson]);

            % copy the file if it's not a trial
            if dryrun == false
               copyfile(oldjson, newjson);
            end
         end

         % or if the file is a requested exclude file, copy to 'exclude'
      elseif contains(fullfile(srcDirPath,srcFileName),strexclude) && ~isempty(strexclude)

         newDirPath = fullfile(pathsave,'exclude');

         if ~exist(newDirPath,'dir'); mkdir(newDirPath); end

         fexclude = fullfile(newDirPath,srcFileName);

         Info.filesexcluded = unique([Info.filesexcluded;fexclude]);
      end

      oldfile           = fullfile(srcDirPath,srcFileName);
      newfile           = fullfile(newDirPath,srcFileName);
      Info.filescopied  = unique([Info.filescopied;newfile]);

      if dryrun == false
         % copy the file
         copyfile(oldfile, newfile);
      end
   end

   if ~isempty(strexclude)
      rmpath(genpath(fullfile(pathsave,'exclude')));
      Info.msg = 'excluded files copied to /exclude, remove or rename if desired';
      disp(Info.msg);
   else
      % can update this if more info is worth adding
      Info.msg = 'success';
   end
end
