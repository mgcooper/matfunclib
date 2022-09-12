function [ab,stats] = gmrfit(x,y)
    
    % geometric mean regression
    Sxx     = sum((x-mean(x)).^2);
    Syy     = sum((y-mean(y)).^2);
    Sxy     = sum((x-mean(x)).*(y-mean(y)));
    b       = sign(Sxy)*sqrt(Syy/Sxx);
    a       = mean(y)-b*mean(x);
    ab      = [a;b];
    stats   = []; 
    
end