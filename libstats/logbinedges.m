function [edges,centers] = logbinedges(data)
   
   minval   =  fix(log10(min(data)));
   maxval   =  ceil(log10(max(data)));
   edges    =  logspace(minval,maxval);
   
   % note that the centers are probably not optimal, they should also be
   % logarithmic
   centers  =  edges(1:end-1) + diff(edges)./2;
end