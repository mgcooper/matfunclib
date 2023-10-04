function Y = ygridvec(Y)
   %YGRIDVEC Convert coordinates in Y to grid vector.
   %
   %  Y = YGRIDVEC(Y) converts coordinates in Y to grid vector
   %
   % See also: gridvec, xgridvec, fullgrid

   % input checks
   narginchk(1,1)

   Y = reshape(sort(unique(Y(:)),'descend'),[],1);
end
