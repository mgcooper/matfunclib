function foldername = mfoldername(filename, appendpath, makefolder)
   %MFOLDERNAME Convert filename to a fullfile path to its parent folder.
   %
   % Syntax
   %
   % foldername = mfoldername(filename) generates a full path to the parent
   % folder of filename e.g. foldername = /full/path/to/filename
   %
   % foldername = mfoldername(mfilename('fullpath')) when used within a matlab
   % function generates a full path to filename in the folder containing the
   % calling function e.g. filename = /full/path/to/calling/function/
   %
   % Inputs
   %
   % filename: file name of m-file on the user path, or fullpath to m-file. If a
   % file name of an m-file is provided, the 'which' command is used to find the
   % full path. If a fullpath is provided, it is used as-is.
   %
   % appendpath: additional path string that is appended to the foldername, e.g.
   % 'data' to save data in a folder named 'data' that is contained within the
   % parent folder of filename.
   %
   % Examples
   %
   % Get the parent folder of a function on your path foldername =
   % mfoldername('plot');
   %
   % From a calling function: foldername = mfoldername(mfilename('fullpath'))
   %
   % Append an additional directory foldername =
   % mfoldername(mfilename('fullpath'),'data');
   %
   %
   % See also localfile

   % Optional arguments
   if nargin < 2
      appendpath = "";
   end
   
   if nargin < 3
      makefolder = false;
   end

   % If FILENAME is a folder path and the last character is a filesep, the
   % filesep needs to be removed otherwise fileparts returns the wrong parts.
   numchars = numel(filename);
   if strcmp(filename(numchars), filesep)
      filename = filename(1:numchars-1);
   end

   % The full path to the file was provided
   if isfolder(fileparts(filename))
      foldername = fullfile(fileparts(filename), appendpath);
   else
      % If filename is located on the specified path or in the current folder
      if isfile(filename)
         % Convert filename to fullpath of parent folder
         foldername = fullfile(fileparts(which(filename)), appendpath);
      end
   end

   % make the folder?
   if makefolder && ~isfolder(foldername)
      mkdir(foldername)
   end
end
