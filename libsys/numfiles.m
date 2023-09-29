function N = numfiles(varargin)
   %NUMFILES generates a list of files matching pattern in folder path
   %
   % N = NUMFILES()
   % N = NUMFILES(FILEPATH)
   % N = NUMFILES(FILEPATH, PATTERN)
   %
   % Matt Cooper, 2022, https://github.com/mgcooper
   %
   % See also:

   if nargin == 0
      filepath = pwd;
      pattern = '*';
   elseif nargin == 1
      filepath = varargin{1};
      pattern = '*';
   elseif nargin == 2
      filepath = varargin{1};
      pattern = varargin{2};
   end

   [pattern, flag] = fixpattern(pattern);

   list = dir(fullfile(filepath, pattern));
   % list = list([list.isdir]); % activate if you only want folders
   list(strncmp({list.name}, '.', 1)) = [];

   % if the pattern is **, only return directories
   if flag==true
      list = list([list.isdir]);
   end

   N = numel(list);
end

%% Local function
function [pattern, pathflag] = fixpattern(pattern)

   pathflag = false; % assume the pattern is for files, not directories
   
   if ~contains(pattern,'.') && ~contains(pattern,'*')
      % if the pattern is just the suffix e.g. 'tif' or 'mat', add *.
      pattern = ['*.' pattern];
      
   elseif contains(pattern,'**')
      % if the pattern is **, don't adjust it
      pathflag = true;
      return
      
      % % next two lead to unexpected behavior, try them, they only return the
      % hidden dotfiles 
      % % if the pattern has the * but no . add the .    (e.g. *mat)
      % elseif contains(pattern,'*') && ~contains(pattern,'.')
      %   pattern = [pattern(1) '.' pattern(2:end)];
      % % if the pattern has the . but no * add the *   (e.g. .mat)
      % elseif contains(pattern,'.') && ~contains(pattern,'*')
      %   pattern = ['*' pattern];
   end
end
