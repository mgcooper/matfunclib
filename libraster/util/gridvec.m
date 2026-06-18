function [X,Y] = gridvec(X,Y,varargin)
   %GRIDVEC Convert coordinate-pairs X,Y to grid vectors.
   %
   %  [X,Y] = GRIDVEC(X,Y) converts coordinate-pairs X,Y to grid vectors
   %
   % Example
   %
   %
   % Matt Cooper, 19-Apr-2023, https://github.com/mgcooper
   %
   % Note on orientation: X is returned ascending (W-E) and Y DESCENDING (N-S),
   % i.e. the north-up "image" convention shared by gridvec, xgridvec, ygridvec,
   % and fullgrid. This is correct for geographic rasters but reverses the Y axis
   % of planar/projected grids whose Y (northing) is conventionally ascending
   % (S-N). Callers that need S-N planar order must flip Y themselves.
   %
   % See also: fullgrid, isfullgrid, xgridvec, ygridvec, meshgrid, fastgrid

   % input checks
   narginchk(2,3)

   % Force the image convention: X ascending (W-E), Y descending (N-S).
   X = reshape(sort(unique(X(:)),'ascend'),1,[]);
   Y = reshape(sort(unique(Y(:)),'descend'),[],1);
end
