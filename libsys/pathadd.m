function oldpath = pathadd(pathlist, addSubPaths, pathAppend, ignorePaths)
% PATHADD add path(s) to matlab search path
%
% This function adds specified paths to MATLAB's search path. By default,
% it adds the current directory and all its subdirectories, ignoring
% standard MATLAB special directories, as well as '.git', '.svn,', 'CVS',
% '.' and '..'.
%
% pathadd() % adds current directory and subdirectories
%
% Inputs:
%
% pathlist: char, cellstr, or string array of paths to add. Default is pwd().
%
% addSubPaths: logical indicating to add all sub-folders of each path in
% pathlist or not. Default is true.
%
% pathAppend: char or string, '-begin' adds specified folders to the top of the
% search path, '-end' adds them to the end. Default is '-end'.
%
% ignorePaths: char, cellstr, or string array of patterns to ignore. Any path
% containing a folder that matches the pattern will be removed. Paths are
% generated using genpath, which ignores folders named private, folders that
% begin with the @ character (class folders), folders that begin with the +
% character (package folders), folders named resources, or subfolders within any
% of these. Therefore these will be ignored by default. In addition, '.git',
% '.svn,', 'CVS', '.' and '..' are ignored.

arguments
   pathlist (:,1) string = pwd()
   addSubPaths (1,1) logical = true
   pathAppend (1,1) string = "-end"
   ignorePaths (:, 1) string = ""
end

% Temporarily turn off warnings about paths not already being on the path
withwarnoff({'MATLAB:mpath:nameNonexistentOrNotADirectory', ...
   'MATLAB:rmpath:DirNotFound'});

% Add the default ignorePaths to the provided ones.
ignorePaths = [ignorePaths; ".git"; ".svn"; "CVS"; "."; ".."];

% Store the original path
oldpath = path;

for n = 1:numel(pathlist)
   
   % Generate all paths
   if addSubPaths
      
      % Generate a list of all sub-folders
      subpaths = strsplit(genpath(pathlist(n)), pathsep);
      
      % Remove ignored folders
      keep = @(folders, ignore) cellfun('isempty', (strfind(folders, ignore)));
   
      for m = 1:numel(ignorePaths)
         subpaths = subpaths(keep(subpaths, ignorePaths(m)));
      end
      
      % Rebuild the path string. Insert platform-specific path separator between
      % each path in the subpaths cell array, then join them horizontally.
      subpaths = strcat(subpaths, pathsep);
      subpaths = horzcat(subpaths{:});
   
   else
      subpaths = pathlist(n);
   end
   
   % Add the paths to the start or end of the path designated by pathAppend
   addpath(subpaths, pathAppend);
end

% % Keep this around in case I need a version of this function that does not use
% an arguments block.

% % Set defaults
% if nargin < 4 || isempty(ignore); ignore = {'.git','.svn'}; end
% if nargin < 3 || isempty(pathloc); pathloc = '-end'; end
% if nargin < 2 || isempty(addsubpaths); addsubpaths = true; end
% if nargin < 1 || isempty(pathstr); pathstr = pwd(); end
% 
% % Parse inputs
% if ischar(ignore); ignore = {ignore}; end
% if ischar(ignore); ignore = {ignore}; end

% Notes:
% % Use genpath b/c dir does not automatically ignore the @, +, resources, etc.
% subpaths = dir(fullfile(pathstring, '**/*'));
% subpaths = subpaths([subpaths.isdir]);
% for n = 1:numel(ignorePaths)
%    subpaths = subpaths(keep({subpaths.folder},ignorePaths(n)));
%    subpaths = subpaths(keep({subpaths.name},ignorePaths(n)));
% end
% 
% % contains is not octave compatible, otherwise I would use this:
% subpaths = subpaths(~contains({subpaths.folder},ignore));
% subpaths = subpaths(~ismember({subpaths.name},ignorePaths));
% 
% pathstring = fullfile({subpaths.folder}', {subpaths.name}');
   