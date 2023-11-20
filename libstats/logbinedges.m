function [edges, centers] = logbinedges(data, N)
   %LOGBINEDGES Compute bin edges for logged data
   %
   %
   % See also: binedges

   if nargin < 2
      N = ceil(sqrt(numel(data)));
   end
   
   minval = fix(log10(min(data)));
   maxval = ceil(log10(max(data)));
   edges = logspace(minval, maxval, N);

   % note that the centers should also be logarithmic
   centers = edges(1:end-1) + diff(edges)./2;
end
