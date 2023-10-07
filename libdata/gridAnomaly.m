function [pctDif, absDif, pctAnom] = gridAnomaly(normal, sample)
   %GRIDANOMALY Anomaly of gridded data
   %
   %   [pctDif, absDif, pctAnom] = gridAnomaly(normal, sample)
   %
   % See also: anomaly

   absDif = sample - normal;
   ratio = absDif./normal;
   pctDif = 100.*ratio;
   pctAnom = 100 + pctDif;

   % pctAnom = 100.*sample./normal;
end
