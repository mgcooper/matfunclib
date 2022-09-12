function data = readfiles(filenameorlist,dataoutputtype,varargin)
   
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   p                 = inputParser;
   p.FunctionName    = 'readfiles';
   p.CaseSensitive   = false;
   p.KeepUnmatched   = true;
   
   validfiles  = @(x)validateattributes(x,{'struct','char','string'},   ...
                     {'nonempty'},'readfiles','filenameorlist',1);
   validoutput = @(x)validateattributes(x,{'char'},{'nonempty'},  ...
                     'readfiles','dataoutputtype');   
   validnanval = @(x)validateattributes(x,{'numeric'},{'nonempty'},  ...
                     'readfiles','replacewithnan');

   addRequired(   p,'filenameorlist',              validfiles        );
   addOptional(   p,'dataoutputtype',  'struct',   validoutput       );
   addParameter(  p,'replacewithnan',  nan,        validnanval       );

   parse(p,filenameorlist,dataoutputtype,varargin{:});
   
   filenameorlist = p.Results.filenameorlist;
   outputrequest  = p.Results.dataoutputtype;
   nanval         = p.Results.replacewithnan;
 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   
   % either pass in a file list or a path to files
   if isstruct(filenameorlist)
      filelist    = filenameorlist;
   else
      filelist    = dir(fullfile(filenameorlist)); % convert filename to list
   end
   
   if isempty(fieldnames(filelist))
      error('empty list');
   end
   
   % get the full path and file type
   [filepath,filetype,numfiles]  = getListInfo(filelist);
   
   % read the data
   data = getRequest(filelist,filepath,filetype,numfiles,outputrequest);
   
   % clean and retime timetables if requested
   if strcmp(outputrequest,'timetable')
      data = cleantimetable(data);
   end
   
end

function data = getRequest(filelist,filepath,filetype,numfiles,request)
   
   for iFile = 1:numfiles
      
      thisName    = filelist(iFile).name;
      thisFile    = [filepath '/' thisName];
      thisName    = strrep(thisName,filetype,'');
      fieldName   = matlab.lang.makeValidName(thisName);
      
      switch filetype
         
         % SPREADSHEETS
         case {'.xlsx','.csv','.xls','.dat','.txt'}
            
            switch request
               
               case 'timetable'
                  
                  data.(fieldName) = readtimetable(thisFile);
                  
               otherwise % subsumes case 'table'
                  
                  data.(fieldName) = readtable(thisFile);   
            end
      
         % NC AND HDF
         case {'.nc','.nc4'}
            
            switch request
               
               case {'timetable','table'}
                  
                  error('data type incompatible with requested output type');
                  
               otherwise % subsumes case 'struct'
            
                  data.(fieldName) = ncreaddata(thisFile,ncvars(thisFile));
            end
            
         % GEOTIFF
         case {'.geotiff','.tiff','.tif'}
            
            switch request
               
               case {'timetable','table'}
                  
                  error('data type incompatible with requested output type');
                  
               otherwise
                  
                  [data.(fieldName).Z,data.(fieldName).R] = readgeoraster(thisFile);
            end
            
         % OHTER IMAGES
         case {'.jpg','.png'}
            
            switch request
               
               case {'timetable','table'}
                  
                  error('data type incompatible with requested output type');
                  
               otherwise
                  
                  data.(fieldName) = imread(thisFile);   
            end
      end
   end   
end

function [filePath,fileType,numFiles]  = getListInfo(fileList)
   fileName                = [fileList(1).folder '/' fileList(1).name];
   [filePath,~,fileType]   = fileparts(fileName);
   numFiles                = numel(fileList);
end

function data = cleantimetable(data)
   
   tables      = fieldnames(data);
   numtables   = numel(tables);
   
% make sure the time dimensions is called 'Time'   
   for n = 1:numtables

      T     = data.(tables{n});
      dims  = T.Properties.DimensionNames;
      
      if string(dims{1}) ~= "Time"
         T.Properties.DimensionNames{1} = 'Time';
      end
      
      % put the table back
      data.(tables{n})  = T;
      
   end
   
% quality control checks   
   for n = 1:numtables
      
      T     = data.(tables{n});

      QA(n).issorted       = issorted(T);
      QA(n).isregular      = isregular(T);
      QA(n).ismissing      = ismissing(T);
      QA(n).nummissing     = sum(QA(n).ismissing);
      QA(n).duplicates     = getduplicatetimes(T);

      % clean 
      T  = tablecleanup(T,'first');
      
      % put the table back
      data.(tables{n})  = T;
      
   end
   
   data.QA  = QA;
   
% % I stopped here b/c without knowing dt I don't want to retime   
% % get the min-max dates to retime
%    T     = data.(tables{1});
%    Tmin  = min(T.Time);
%    Tmax  = max(T.Time);
%    dt    = T.Properties.TimeStep;
%    
%    for n = 2:numtables
%       
%       T     = data.(tables{n});
%       Tmin  = min(Tmin,min(T.Time));
%       Tmax  = max(Tmax,max(T.Time));
%       
%    end
%    
% % retime the tables to a consistent timeframe
%    Time  = Tmin:dt:Tmax;   
   
   
end

function dupes = getduplicatetimes(T)

   dupes = sort(T.Time);
   TF    = (diff(dupes) == 0);
   dupes = dupes(TF);
   dupes = unique(dupes);

end

function T = tablecleanup(T,whichrow)
   
   % remove missing entries
   T     = sortrows(T,'Time');
   OK    = ~ismissing(T.Time);
   T     = T(OK,:);
   
   uniqueTimes = unique(T.Time);
   
   switch whichrow
      case 'first'
         T = retime(T,uniqueTimes);     
         
      case 'second'
         T = retime(T,uniqueTimes,'previous'); 
         
      case 'mean'
         T = retime(T,uniqueTimes,'mean');
   end
   
end
   
% function data = readstructdata(thisPath,filetype,fieldName)
%   
%    switch filetype
%       case {'.xlsx','.csv','.xls','.dat','.txt'}
%          data = readtable(thisPath);
%       case {'.nc','.nc4'}
%          data.(fieldName) = ncreaddata(thisPath,ncvars(thisPath));
%       case {'.geotiff','.tiff','.tif'}
%          [data.(fieldName).Z,data.(fieldName).R] = readgeoraster(thisPath);
%       case {'.jpg','.png'}
%          data.(fieldName) = imread(thisPath);
%    end
% end
% 
% 
% 
% function data = readtabledata(thisPath,filetype,fieldName)
% 
%    switch filetype
%       case {'.xlsx','.csv','.xls','.dat','.txt'}
%          data.(fieldName) = readtable(thisPath);
%       case {'.nc','.nc4'}
%          error('data type incompatible with requested output type');
%       case {'.geotiff','.tiff','.tif'}
%          error('data type incompatible with requested output type');
%       case {'.jpg','.png'}
%          error('data type incompatible with requested output type');
%    end
%    
% end
% 
% function data = readtimetabledata(thisPath,filetype,fieldName)
%    
%    switch filetype
%       case {'.xlsx','.csv','.xls','.dat','.txt'}
%          data.(fieldName) = readtimetable(thisPath);
%       case {'.nc','.nc4'}
%          error('data type incompatible with requested output type');
%       case {'.geotiff','.tiff','.tif'}
%          error('data type incompatible with requested output type');
%       case {'.jpg','.png'}
%          error('data type incompatible with requested output type');
%    end
%             
% end