function fullpath = matfilepath(varargin)
   %MATFILEPATH Build full path to matfile relative to top level project folder.
   %
   % FULLPATH = MATFILEPATH(VARARGIN) builds a full path to a .mat file by
   % appending each element of varargin to the project base path. The file name
   % is always assumed to be the last element of varargin, and each eleemnt is
   % assumed to be a folder name up to but not including the last one.
   %
   % See also: figfilepath

   % Process inputs
   narginchk(1,Inf)
   varargin = cellmap(@convertStringsToChars, varargin);

   % Build the full path to the .mat file
   fullpath = fullfile(projectpath(), 'data', varargin{:});

   % Check if filename has a .mat extension
   [parentname, ~, ext] = fileparts(fullpath);

   if ~strcmp(ext, '.mat')
      % Append .mat
      fullpath = [fullpath, '.mat'];
   end

   if ~isfolder(parentname)
      warning('project data folder does not exist')
   end
end
