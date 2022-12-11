function pathstr = list2path(list,index)
pathstr = fullfile(list(index).folder,list(index).name);