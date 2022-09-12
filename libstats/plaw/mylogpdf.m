% log pdf function taking log(alpha)
function logf = mylogpdf(x,logalpha,xmin)
alpha = exp(logalpha);

if nargin<3
    xmin = min(x);
end
 
% mgc: f is correct, but commented out to use the log version
% f = ((alpha-1)/xmin) * (x/xmin).^-alpha;
logf = log(alpha-1) - log(xmin) - alpha*log(x/xmin);
logf(x<xmin) = -Inf;

% mgc: if we start with p(x) = x^-alpha, then this is correct:
% f = (alpha-1)*xmin.^(alpha-1) * x^-alpha;
% logf = log(alpha-1) 

end