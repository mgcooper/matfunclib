function tf = isonpath(fullpath)
   %ISONPATH Determine if path string is on the matlab path.
   %
   %  tf = isonpath(fullpath)
   %
   % See also: isfullpath isfullfile

   pathCell = strsplit(path, pathsep);

   if ispc
      tf = any(strcmpi(fullpath, pathCell));
   else
      tf = any(strcmp(fullpath, pathCell));
   end

   % % This is simplest but contains is not octave compatible
   % tf = contains( ...
   %    [pathsep, path, pathsep], ...
   %    [pathsep, fullpath, pathsep], 'IgnoreCase', ispc);
end
