function [X,Y] = fastgrid(X,Y)
%FASTGRID fast creation of 2d grid from vectors X,Y in meshgrid format
% 
%  [X,Y] = fastgrid(X,Y) works exactly like meshgrid(X,Y) for vectors X,Y
% 
% Matt Cooper, 19-Apr-2023, https://github.com/mgcooper
%
% See also meshgrid, ndgrid


% this converts X,Y to grid vecs that produce full grids oriented N-S, E-W
% X = reshape(sort(unique(X(:)),'ascend'),1,[]);
% Y = reshape(sort(unique(Y(:)),'descend'),[],1);

try
   X = repmat(full(X(:)).', numel(Y),1);
   Y = repmat(full(Y(:)),1, size(X,2));
catch
end