function filename = localfile(mfilepath,filename)
   %LOCALFILE convert filename to a fullfile path in folder mfilepath
   %
   %  filename = localfile(mfilename('fullpath'),filename) when used within a
   %  matlab function generates a full path to filename in the folder containing
   %  the calling function e.g. filename =
   %  /full/path/to/calling/function/filename
   %
   % localfile is particularly useful for generating filenames for files
   % contained within the same folder as a function, to both save and load
   % files. For example, generating a custom colormap, checking if a file exists
   % in the generating function parent folder, if so, save it, and in another
   % function, do the same but instead load the colormap file, or create it if
   % it doesn't exist. See wacmap.m.
   %
   % Example
   %
   % From a calling function:
   % mfilepath = mfilename('fullpath')
   % filename = 'myfile.txt'
   % filename = localfile(mfilepath,filename)
   %
   % See also

   % convert to fullpath
   filename = fullfile(fileparts(which(mfilepath)),filename);
end
