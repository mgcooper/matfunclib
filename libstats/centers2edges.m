function edges = centers2edges(centers)
   %UNTITLED9 Summary of this function goes here
   %   Detailed explanation goes here

   %    The hist function accepts bin centers, whereas the histogram function
   %    accepts bin edges. To update code to use histogram, you might need to
   %    convert bin centers to bin edges to reproduce results achieved with
   %    hist.

   % To convert the bin centers into bin edges, calculate the midpoint between
   % consecutive values in centers. This method reproduces the results of hist
   % for both uniform and nonuniform bin widths.

   d = diff(centers)/2;
   edges = [centers(1)-d(1), centers(1:end-1)+d, centers(end)+d(end)];

   % The hist function includes values falling on the right edge of each bin
   % (the first bin includes both edges), whereas histogram includes values that
   % fall on the left edge of each bin (and the last bin includes both edges).
   % Shift the bin edges slightly to obtain the same bin counts as hist.
   edges(2:end) = edges(2:end)+eps(edges(2:end));
end