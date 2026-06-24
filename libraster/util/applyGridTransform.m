function V = applyGridTransform(V, transform)
   %APPLYGRIDTRANSFORM Replay prepareMapGrid's transform record on an array.
   %
   %  V = applyGridTransform(V, TRANSFORM) applies, in order, the transpose and
   %  the left-right / up-down flips recorded in TRANSFORM to V, so V lines up
   %  with the meshgrid / W-E / N-S grid that prepareMapGrid canonicalizes to.
   %  TRANSFORM is the 'transform' struct returned by prepareMapGrid (fields
   %  didTranspose, didFlipLR, didFlipUD). V may be a coordinate array (X or Y) or
   %  a value array, numeric or logical, 2-D or N-D (the first two dimensions are
   %  the grid, e.g. rows x cols x time). V may also be a CELL array of such
   %  arrays (a stack of layers stored as cells, as in exactremap's parseGridData),
   %  in which case the transform is applied to each element, not to the cell
   %  layout.
   %
   %  This is the primitive shared by callers that ALREADY hold a transform from
   %  their own prepareMapGrid call (e.g. gridxyz, rasterize, exactremap's
   %  parseGridData) and want to replay it on a value/coordinate array WITHOUT
   %  recomputing it. orientValueToGrid is the higher-level entry point: given
   %  V,X,Y it computes the transform from X,Y first (via prepareMapGrid), then
   %  calls this.
   %
   % See also: prepareMapGrid, orientValueToGrid, gridxyz, rasterize

   % Cell stack: transform each array, not the cell layout.
   if iscell(V)
      V = cellfun(@(v) applyGridTransform(v, transform), V, ...
         'UniformOutput', false);
      return
   end

   if transform.didTranspose
      V = permute(V, [2 1, 3:ndims(V)]);
   end
   if transform.didFlipLR
      V = fliplr(V);
   end
   if transform.didFlipUD
      V = flipud(V);
   end
end
