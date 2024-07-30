function fullpath = figfilepath(varargin)
   %FIGFILEPATH Build full path to graphics file relative to project folder.
   %
   % FULLPATH = FIGFILEPATH(VARARGIN) builds a full path to a .PNG file by
   % appending each element of varargin to the project base path. The file name
   % is always assumed to be the last element of varargin, and each element is
   % assumed to be a folder name up to but not including the last one.
   %
   % See also: matfilepath

   % Process inputs
   narginchk(1,Inf)
   varargin = cellmap(@convertStringsToChars, varargin);

   fullpath = fullfile(projectpath(), 'figs', varargin{:});

   % Append .png if it is not already
   fullpath = validateGraphicsFile(fullpath);
end

function filename = validateGraphicsFile(filename)
   %VALIDATEGRAPHICSFILE Validate filename for exportgraphics.

   % List of valid extensions
   validExtensions = {'.jpg', '.jpeg', '.png', '.tif', '.tiff', ...
      '.gif', '.pdf', '.emf', '.eps'};

   % Check if filename has a valid extension
   [~,~,ext] = fileparts(filename);

   if ~ismember(ext, validExtensions)
      % Append .png if the extension is not valid
      filename = [filename, '.png'];
   end
end
