function [isFile, isFolder] = isfullpath(str)
   %ISFULLPATH Checks if a string represents a full file or folder path.
   %
   % [isFile, isFolder] = isfullpath(str) returns isFile true if the string str
   % appears to represent a full file path, and isFolder true if it appears to
   % represent a full folder path. Both outputs are false otherwise.
   %
   % Example:
   %   [isFile, isFolder] = isfullpath('C:\Users\file.txt');
   %   % isFile returns true on Windows, isFolder returns false
   %   [isFile, isFolder] = isfullpath('/home/user/');
   %   % isFile returns false on Linux/Mac, isFolder returns true
   %
   % See also: isfullfile, ispathlike

   % Check if all components of path are non-empty
   [allPathParts{1:3}] = fileparts(str);
   isFile = all(~cellfun(@isempty, allPathParts));

   % Check for platform-specific full path for files
   if ispc
      isFile = isFile && ...
         notempty(regexp(allPathParts{1}, '^[a-zA-Z]:\\', 'once'));
   else
      isFile = isFile && startsWith(allPathParts{1}, '/');
   end

   % Check for platform-specific full path for folders
   isFolder = ismember(filesep, str) && notempty(fileparts(str));
   if ispc
      isFolder = isFolder && ...
         notempty(regexp(allPathParts{1}, '^[a-zA-Z]:\\', 'once'));
   else
      isFolder = isFolder && startsWith(allPathParts{1}, '/');
   end
end
