function [ab,stats] = rmafit(x,y,alpha)
%RMAFIT reduced major axis regression
% 
% [ab,stats] = rmafit(x,y,alpha)
% 
% york, 1966, eq. 3/4
% 
% equals mlefit if ab = mlefit(x,y,std(x),std(y))
% 
% See also: mlefit, olsfit, pcafit, gmrfit, yorkfit
    
    if nargin<3; alpha = 0.05; end
    
    N       = numel(x);
    
    xstd    = std(x); ystd = std(y); r = corr(x,y);
    xbar    = mean(x); ybar = mean(y);
    b       = ystd/xstd;
    a       = ybar-b*xbar;
    sigb    = b*sqrt((1-r*r)/N);
    siga    = ystd*sqrt((1-r)/N*(2+xbar*xbar*(1+r)/xstd/xstd));
    ab      = [a;b];
    
    % output
    stats.bL    = b-sigb;
    stats.bH    = b+sigb;
    stats.aL    = a-siga;
    stats.aH    = a+siga;
    stats.siga  = siga;
    stats.sigb  = sigb;
    
    % the solution here is identical to mlefit/yorkfit:
    %ab = mlefit(x,y,std(x),std(y))
    %ab = yorkfit(x,y,std(x),std(y))
    %ab = pcafit(x,y)

end