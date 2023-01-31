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
p                 = magicParser;
p.FunctionName    = mfilename;

p.addRequired(    'dirpath',                 @(x)ischarlike(x)    );
p.addOptional(    'pattern',     '*',        @(x)ischarlike(x)    );

p.parseMagically('caller');

pattern = p.Results.pattern;
%-------------------------------------------------------------------------------

% NOTE: this works as-is but then I started adding the input parsing scheme from
% getlist and decided to just add 'asfiles' as an option to getlist

filelist = fnamefromlist(getlist(dirpath,pattern),'asstring');






