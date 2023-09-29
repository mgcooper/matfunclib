function list = getlist(dirpath, pattern, varargin)
   %GETLIST Get a list of files matching pattern in the folder dirpath.
   %
   % list = getlist(dirpath, pattern, varargin)
   %
   % Matt Cooper, 2022, https://github.com/mgcooper
   %
   % See also getfilelist, getgisfilelist, fnamefromlist

   % parse inputs
   [dirpath, pattern, postget, subdirs, asfiles] = parseinputs( ...
      dirpath, pattern, mfilename, varargin{:});

   % parse the wildcard pattern
   [pattern, pflag] = fixpattern(pattern, subdirs);

   list = rmdotfolders(dir(fullfile(dirpath, pattern)));
   % list = list([list.isdir]); % activate if you only want folders

   % if the pattern is **, only return directories
   if pflag==true
      list = list([list.isdir]);
   end

   % if filenames is true, return a filename list
   if asfiles == true
      list = fnamefromlist(list, 'asstring');
   end

   if postget == "show"
      showlist(list);
   end
end

function [pattern, pflag] = fixpattern(pattern,searchsubs)

   pflag = false; % assume the pattern is for files, not directories

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
end

%% Inpute Parser
function [dirpath, pattern, postget, subdirs, asfiles] = parseinputs( ...
      dirpath, pattern, funcname, varargin)

   parser = inputParser;
   parser.FunctionName = funcname;
   parser.CaseSensitive = false;
   parser.KeepUnmatched = true;

   validpath = @(x) validateattributes(x, ...
      {'char', 'string'}, {'scalartext'}, funcname, 'dirpath', 1);
   validpattern = @(x) validateattributes(x, ...
      {'char','string'}, {'scalartext'}, funcname, 'pattern', 2);
   validoptions = @(x) any(validatestring(x, {'show', 'none'}));

   parser.addRequired('dirpath', validpath );
   parser.addRequired('pattern', validpattern );
   parser.addOptional('postget', 'none', validoptions );
   parser.addParameter('subdirs', false, @islogical);
   parser.addParameter('asfiles', false, @islogical);

   parser.parse(dirpath, pattern, varargin{:});

   dirpath = parser.Results.dirpath;
   pattern = parser.Results.pattern;
   postget = parser.Results.postget;
   subdirs = parser.Results.subdirs;
   asfiles = parser.Results.asfiles;
end
