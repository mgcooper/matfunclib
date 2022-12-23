function [fname] = fnamefromlist(filelist,filepath,listindex)
%FNAMEFROMLIST construct filename from filelist and index
% 
%  [fname] = fnamefromlist(filelist,filepath,listindex)
% 
% See also

fname = fullfile(filepath,filelist(listindex).name);