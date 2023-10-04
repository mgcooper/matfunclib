function [X,Y] = gridvec(X,Y,varargin)
   %GRIDVEC Convert coordinate-pairs X,Y to grid vectors.
   %
   %  [X,Y] = GRIDVEC([X,Y]) converts coordinate-pairs X,Y to grid vectors
   %
   % Example
   %
   %
   % Matt Cooper, 19-Apr-2023, https://github.com/mgcooper
   %
   % See also: fullgrid, isfullgrid, xgridvec, ygridvec, meshgrid, fastgrid

   % input checks
   narginchk(2,3)

   X = reshape(sort(unique(X(:)),'ascend'),1,[]);
   Y = reshape(sort(unique(Y(:)),'descend'),[],1);
end
