function [fname] = fnamefromlist(filelist,filepath,listindex)
%FNAMEFROMLIST construct filename from filelist and index
% 
%  [fname] = fnamefromlist(filelist,filepath,listindex)
% 
% Matt Cooper, 2022, https://github.com/mgcooper
% 
% See also: numfiles, list2path

fname = fullfile(filepath,filelist(listindex).name);