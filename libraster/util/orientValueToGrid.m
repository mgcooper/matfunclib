function [V, ambiguous] = orientValueToGrid(V, X, Y)
   %ORIENTVALUETOGRID Orient a value array V to libraster's meshgrid convention.
   %
   %  [V, ambiguous] = orientValueToGrid(V, X, Y) returns V transposed/flipped so
   %  its first two dimensions align with the grid prepareMapGrid(X,Y) produces
   %  (meshgrid, size [numel(Y) x numel(X)], oriented W-E / N-S). Use it when a
   %  caller holds a value array V whose orientation must match libraster's grid
   %  convention -- e.g. a climate field stored on an ndgrid. ambiguous is true
   %  only when the orientation CANNOT be determined, in which case V is returned
   %  unchanged and the caller should warn the user.
   %
   %  Two modes:
   %   - X, Y are 2-D arrays: the orientation is read from the arrays. V is
   %     transposed (ndgrid->meshgrid) and flipped (W-E / N-S) to match
   %     prepareMapGrid's transform; ambiguous follows the array detector (a
   %     ~45-degree rotation, where the row/column gradients tie).
   %   - X, Y are 1-D vectors (lengths nx, ny): two vectors do NOT encode ndgrid vs
   %     meshgrid -- meshgrid(x,y) and ndgrid(x,y) consume the same x,y -- so the
   %     orientation lives only in size(V). [ny x nx] is already meshgrid (no-op);
   %     [nx x ny] is ndgrid (transpose). A SQUARE grid (nx == ny) is
   %     undeterminable from V's shape alone -> V is left unchanged and
   %     ambiguous = true so the caller can warn.
   %
   %  V may be numeric or logical and 2-D or N-D (the first two dimensions are the
   %  grid, e.g. cells x cells x time); empty V passes through unchanged.
   %
   % Example
   %   x = 1:4; y = 1:6;             % non-square so shape disambiguates
   %   Vnd = (1:4).' + 10*(1:6);     % an ndgrid-oriented [nx x ny] field
   %   Vmesh = orientValueToGrid(Vnd, x, y);   % -> [ny x nx], meshgrid
   %
   % See also: prepareMapGrid, gridIsNdgrid, fullgrid

   validateattributes(V, {'numeric', 'logical'}, {}, mfilename, 'V', 1);

   ambiguous = false;
   if isempty(V)
      return
   end

   if isvector(X) && isvector(Y)
      % Vector axes: orientation is only in size(V). libraster expands vector axes
      % to meshgrid, size [numel(Y) x numel(X)].
      nx = numel(X);
      ny = numel(Y);
      if nx == ny
         ambiguous = true;                      % square -> undeterminable
      elseif size(V, 1) == nx && size(V, 2) == ny
         V = permute(V, [2 1, 3:ndims(V)]);     % [nx x ny] ndgrid -> transpose
      end
      % else size(V) == [ny x nx] -> already meshgrid -> no-op
      return
   end

   % 2-D array axes: replay prepareMapGrid's transform record on V (transpose,
   % then flips), so V matches the meshgrid / W-E / N-S output it canonicalizes to.
   [~, ~, ~, ~, ~, ~, ~, ~, ~, ~, tform] = prepareMapGrid(X, Y, 'fullgrids');
   ambiguous = tform.orientationAmbiguous;
   if tform.didTranspose
      V = permute(V, [2 1, 3:ndims(V)]);
   end
   if tform.didFlipLR
      V = fliplr(V);
   end
   if tform.didFlipUD
      V = flipud(V);
   end
end
