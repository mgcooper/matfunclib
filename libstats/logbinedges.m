function [edges, centers] = logbinedges(data, N, logbase)
   %LOGBINEDGES Compute logarithmically spaced bin edges.
   %
   %  [EDGES, CENTERS] = LOGBINEDGES(DATA) returns log10-spaced bin edges and
   %  geometric bin centers using the default automatic bin count from
   %  BINEDGES.
   %
   %  [EDGES, CENTERS] = LOGBINEDGES(DATA, N) uses N bins.
   %
   %  [EDGES, CENTERS] = LOGBINEDGES(DATA, N, LOGBASE) uses either 'log10' or
   %  'ln' spacing.
   %
   %  This wrapper is retained for compatibility. New code should prefer
   %  BINEDGES(DATA, 'NumBins', N, 'Scale', LOGBASE).
   %
   %  See also binedges

   if nargin < 2 || isempty(N)
      N = [];
   end
   if nargin < 3 || isempty(logbase)
      logbase = 'log10';
   end

   if isempty(N)
      [edges, ~, centers] = binedges(data, 'Scale', logbase);
   else
      [edges, ~, centers] = binedges(data, 'Scale', logbase, 'NumBins', N);
   end
end
