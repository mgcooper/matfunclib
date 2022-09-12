function q = plqtl(xmin,alpha,p)
   
   % compute quantiles of a pareto distribution
   q = xmin.*(1-p).^(-1/(alpha-1));