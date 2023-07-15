function [ab,stats] = gmrfit(x,y)
%GMRFIT geometric mean regression
% 
% [ab,stats] = gmrfit(x,y)
% 
% See also: mlefit, olsfit, pcafit, rmafit, yorkfit
    
    Sxx     = sum((x-mean(x)).^2);
    Syy     = sum((y-mean(y)).^2);
    Sxy     = sum((x-mean(x)).*(y-mean(y)));
    b       = sign(Sxy)*sqrt(Syy/Sxx);
    a       = mean(y)-b*mean(x);
    ab      = [a;b];
    stats   = []; 
    
end