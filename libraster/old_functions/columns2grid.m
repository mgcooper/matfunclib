function [ griddedData ] = columns2grid( columnData,numrows,numcols )
%COL2GRID takes multi-column timeseries data and puts them in gridded
%format
%   This function is very limited by assumptions please note: First the
%   time dimension must be in the row dimension and the columns each
%   represent a different point i.e. gridded location. Also, this function
%   assumes that the first column is the lower right point and the last
%   column is the upper left point. This is because if you have a listing
%   of geographic coordinates, they will be numbered this way i.e.
%   longitude increases from right to left and latitude from bottom to top.

% july 2022, started to fix this up, not even sure what numrows and numcols
% represent, are they just size(columnData)? 
% griddedData = nan(

for m = 1:length(columnData)
    for n = 1:numrows
        starti = numcols*n - (numcols-1);
        endi = numcols*n;
        
        temp = columnData(m,starti:endi);
        griddedData(n,:,m) = temp;
        
    end 
end

for n = 1:length(griddedData)
    temp = griddedData(:,:,n);
    temp = rot90(temp,2);
    griddedData(:,:,n) = temp;
end

end
