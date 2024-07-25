function reopentabs(varargin)
   %REOPENTABS Reopen a list of files (tabs) of type 'matlab' or 'preview'.
   %
   % default list option is the most recent saved list (created with 'savetabs')
   % 
   % TODO: add options to showtabs to see the most recent list or the most N recent

   validopts = {'pickfile','latest'};
   validtabs = {'matlab','preview'};
   
   parser = inputParser;
   parser.FunctionName = mfilename;
   parser.addOptional('pickfile', 'latest', @(x)any(validatestring(x,validopts)));
   parser.addOptional('tabstype', 'matlab', @(x)any(validatestring(x,validtabs)));
   parser.parse(varargin{:});

   switch parser.Results.tabstype
      case 'matlab'
         reopen_matlab_tabs(parser.Results.pickfile);
      case 'preview'
         % i use automate for this now but could copy the old script here
         reopen_preview_tabs(parser.Results.pickfile);
   end
end

%% Local Functions
function reopen_matlab_tabs(pickfile)

   directory = fullfile(getenv('MATLABUSERPATH'),'opentabs/matlab_editor');
   oldcwd = pwd;

   if strcmp(pickfile,'pickfile')
      cd(directory)
      fname = uigetfile;

      % this is the old way but there's no reason to use it
      %fname = input('copy and paste the filename','s');
      %fname = [pathin fname '.mat'];

   elseif strcmp(pickfile,'latest')

      % use the most recent file
      [fname,filedate] = getlatestfile(directory);

      % check if the most recent file matches the file name
      if ~strcmp(filedate,strrep(strrep(fname,'open_',''),'.mat',''))
         warning('file date does not match file name, fyi');
      end

   end

   load([directory fname],'filelist')

   % if filenames changed, the reopen may not work
   for n = 1:numel(filelist)
      thisfile = filelist(n);
      try
         open(thisfile)
      catch
         % strip out the path
         [~,fname,ext] = fileparts(thisfile);
         fname = [char(fname), char(ext)];
         tryfile = which(fname);
         try
            open(tryfile)
         catch
            % let it go
         end
      end
   end
   % go back to where we started
   cd(oldcwd)
end

%-------------------------------------------------------------------------------
function reopen_preview_tabs
end
