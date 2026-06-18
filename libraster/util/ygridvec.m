function Y = ygridvec(Y)
   %YGRIDVEC Convert coordinates in Y to grid vector.
   %
   %  Y = YGRIDVEC(Y) converts coordinates in Y to grid vector
   %
   %  Y is returned DESCENDING (N-S) -- the north-up "image" convention shared by
   %  gridvec, ygridvec, fullgrid, and yfullgrid. Correct for geographic rasters;
   %  for planar grids whose Y (northing) is conventionally ascending (S-N), flip
   %  Y yourself if S-N order is required.
   %
   % See also: gridvec, xgridvec, fullgrid

   % input checks
   narginchk(1,1)

   Y = reshape(sort(unique(Y(:)),'descend'),[],1);
end
