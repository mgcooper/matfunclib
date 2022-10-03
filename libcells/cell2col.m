function [ col_data ] = cell2col( celldata,colnum)
%cell2col converts data in cell format to column format i.e. matrix
%   Very limited function in beta. Basically just cycles through a cell
%   array of unlimited number of entries in one dimension and extracts the
%   data from the column of user choice, then puts all those columns into
%   a matrix. 

% % turns out it is this easy:
% testhorz = {[1,3,1,4],[1,2],[1, 2,2,2,2,4,4,5]};
% testvert = {[1;3;1;4],[1;2],[1;2;2;2;2;4;4;5]};
% test = testvert;
% if size(test{1},1) == 1
%    test = horzcat(test{:});
% elseif size(test{1},2) == 1
%    test = vertcat(test{:});
% end


col_data = [];
a = length(celldata);
for n = 1:a
    b = celldata{n}(:,colnum);
    c = length(b);
    col_data = [col_data;b];
end
col_data = reshape(col_data,c,a);
end

