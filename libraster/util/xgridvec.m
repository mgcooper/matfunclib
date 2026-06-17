function X = xgridvec(X)
   %XGRIDVEC Convert coordinates in X to grid vector.
   %
   %  X = XGRIDVEC(X) converts coordinates in X to grid vector
   %
   %  X is returned ASCENDING (W-E). Its sibling ygridvec returns Y DESCENDING
   %  (N-S), the north-up "image" convention -- see ygridvec for the planar caveat.
   %
   % See also: gridvec, ygridvec

   % input checks
   narginchk(1,1)

   X = reshape(sort(unique(X(:)),'ascend'),1,[]);
end
