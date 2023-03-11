function dirlist = rmdotfolders(dirlist)
dirlist(strncmp({dirlist.name}, '.', 1)) = [];

% NOTE: to only remove . and .. for example to keep .github, use this:
% dirlist(strncmp({dirlist.name}, '.', 1) & strlength({dirlist.name})<3) = [];