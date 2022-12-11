function dirlist = rmdotfolders(dirlist)
dirlist(strncmp({dirlist.name}, '.', 1)) = [];