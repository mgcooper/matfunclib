function data = readfiles(filelist,varargin)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% TODO:
% see 'convertvars'
% make the mar, racmo table standard i.e. when filetype is .nc, put 0-d
% vars into properties, 1-d vars into table, with option to ask for lat,lon
% location to put all vars into table
% see 'tsvread

% see get_Arctic_Rivers for example of parsing an xml metadata file

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
p                 = inputParser;
p.FunctionName    = 'readfiles';
p.CaseSensitive   = false;
p.KeepUnmatched   = true;
p.StructExpand    = false;

validfiles  = @(x)validateattributes(x,{'struct','char','string'},   ...
               {'nonempty'},'readfiles','filelist',1);
validoutput = @(x)validateattributes(x,{'char'},                     ...
               {'nonempty'},'readfiles','outputtype');
validopts   = @(x)validateattributes(x,                              ...
               {'matlab.io.text.DelimitedTextImportOptions',      ...
               'matlab.io.spreadsheet.SpreadsheetImportOptions'}, ...
               {'nonempty'},'readfiles','importopts');
validnewt   =  @(x)validateattributes(x,{'datetime','duration'},     ...
               {'nonempty'},'readfiles','newtime');

defaultopts = defaultImportOpts(filelist);

addRequired(   p,'filelist',                       validfiles         );
addParameter(  p,'outputtype',      'struct',      validoutput        );
addParameter(  p,'importopts',      defaultopts,   validopts          );
addParameter(  p,'retime',          false,         @(x)islogical(x)   );
addParameter(  p,'newtime',         NaT,           validnewt          );
addParameter(  p,'ReadVariableNames',true,         @(x)islogical(x)   );
%  addParameter(  p,'replacewithnan', NaN,           @(x)isnumeric(x)   );

% NOTE: I cahnged outputtype to a parameter from optional, there are a
% bunch of alternatives in the other folders in this functin's dir i was
% learnign how to use it, the note below this suggests i wanted to see
% dataoutputtype at the command line to remind me but if not passed in, use
% struct, but i think a better approach is to have it be naemvalue and by
% default i basically always tab complete anwya so i'll see the option
   
parse(p,filelist,varargin{:});

filelist       = p.Results.filelist;
outputtype     = p.Results.outputtype;
importopts     = p.Results.importopts;
retimeornot    = p.Results.retime;
newtime        = p.Results.newtime;
readvarnames   = p.Results.ReadVariableNames;
% nanval         = p.Results.replacewithnan;
   
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   
   % either pass in a file list or a path to files
   filelist = makefilelist(filelist);
   
   % get the full path and file type
   [filepath,filetype,numfiles] = getListInfo(filelist);
   
   % add opts to default importopts
   %    importopts.VariableNamingRule = '
   
   % read the data
   data = getRequest(filelist,filepath,filetype,numfiles,importopts,outputtype);
   
   %    % replace nan val
   %    fields   = fieldnames(data);
   %    for n = 1:numel(fields)
   %       datn = data.(fields{n});
   %       if isnan(nanval)
   %          inan  = isnan(datn);
   %       else
   %          inan  = datn == nanval;
   %       end
   %       datn(inan) = nan;
   %       data.(fields{n}) = datn;
   %    end
   
   % clean and retime timetables if requested. each field is a table
   fields = fieldnames(data);
   if strcmp(outputtype,'timetable') && istimetable(data.(fields{1}))
      data = cleantimetable(data,retimeornot,newtime);
   else
      
      if numel(fields) == 1
         data = data.(fields{1});
      end
      
   end
   
end

function defaultopts = defaultImportOpts(filenameorlist)
   
   % below I use a dummy importoptions object for the case where the file
   % isn't compatible with detectImportOptions and send it back with
   % variablenames 'false' to check later
   
   filelist    = makefilelist(filenameorlist);
   filename    = [filelist(1).folder '/' filelist(1).name];
   
   if isspreadsheet(filename) || istextfile(filename)
      defaultopts = detectImportOptions(filename);
   else
      defaultopts = matlab.io.text.DelimitedTextImportOptions;
      defaultopts.VariableNames = 'false';
   end
   
end

function filelist = makefilelist(filenameorlist)
   
   if isstruct(filenameorlist)
      filelist    = filenameorlist;
   else
      filelist    = dir(fullfile(filenameorlist)); % convert filename to list
   end
   
   if isempty(fieldnames(filelist))
      error('empty list');
   end
   
end

function data = getRequest(filelist,filepath,filetype,numfiles,opts,request)
   
   % this says to detectImportOptions if they weren't provided
   getopts = false;
   if strcmp(opts.VariableNames,'false')
      getopts = true;
   end
   % opts.VariableNames is only false if the file is not compatible with
   % importopts, its a dummy setting set in defaultImportOpts
   
   for iFile = 1:numfiles
      
      % for each file, a fieldName will be created in the main structure
      % that will hold all of the data. for h5/nc or any other requested
      % structure output, there will then be a nested structure contianing
      % all the datasets in that file. if only one file is passed in, the
      % main struct will be collapsed, see the main calling routine
      
      thisName    = filelist(iFile).name;
      thisFile    = [filepath '/' thisName];
      thisName    = strrep(thisName,filetype,'');
      thisName    = strrep(thisName,' ','_');
      fieldName   = matlab.lang.makeValidName(thisName,'ReplacementStyle','delete');
      
      
      switch filetype
         
         % SPREADSHEETS
         case {'.xlsx','.csv','.xls','.dat','.txt'}
            
            % isspreadsheet could replace the need for a switch at all
            if getopts == true
               if isspreadsheet(filetype)
                  opts  = detectImportOptions(thisFile,'FileType','spreadsheet');
               else
                  opts  = detectImportOptions(thisFile,'FileType','text');
               end
            end
            
            % as an example, this is in readATS
            % opts.Delimiter      = {' '};
            % opts.CommentStyle   = {'#'};
            
            switch request
               
               case 'timetable'
                  
                  % matlab doesn't let 'ReadVariableNames' be set in the
                  % opts structure, so default behavior is to pass in opts
                  %  with PreserveVariableNames = true and opts.DataLines
                  % and opts.VariableNamesLine set outside the function
                  try
                     data.(fieldName) = readtimetable(thisFile,opts,   ...
                        'ReadVariableNames',true);
                  catch ME
                     try
                        data.(fieldName) = readtimetable(thisFile,opts,...
                           'ReadVariableNames',false);
                     catch METOO
                        data.(fieldName) = readtable(thisFile,opts,...
                           'ReadVariableNames',true);
                        warning('returning table, no datetime found');
                        
                     end
                  end
                  
               otherwise % subsumes case 'table'
                  
                  try data.(fieldName) = readtable(thisFile,opts,   ...
                        'ReadVariableNames',true);
                  catch ME
                     data.(fieldName) = readtable(thisFile,opts,    ...
                        'ReadVariableNames',false);
                  end
            end
            
            % NC
         case {'.nc','.nc4'}
            
            switch request
               
               case {'timetable','table'}
                  
                  % rather than error, should first check the data size
                  msg = ['timetable output not supported for nc files, \n' ...
                     'using struct instead'];
                  warning(msg);
                  
               otherwise % subsumes case 'struct'
                  
                  data.(fieldName) = ncreaddata(thisFile,ncvars(thisFile));
            end
            
            
            % h5
         case '.h5'
            
            switch request
               
               case {'timetable','table'}
                  
                  % rather than error, should first check the data size
                  msg = ['timetable output not supported for h5 files, \n' ...
                     'using struct instead'];
                  warning(msg);
                  
               otherwise % subsumes case 'struct'
                  
                  data.(fieldName) = h5readdata(thisFile);
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

function data = cleantimetable(data,retimeornot,newtime)
   
   tables      = fieldnames(data);
   numtables   = numel(tables);
   
   % quality control checks
   for n = 1:numtables
      data.(tables{n}) = tablecleaner(data.(tables{n}),'regularize',    ...
         retimeornot,'newtime',newtime);
   end
   
   % if there is only one table, option to return the timetable itself
   if numtables == 1
      data = data.(tables{n});
   end
   
   
end

% function data = cleantimetable(data,retimeornot,newtime,newstep)
%
%    tables      = fieldnames(data);
%    numtables   = numel(tables);
%
% % quality control checks
%    for n = 1:numtables
%
%       T     = data.(tables{n});
%
%       % make sure the Time dimension in named Time
%       T     = renametimetabletimevar(T);
%
%
%       QA(n).issorted       = issorted(T);
%       QA(n).isregular      = isregular(T);
%       QA(n).ismissing      = ismissing(T);
%       QA(n).nummissing     = sum(QA(n).ismissing);
%       QA(n).duplicates     = getduplicatetimes(T);
%
%       % clean
%       [T,QA] = tablecleanup(QA,T,'first',retimeornot,newtime,newstep);
%
%       % add the QA info to the table properties
%       T = addprop(T,{'QA'},{'table'});
%       T.Properties.CustomProperties.QA = QA;
%
%       % put the table back
%       data.(tables{n})  = T;
%    end
%
%    % i commented this out and instead add to custom props
%    % data.QA  = QA;
%
%    % if there is only one table, option to return the timetable itself
%    if numtables == 1
%       data = data.(tables{n});
%    end
%
%
% % % I stopped here b/c without knowing dt I don't want to retime
% % % get the min-max dates to retime
% %    T     = data.(tables{1});
% %    Tmin  = min(T.Time);
% %    Tmax  = max(T.Time);
% %    dt    = T.Properties.TimeStep;
% %
% %    for n = 2:numtables
% %
% %       T     = data.(tables{n});
% %       Tmin  = min(Tmin,min(T.Time));
% %       Tmax  = max(Tmax,max(T.Time));
% %
% %    end
% %
% % % retime the tables to a consistent timeframe
% %    Time  = Tmin:dt:Tmax;
%
%
% end
%
% function dupes = getduplicatetimes(T)
%
%    dupes = sort(T.Time);
%    TF    = (diff(dupes) == 0);
%    dupes = dupes(TF);
%    dupes = unique(dupes);
%
% end
%
% function [T,QA] = tablecleanup(QA,T,whichrow,retimeornot,newtime,newstep)
%
% % Part 1: stuff we do regardless of retime
%
%    % remove missing entries
%    T     = sortrows(T,'Time');
%    ok    = ~ismissing(T.Time);
%    T     = T(ok,:);
%
%    % find unique times and unique timesteps
%    uniquetimes = unique(T.Time);
%
%   [dtcounts,  ...
%    dtsteps ]   = groupcounts(diff(T.Time));
%    dtfreq      = dtcounts./(sum(dtcounts)+1);
%
%    % choose the most frequent timestep for retiming
%    mostfrequentstep     = dtsteps(findmax(dtfreq));
%
%    % save this information
%    QA.uniquetimes       = uniquetimes;
%    QA.dtcounts          = dtcounts;
%    QA.dtsteps           = dtsteps;
%    QA.dtfreq            = dtfreq;
%    QA.mostfrequentstep  = mostfrequentstep;
%    QA.retimehistory     = 'removed duplicate values with: retime(T,uniquetimes,''first'')';
%
%    % do a limited retime to remove duplicate values
%    switch whichrow
%       case 'first'
%          T = retime(T,uniquetimes);
%
%       case 'second'
%          T = retime(T,uniquetimes,'previous');
%
%       case 'mean'
%          T = retime(T,uniquetimes,'mean');
%    end
%
% % Part 2: stuff we do if we retime to a new timestep
%
%    if retimeornot == true
%
%       if isnat(newstep) && isnat(newtime)
%          % no new time/step provided, use most frequent one
%          newstep        = mostfrequentstep;
%
%          % warning if two unique timesteps occur with >40% frequency
%          if sum(dtfreq>0.40) > 2
%             QA.warning  = 'two unique timesteps occur with >40% frequency';
%          end
%
%       elseif isnat(newstep) && ~isnat(newtime)
%          % a new time was provided
%          T        = retime(T,newtime,'linear');
%          newstep  = T.Properties.TimeStep;
%
%       elseif ~isnat(newstep) && isnat(newtime)
%          % a new time step was provided
%          T        = retime(T,'regular','linear','TimeStep',newstep);
%
%          % NOTE: I think to use 'daily' syntax need:
%          % T      = retime(T,'daily','linear');
%          % so would need option to pass in duration or char
%
%          % ALSO: might not be worth it to get all this fucntionality in
%          % here b/c the retime method is also important e.g., 'linear' or
%          % 'mean' (or 'sum' for some quantities)
%
%       end
%
%       QA.newtimestep = newstep;
%
%    end
%
% end






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