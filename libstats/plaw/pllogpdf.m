function logf = pllogpdf(x,logalpha,xmin)
%PLLOGPDF log pdf function using log(alpha) assuming power law distribution
% 
% 
% See also plcdf, plrand

alpha = exp(logalpha);

if nargin<3
    xmin = min(x);
end
 
% Note: f is correct, but commented out to use the log version
% f = ((alpha-1)/xmin) * (x/xmin).^-alpha;
logf = log(alpha-1) - log(xmin) - alpha*log(x/xmin);
logf(x<xmin) = -Inf;

% Note: if we use p(x) = x^-alpha, then this is correct:
% f = (alpha-1)*xmin.^(alpha-1) * x^-alpha;
% logf = log(alpha-1) 
end