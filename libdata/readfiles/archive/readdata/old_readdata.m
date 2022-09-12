function dat = readdata(varargin)
   
   % this is the original function
   
   % I couldn't get the input parsing correct, i wanted to EITHER pass in
   % fileList OR filePath + fileType, but didn't work, so abandaoned to
   % just read a list
   
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   p                 = inputParser;
   p.FunctionName    = 'readfilelist';
   p.CaseSensitive   = false;
   p.KeepUnmatched   = true;
   
   addOptional(   p,'fileList',  struct(),   @(x)isstruct(x)  );
   addOptional(   p,'filePath',  '',         @(x)ischar(x)  );
   addOptional(   p,'fileType',  '',         @(x)ischar(x)  );
   
   
   parse(p,varargin{:});
   
   fileList    = p.Results.fileList;
   filePath    = p.Results.filePath;
   fileType    = p.Results.fileType;
   
   
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   
   % either pass in a file list or a path to files
   
   if isempty(fieldnames(fileList))
      fileList = getlist(filePath,fileType);    % get the list
   else
      fileName = [fileList(1).folder '/' fileList(1).name];
      [filePath,~,fileType] = fileparts(fileName);
   end
   
   numFiles    = numel(fileList);
   
   for thisFile = 1:numFiles
      
      thisName    = fileList(thisFile).name;
      thisPath    = [filePath '/' thisName];
      thisName    = strrep(thisName,fileType,'');
      thisName    = matlab.lang.makeValidName(thisName);
      
      switch fileType
         case {'.xlsx','.csv','.xls','.dat','.txt'}
            dat.(thisName) = readtable(thisPath);
         case {'.nc','.nc4'}
            dat.(thisName) = ncreaddata(thisPath,ncvars(thisPath));
         case {'.geotiff','.tiff','.tif'}
            [dat.(thisName).Z,dat.(thisName).R] = readgeoraster(thisPath);
         case {'.jpg','.png'}
            dat.(thisName) = imread(thisPath);
      end
      
   end
   
end

