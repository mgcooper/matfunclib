function plnum = plrand(N,alpha,xmin)
%PLRAND generate random power law distributed data
% 
%  plnum = plrand(N,alpha,xmin)
%
% See also plqtl, plcdf

% p(x)=(alpha-1)*x^(-alpha)
plnum = xmin.*(1-rand(N,1)).^(1/(-alpha+1));
end