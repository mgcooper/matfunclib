function filelist = getfilelist(foldername,varargin)
%GETFILELIST get a list of files in directory matching pattern
% 
%  FILELIST = getfilelist(FOLDERNAME) returns cell array FILELIST containing the
%  full path to each file in folder FOLDERNAME.
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
[foldername, pattern, liststyle] = parseinputs(foldername, mfilename, varargin{:});

% NOTE: this works as-is but then I started adding the input parsing scheme from
% getlist and decided to just add 'asfiles' as an option to getlist
filelist = fnamefromlist(getlist(foldername,pattern),'asstring');

if liststyle == "filenames"
   [~,filenames,fileexts] = fileparts(filelist);
   filelist = strcat(filenames,fileexts);
   
elseif liststyle == "folders"
   filelist = filelist(isfolder(filelist));
   
elseif liststyle == "parents" 
   % note, in some cases filelist may already be a list of sub-folders, and this
   % will strip the subfolder names and return the parent folder, so I need to
   % unify getlist, getfilelist, fnamefromlist, etc
   filelist = fileparts(filelist);
end

%% input parsing
function [foldername, pattern, liststyle] = parseinputs(foldername, funcname, varargin)
p = inputParser;
p.FunctionName = funcname;
p.addRequired('foldername', @ischarlike);

% validation
validstyles = {'fullpath','filenames','folders'};
validoption = @(x)any(validatestring(x,validstyles));

if nargin == 2 
   if ismember(varargin{1}, validstyles)
      p.addOptional('liststyle', 'fullpath', validoption);
      p.parse(foldername, varargin{:});
      liststyle = p.Results.liststyle;
      pattern = '*';
   else
      p.addOptional('pattern', '*', @ischarlike);
      p.parse(foldername, varargin{:});
      pattern = p.Results.pattern;
      liststyle = 'fullpath';
   end
else
   p.addOptional('pattern', '*', @ischarlike);
   p.addOptional('liststyle', 'fullpath', validoption );
   p.parse(foldername, varargin{:});
   pattern = p.Results.pattern;
   liststyle = p.Results.liststyle;
end
