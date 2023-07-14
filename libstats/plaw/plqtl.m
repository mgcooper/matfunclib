function q = plqtl(xmin,alpha,p)
%PLQTL compute quantiles of a pareto distribution
% 
% q = plqtl(xmin,alpha,p)
% 
% See also plrand, plcdf

q = xmin.*(1-p).^(-1/(alpha-1));