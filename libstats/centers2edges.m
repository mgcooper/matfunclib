function edges = centers2edges(centers)
   %CENTERS2EDGES Convert bin centers to bin edges.
   %
   % This function converts bin centers to bin edges. It works for both
   % uniform and non-uniform bin widths.
   %
   % Inputs:
   %   centers - Bin centers (linear or log scales).
   %
   % Outputs:
   %   edges   - Bin edges corresponding to the centers.
   %
   % Notes:
   %   The 'hist' function accepts bin centers, whereas the 'histogram' function
   %   requires bin edges. This function helps convert between these formats.
   %   For example, to update code to use histogram, you might need to convert
   %   bin centers to bin edges to reproduce results achieved with hist.
   %
   % See also: hist, histogram, histcounts, binedges

   % To convert the bin centers into bin edges, calculate the midpoint between
   % consecutive values in centers. This method reproduces the results of hist
   % for both uniform and nonuniform bin widths.

   % Compute the difference between consecutive centers.
   d = diff(centers)/2;

   % Compute the edges as the midpoints between centers.
   edges = [centers(1)-d(1), centers(1:end-1)+d, centers(end)+d(end)];

   % The hist function includes values falling on the right edge of each bin
   % (the first bin includes both edges), whereas histogram includes values that
   % fall on the left edge of each bin (and the last bin includes both edges).
   % Shift the bin edges slightly to obtain the same bin counts as hist.
   edges(2:end) = edges(2:end) + eps(edges(2:end));
end
