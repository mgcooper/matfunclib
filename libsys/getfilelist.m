function filelist = getfilelist(dirpath,varargin)
%GETFILELIST get a list of files in directory matching pattern
% 
%  filelist = GETFILELIST(dirpath) returns cell array filelist containing the
%  full path to each file in folder dirpath
% 
%  filelist = GETFILELIST(dirpath,pattern) returns cell array filelist containing the
%  full path to each file in folder dirpath with file name matching pattern
% 
% Example
%     filelist = getfilelist(pwd)
% 
% Matt Cooper, 23-Jan-2023, https://github.com/mgcooper
% 
% See also getlist, getgisfilelist

%-------------------------------------------------------------------------------
% input parsing
%-------------------------------------------------------------------------------
p = magicParser;
p.FunctionName = mfilename;
p.addRequired('dirpath',@(x)ischarlike(x));

% validation
validstyles = {'fullpath','filenames','folders'};
validoption = @(x)any(validatestring(x,validstyles));

if nargin == 2 
   if ismember(varargin{1},validstyles)
      p.addOptional('liststyle','fullpath',validoption);
      pattern = '*';
   else
      p.addOptional('pattern','*',@(x)ischarlike(x));
      liststyle = 'fullpath';
   end      
else
   p.addOptional('pattern', '*', @(x)ischarlike(x) );
   p.addOptional('liststyle', 'fullpath', validoption );
end

p.parseMagically('caller');
%-------------------------------------------------------------------------------

% NOTE: this works as-is but then I started adding the input parsing scheme from
% getlist and decided to just add 'asfiles' as an option to getlist

filelist = fnamefromlist(getlist(dirpath,pattern),'asstring');

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

% % prob don't need thi sbut just noting thsee two are equivlane
% sites_v1_files = getfilelist(fullfile(p,'gages'),'filenames')
% sites_v1_files = strrep(strrep(sites_v1_files,'usgs_',''),'.csv','');
% 
% sites_v1_files = fnamefromlist(getlist(fullfile(p,'gages')));
% sites_v1_files = strrep(sites_v1_files,fullfile(p,'gages'),'');
% sites_v1_files = string(strrep(strrep(sites_v1_files,'/usgs_',''),'.csv',''));


