% one issue that will need to be dealt with is file type and row/col
% ordering. netcdf uses row ordering, matlab uses column ordering. For
% netcdf, i would porbably want to first check for presence of latitude
% longitude variable names, then lat lon, then x,y, then check the size of
% the data for some other variable, then compare to the size of x y, then
% assume the data needs to be permuted. I know the correct permutation for
% 3-d data i.e. x,y,time, but would need to confirm form 4-d data. 