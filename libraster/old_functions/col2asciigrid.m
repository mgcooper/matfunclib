function [ griddedData ] = col2grid( columnData,headerInfo )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

ncols = headerInfo(1,1);
nrows = headerInfo(1,2);
xll = headerInfo(1,3);
yll = headerInfo(1,4);
spacing = headerInfo(1,5);
noData = headerInfo(1,6);

%% checks
if numel(columnData) ~= ncols*nrows
    error('Mismatch between grid size and column data');
end



end

