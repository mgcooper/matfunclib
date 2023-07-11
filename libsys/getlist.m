function [ list ] = getlist( dirpath, pattern, varargin )
%GETLIST get a list of files matching pattern in the folder dirpath
% 
%     [ list ] = getlist( dirpath,pattern,varargin )
% 
% Matt Cooper, 2022, https://github.com/mgcooper
% 
% See also getfilelist, getgisfilelist, fnamefromlist

% NOTE: 'pattern' is a function designed to match text patterns ... not sure if
% my use here conflicts with that but when I tried to call this function from
% getfilelist which used 'pattern' as an optional input the input parser here
% interpreted pattern as the output of the function 'pattern'

% parse inputs
[dirpath, pattern, postget, subdirs, asfiles] = parseinputs( ...
   dirpath, pattern, mfilename, varargin{:});

% parse the wildcard pattern
[pattern, pflag] = fixpattern(pattern,subdirs);

list = dir(fullfile(dirpath,pattern));
% list = list([list.isdir]); % activate if you only want folders
list = rmdotfolders(list);

% if the pattern is **, only return directories
if pflag==true
   list = list([list.isdir]);
end

% if filenames is true, return a filename list
if asfiles == true
   list = fnamefromlist(list,'asstring');
end

if postget == "show"
   showlist(list);
end


function [pattern,pflag] = fixpattern(pattern,searchsubs)

pflag=false; % assume the pattern is for files, not directories

% if the pattern is just the suffix e.g. 'tif' or 'mat', add *.
if ~contains(pattern,'.') && ~contains(pattern,'*')
   pattern = ['*.' pattern];
   % if the pattern is **, don't adjust it
elseif contains(pattern,'**')
   pflag=true;
   return
   % if the pattern has the * but no . add the .    (e.g. *mat)
elseif contains(pattern,'*') && ~contains(pattern,'.')
   % if the pattern is just *, use it (e.g. to list all folders)
   if strcmp(pattern,'*')
      return;
   else
      % otherwise, add the . so we get all the fiels
      pattern = [pattern(1) '.' pattern(2:end)];
   end
   % if the pattern has the . but no * add the *   (e.g. .mat)
elseif contains(pattern,'.') && ~contains(pattern,'*')
   pattern = ['*' pattern];
end

% finally, if searchsubs is true, append **/ to the pattern
if searchsubs
   pattern = ['**/' pattern];
end


function [dirpath, pattern, postget, subdirs, asfiles] = parseinputs( ...
   dirpath, pattern, funcname, varargin);

p = inputParser;
p.FunctionName = funcname;
p.CaseSensitive = false;
p.KeepUnmatched = true;

validpath = ...
   @(x)validateattributes(x,{'char','string'},{'scalartext'},'getlist','path',1);
validpattern = ...
   @(x)validateattributes(x,{'char','string'},{'scalartext'},'getlist','pattern',2);
validoptions = ...
   @(x)any(validatestring(x,{'show','none'}));

addRequired( p,'dirpath', validpath );
addRequired( p,'pattern', validpattern );
addOptional( p,'postget', 'none', validoptions );
addParameter(p,'subdirs', false, @(x)islogical(x) );
addParameter(p,'asfiles', false, @(x)islogical(x) );

parse(p,dirpath,pattern,varargin{:});

dirpath = p.Results.dirpath;
pattern = p.Results.pattern;
postget = p.Results.postget;
subdirs = p.Results.subdirs;
asfiles = p.Results.asfiles;

% could use optionParser for subdirs, asfiles, asstring,etc, and change postget
% to name-value or add it to optionParser as 'showlist'