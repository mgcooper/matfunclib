function Column = cell2col(CellArray, ColumnNumber)
%cell2col convert cell array to column
%
% Very limited function that cycles through all elements of a cell array and
% extracts the designated column and puts all those columns into a matrix.
%
% See also

% % turns out it is this easy:
% testhorz = {[1,3,1,4],[1,2],[1, 2,2,2,2,4,4,5]};
% testvert = {[1;3;1;4],[1;2],[1;2;2;2;2;4;4;5]};
% test = testvert;
% if size(test{1},1) == 1
%    test = horzcat(test{:});
% elseif size(test{1},2) == 1
%    test = vertcat(test{:});
% end

Column = [];
a = length(CellArray);
for n = 1:a
   b = CellArray{n}(:,ColumnNumber);
   c = length(b);
   Column = [Column;b];
end
Column = reshape(Column,c,a);
