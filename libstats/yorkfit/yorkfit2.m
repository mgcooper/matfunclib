function [ab,siga,sigb] = yorkfit2(X,Y,wX,wY,rxy)

    ab      = pcafit(X,Y);
    fnc     = @(b,X) (wX.*wY)./(wY.*b^2+wX-2*b.*rxy.*sqrt(wX.*wY)); % W
    objfnc  = @(AB) sum(fnc(AB(2),X).*(Y-AB(2)*X-AB(1)).^2);
    absol   = fminsearch(objfnc,ab);
    b       = absol(2);
    W       = fnc(b,X);
    Xbar    = wmean(X,W);       % sum(W.*X)/sumW;
    Ybar    = wmean(Y,W);       % sum(W.*Y)/sumW;
    a       = Ybar-b*Xbar;
    xi      = X+W.*(a+b.*X-Y).*(rxy.*sqrt(wX.*wY)-b.*wY)./(wX.*wY); %xadj
    xbar    = wmean(xi,W);    % sum(W.*xadj)/sumW;
    sigb    = sqrt(1/sum(W.*(xi-xbar).^2));
    siga    = sqrt(1/sum(W)+xbar.^2.*sigb.^2);
    ab      = [a;b];
    
    % this is siga and sigb with eq. 1a/1b
    %siga   = sqrt(sum(W.*xi.*xi)/(sum(W.*xi.*xi)*sum(W)-(sum(W.*xi))^2));
    %sigb   = sqrt(sum(W)/(sum(W.*xi.*xi)*sum(W)-(sum(W.*xi))^2));
    %yi     = y+W.*(a+b.*x-y).*(wX-b.*rxy.*ai)./(wX.*wY);
end
    