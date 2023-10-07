function [normData] = normdata(data, minout, maxout)
   %NORMDATA simple normalization of data from 0 - 1
   %
   %
   % See also:

   if minout == 0 && maxout == 1

      mind = min(data);
      maxd = max(data);
      normData = (data - mind)./(maxd - mind);

   elseif minout == -1 && maxout == 1

      factor = max([max(data) abs(min(data))]);
      normData = data/factor;
   end
end
