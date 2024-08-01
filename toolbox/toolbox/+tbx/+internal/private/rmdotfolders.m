function dirlist = rmdotfolders(dirlist, keepdirs)
   %RMDOTFOLDERS Remove dot folders from directory list.
   %
   % DIRLIST = RMDOTFOLDERS(DIRLIST)
   % DIRLIST = RMDOTFOLDERS(DIRLIST, TRUE)
   %
   % Description:
   %
   % DIRLIST = RMDOTFOLDERS(DIRLIST) Removes all elements of struct DIRLIST for
   % which DIRLIST.NAME begins with '.'.
   %
   % DIRLIST = RMDOTFOLDERS(DIRLIST, TRUE) Only removes elements of struct
   % DIRLIST for which DIRLIST.NAME begins with '.' and are less than three
   % characters in length. Use this to keep dot folders such as .github.
   %
   % See also:

   if nargin < 2
      keepdirs = false;
   end

   if keepdirs
      % Only remove '.' and '..'
      dirlist(strncmp({dirlist.name}, '.', 1) & strlength({dirlist.name})<3) = [];
   else
      dirlist(strncmp({dirlist.name}, '.', 1)) = [];
   end
end
