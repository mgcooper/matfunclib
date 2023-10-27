function q = plqtl(xmin, alpha, p)
   %PLQTL Compute quantiles of a Pareto distribution
   %
   %  Q = PLQTL(XMIN, ALPHA, P)
   %
   % See also: plrand, plcdf

   q = xmin .* (1 - p) .^ (-1 / (alpha - 1));
end
