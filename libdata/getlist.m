function [ list ] = getlist( pathdata,pattern,varargin )
%GETLIST generates a list of files matching pattern in folder path

%-------------------------------------------------------------------------------
p                 = inputParser;
p.FunctionName    = 'getlist';
p.CaseSensitive   = false;
p.KeepUnmatched   = true;

validpath = ...
   @(x)validateattributes(x,{'char','string'},{'scalartext'},'getlist','path',1);
validpattern = ...
   @(x)validateattributes(x,{'char','string'},{'scalartext'},'getlist','pattern',2);
validoptions = ...
   @(x)any(validatestring(x,{'show','none'}));

addRequired(   p,'path',                     validpath            );
addRequired(   p,'pattern',                  validpattern         );
addOptional(   p,'postget',      'none',     validoptions         );
addParameter(  p,'subdirs',      false,      @(x)islogical(x)     );

parse(p,pathdata,pattern,varargin{:});

pathdata    = p.Results.path;
pattern     = p.Results.pattern;
postget     = p.Results.postget;
subdirs     = p.Results.subdirs;

%-------------------------------------------------------------------------------

% note: I think using fullfile(path,file) or fullfile(path,wildcard) negates the
% need to ever deal with trailing filesep, and I've been using it wrong all this
% time like fullfile([path file])
if strcmp(pathdata(end),'/') == false; pathdata = [pathdata '/']; end

[pattern,pflag] = fixpattern(pattern,subdirs);

list = dir(fullfile(pathdata,pattern));
% list = list([list.isdir]); % activate if you only want folders
list = rmdotfolders(list);

% if the pattern is **, only return directories
if pflag==true
   list = list([list.isdir]);
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

