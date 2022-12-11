function [fname] = fnamefromlist(filelist,filepath,listindex)
%FNAMEFROMLIST construct filename from filelist and index
fname = fullfile(filepath,filelist(listindex).name);