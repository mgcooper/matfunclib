function filelist = getfilelist(foldername, varargin)
   %GETFILELIST get a list of files in directory matching pattern
   %
   %  FILELIST = getfilelist(FOLDERNAME) returns cell array FILELIST containing
   %  the full path to each file in folder FOLDERNAME.
   %
   %  FILELIST = GETFILELIST(FOLDERNAME, PATTERN) returns cell array FILELIST
   %  containing the full path to each file in folder dirpath with file name
   %  matching char PATTERN.
   %
   % Example
   %     filelist = getfilelist(pwd)
   %
   % Matt Cooper, 23-Jan-2023, https://github.com/mgcooper
   %
   % See also getlist, getgisfilelist

   % parse inputs
   [foldername, pattern, liststyle] = parseinputs( ...
      foldername, mfilename, varargin{:});

   % NOTE: this works as-is but then I started adding the input parsing scheme
   % from getlist and decided to just add 'asfiles' as an option to getlist
   filelist = fnamefromlist(getlist(foldername,pattern),'asstring');

   if liststyle == "filenames"
      [~,filenames,fileexts] = fileparts(filelist);
      filelist = strcat(filenames,fileexts);

   elseif liststyle == "folders"
      filelist = filelist(isfolder(filelist));

   elseif liststyle == "parents"
      % note, in some cases filelist may already be a list of sub-folders, and
      % this will strip the subfolder names and return the parent folder, so I
      % need to unify getlist, getfilelist, fnamefromlist, etc
      filelist = fileparts(filelist);
   end
end

%% input parsing
function [foldername, pattern, liststyle] = parseinputs( ...
      foldername, funcname, varargin)
   
   parser = inputParser;
   parser.FunctionName = funcname;
   parser.addRequired('foldername', @ischarlike);

   % validation
   validstyles = {'fullpath','filenames','folders'};
   validoption = @(x)any(validatestring(x,validstyles));

   if nargin == 2
      if ismember(varargin{1}, validstyles)
         parser.addOptional('liststyle', 'fullpath', validoption);
         parser.parse(foldername, varargin{:});
         liststyle = parser.Results.liststyle;
         pattern = '*';
      else
         parser.addOptional('pattern', '*', @ischarlike);
         parser.parse(foldername, varargin{:});
         pattern = parser.Results.pattern;
         liststyle = 'fullpath';
      end
   else
      parser.addOptional('pattern', '*', @ischarlike);
      parser.addOptional('liststyle', 'fullpath', validoption );
      parser.parse(foldername, varargin{:});
      pattern = parser.Results.pattern;
      liststyle = parser.Results.liststyle;
   end
end
