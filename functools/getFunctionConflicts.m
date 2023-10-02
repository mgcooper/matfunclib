function filelist = getFunctionConflicts(varargin)
   %GETFUNCTIONCONFLICTS Find duplicate function names
   %
   % Syntax
   %
   %  filelist = getFunctionConflicts(funcname) returns a filelist in the format
   %  of dir() with an additional column 'conflicts' that contains the full path
   %  to all functions with name funcname. If only one function named funcname
   %  is found on the current path, the entry is empty.
   %
   %  filelist = getFunctionConflicts('library',funclibrary) returns a list of
   %  all functions in the function library folder funclibrary
   %
   % Matt Cooper, 30-Nov-2022, https://github.com/mgcooper
   %
   % See also getFunctionDependencies

   % input parsing
   [funcpath, funcname, flibrary] = parseinputs(mfilename,varargin{:});

   % Determine if a function path, library folder, or function name was provided
   isfuncpath = ~isempty(funcpath);
   islibrary = ~isempty(flibrary);
   isfuncname = ~isempty(funcname);

   if ~isfuncname && ~islibrary && ~isfuncpath
      error('specify function name or function library');
   end

   % figure out if a single file or folder of files is requested
   if isfuncpath && ~isfolder(funcpath)
      % if a full path to a function file is passed in, treat it the same as funcname
      isfuncname = true;
   elseif islibrary
      % if a library is requested, build a full path
      funcpath = fullfile(getenv('MATLABFUNCTIONPATH'),flibrary);
   elseif isfuncname
      % if a function name is requested, build a full path
      funcpath = which(funcname); % doesn't matter which one is found
   end

   % if a full path to a function file is passed in, use which -all and return
   if isfuncname
      filelist = dir(fullfile(funcpath));
      filelist = findconflicts(filelist,1);
      return

   else % check all files in the funcpath

      filelist = getlist(funcpath,'*m','subdirs',true);
      numfiles = numel(filelist);

      % filenames to ignore
      ignore   = {'readme','test','temp'};

      for n = 1:numfiles

         % we don't want the full path otherwise which only finds it
         % f = fullfile(funcpath,filelist(n).name);

         if contains(filelist(n).name,ignore)
            continue
         else
            filelist = findconflicts(filelist,n);
         end
      end
   end
end

function filelist = findconflicts(filelist,idx)

   allfiles = which(filelist(idx).name,'-all');
   if numel(allfiles) > 1
      warning(['two copies found: ' filelist(idx).name]);
      filelist(idx).conflicts = allfiles;
   else
      filelist(idx).conflicts = [];
   end
end

function [funcpath, funcname, flibrary] = parseinputs(funcname,varargin)

   % use contains on funcname b/c listallmfunctions includes .m but it is
   % convenient to pass in a function name w/o .m
   validfuncname = @(x) any(contains(listallmfunctions,x));
   validlibrarys = @(x) any(ismember(functiondirectorylist,x));
   validfuncpath = @(x) ischar(x)&&~any(ismember(x,{'library','funcname'}));
   
   parser = inputParser;
   parser.FunctionName = funcname;
   parser.CaseSensitive = true;
   parser.KeepUnmatched = true;
   parser.addOptional( 'funcpath', '', validfuncpath );
   parser.addParameter('funcname', '', validfuncname );
   parser.addParameter('flibrary', '', validlibrarys );
   parser.parse(varargin{:});
   
   funcpath = parser.Results.funcpath;
   funcname = parser.Results.funcname;
   flibrary = parser.Results.flibrary;
end
