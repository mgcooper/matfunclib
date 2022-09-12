function info = buildsandbox(funcname,varargin)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
   p = MipInputParser;
   p.FunctionName='buildsandbox';
   p.addRequired('funcname',@(x)ischar(x));
   p.addParameter('dryrun',false,@(x)islogical(x));
   p.addParameter('pathsave',[pwd '/sandbox/'],@(x)ischar(x));
   p.addParameter('strexclude','',@(x)ischar(x));
   p.parseMagically('caller');
   pathsave = p.Results.pathsave;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   % initial checks   
   %~~~~~~~~~~~~~~~~
   
   % append sandbox/ to the pathsave if it isn't already
   if ~contains(pathsave,'sandbox/')
      pathsave = [pathsave 'sandbox/'];   
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

   fList    = fList';   % file list
   pList    = pList';   % product list
   
   info.filelist = fList;
   info.productlist = pList;
   
   % init the new folders created and files copied
   info.newfolders = {''};
   info.filescopied = {''};
   info.filesexcluded = {''};
   
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
      srcDirPath  = [srcDirPath '/'];
      
      % assume we want to copy the dependencies to pathsave
      newDirPath   = pathsave;

      % unless they are in a named folder with a json file
      if any(contains({srcDirList.name},fjson))

         % append the directory name to the new parent path
         newDirPath = [pathsave srcDirName '/'];

         if ~exist(newDirPath,'dir')
            
            info.newfolders = unique([info.newfolders;newDirPath]);
            
            % make the new parent folder if it does not exist
            if dryrun == false
               mkdir(newDirPath); 
            end
         end

         % copy the json file if it hasn't already been copied
         if ~exist([newDirPath fjson],'file')

            oldjson           = [srcDirPath fjson];
            newjson           = [newDirPath fjson];
            info.filescopied  = unique([info.filescopied;newjson]);
        
            % copy the file if it's not a trial
            if dryrun == false
               copyfile(oldjson, newjson);
            end
         end
         
      % or if the file is a requested exclude file, copy to 'exclude'
      elseif contains([srcDirPath srcFileName],strexclude) && ~isempty(strexclude)
      
         newDirPath   = [pathsave 'exclude/'];
         
         if ~exist(newDirPath,'dir'); mkdir(newDirPath); end
      
         fexclude    = [newDirPath srcFileName];
         
         info.filesexcluded = unique([info.filesexcluded;fexclude]);
      end
      
      oldfile           = [srcDirPath srcFileName];
      newfile           = [newDirPath srcFileName];
      info.filescopied  = unique([info.filescopied;newfile]);
      
      if dryrun == false
         % copy the file
         copyfile(oldfile, newfile);
      end

   end
   
   if ~isempty(strexclude)
      rmpath(genpath([pathsave 'exclude']));
      info.msg = 'excluded files copied to /exclude, remove or rename if desired';
      disp(info.msg);
   else
      % can update this if more info is worth adding
      info.msg = 'success';
   end
