function pathstr = list2path(list,index)
%LIST2PATH convert directory list returned by dir to full path filename list
% 
%  pathstr = list2path(list) returns a full path filename list for all files in
%  list 
% 
%  pathstr = list2path(list,index) returns a full path filename list for the
%  file list(index).name
% 

if nargin == 1
   pathstr = fullfile({list.folder},{list.name});
else
   pathstr = fullfile(list(index).folder,list(index).name);
end