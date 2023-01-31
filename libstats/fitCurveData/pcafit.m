function [ab,stats] = pcafit(x,y,alpha)
    
    if nargin<3; alpha = 0.05; end
    N       = numel(x);
    
    % pca (orthogonal regression)
    xbar    = mean(x); ybar = mean(y);
    Sxx     = sum((x-xbar).^2);
    Syy     = sum((y-ybar).^2);
    Sxy     = sum((x-xbar).*(y-ybar));
    b       = (Syy-Sxx+sqrt((Syy-Sxx)^2+4*Sxy*Sxy))/(2*Sxy); % york, 1966
    a       = ybar-b*xbar;
    ab      = [a;b];
    
    % std. errors (york, 1966) - need to decide if these should be used
    xstd    = std(x); ystd = std(y);
    r       = Sxy/sqrt(Sxx*Syy); rr = r*r;            % correlation
    sigb    = b/r*sqrt((1-rr)/N);
    siga    = sqrt(1/N*(ystd-xstd*b)^2+(1-r)*b*(2*xstd*ystd+(xbar*b*(1+r))/rr));
    
    % confidence intervals
    eig12   = eig(cov(x,y)); l1=min(eig12);l2=max(eig12);
    phihat  = atand(b);
    chistat = chi2inv(1-alpha/2,1);
    phiL    = asind(sqrt((chistat^2/((N-1)*(l1/l2+l2/l1-2)))));
    bL      = tand(phihat-phiL);
    bH      = tand(phihat+phiL);
    
%     % compare with standard method
%     [~,CI]  = tconf(b,sigb*sqrt(N),N,alpha);
%     1.96*sigb           % heuristic confidence interval
%     (CI(2)-CI(1))/2     % standard method with t-distribution adjustment
%     (bH-bL)/2           % method given above
    
    % hypothesis test
    r2      = (l1-l2)^2/(l1+l2)^2;
    h0      = 0;                                % reject null hypothesis
    if ((N-2)*r2/(1-r2))<=finv(1-alpha/2,1,N-1) % accept null (no relation)
        h0  = 1;
    end
        
    % output
    stats.bL    = bL;
    stats.bH    = bH;
    stats.h0    = h0;
    
    % another way to compute it (no speed difference)
%     YX      = [y x]; [coeff,score] = pca(YX);
%     meanYX  = mean(YX,1);
%     YXfit   = meanYX + score(:,1)*coeff(:,1)';
%     xfit    = YXfit(:,2);
%     yfit    = YXfit(:,1);
%     ab      = [ones(size(xfit)),xfit]\yfit; 
    
%   % also found this method in the documentation
%     [PCALoadings,PCAScores,PCAVar] = pca(X,'Economy',false);
%     betaPCR = regress(y-mean(y), PCAScores(:,1:2));
% https://www.mathworks.com/help/stats/partial-least-squares-regression-and-principal-components-regression.html

%     % the case where the ratio of error variance, c, is known:              
%     b       = (Syy-c*Sxx+sqrt((Syy-c*Sxx)^2+4*c*Sxy*Sxy))/(2*Sxy);
%     a       = ybar-b*xbar;
%     ab      = [a;b];
    
    
    % this is Leng 2007's version, equivalent york's but a bit longer:
    %b       = (Syy-Sxx+sqrt((Sxx+Syy)^2-4*(Sxx*Syy-Sxy*Sxy)))/2/Sxy;
    %b       = (Syy-c*Sxx+sqrt((Syy+c*Sxx)^2-4*c*(Sxx*Syy-Sxy*Sxy)))/2/Sxy;
    % the second one i added c to demonstrate
end