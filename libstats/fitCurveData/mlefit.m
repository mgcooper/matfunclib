function [ab,stats] = mlefit(x,y,sigx,sigy)
%MLEFIT maximum likelihood estimation for linear regression
% 
% [ab,stats] = mlefit(x,y,sigx,sigy)
% 
% See also: olsfit, pcafit, rmafit, gmafit, yorkfit

    % linear regression with known but uncorrelated error variance
    % (maximum likelihood estimation)
    
    [x,y] = prepareCurveData(x,y);
    
    if nargin == 2
        sigx = std(x,'omitnan');
        sigy = std(y,'omitnan');
    end 
    
    c       = sigy.^2./sigx.^2;     % mgc used c instead of lambda
    Sxx     = sum((x-mean(x)).^2);
    Syy     = sum((y-mean(y)).^2);
    Sxy     = sum((x-mean(x)).*(y-mean(y)));
    b       = (Syy-c.*Sxx+sqrt((Syy-c.*Sxx).^2+4.*c.*Sxy.*Sxy))/2/Sxy;
    a       = mean(y)-b*mean(x);
    ab      = [a;b];
    stats   = [];
    
    % if the ratio of error variance, c, is constant, only dif is no .*:
    %b       = (Syy-c*Sxx+sqrt((Syy-c*Sxx)^2+4*c*Sxy*Sxy))/(2*Sxy);
    %a       = ybar-b*xbar;
    %ab      = [a;b];
    
end