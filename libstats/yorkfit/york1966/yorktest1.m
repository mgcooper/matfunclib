function [ab,siga,sigb,c] = yorktest1(x,y,wX,wY,rxy,option)
    
    if nargin==5
        option = 1;
    end
    
    N       = numel(x);
    %ab      = olsfit(x,y);
    ab      = pcafit(x,y);
    btmp    = ab(2);
    U       = x-mean(x);
    V       = y-mean(y);
    ai      = sqrt(wX.*wY); 
    
    % option 1 - no loop necessary if rxy = 0
    if option == 1
        fnc = @(b) b^3.*sum(((wX.*wY./(b^2.*wY+wX))).^2.*U.^2./wX)     +   ...
                -2.*b^2.*sum(((wX.*wY./(b^2.*wY+wX))).^2.*U.*V./wX)   +   ...
                -b.*(sum(((wX.*wY./(b^2.*wY+wX))).*U.^2) -                 ...
                sum(((wX.*wY./(b^2.*wY+wX))).^2.*V.^2./wX))            +   ...
                sum(((wX.*wY./(b^2.*wY+wX))).*U.*V);
        b   = fzero(fnc,btmp);
        a   = mean(y)-b*mean(x);
        ab  = [a;b];
        
        W    = (wX.*wY)./(b^2.*wY+wX);
        siga = sqrt(sum(W.*x)/(sum(W.*x.*x)*sum(W)-(sum(W.*x))^2));
        sigb = sqrt(sum(W)/(sum(W.*x.*x)*sum(W)-(sum(W.*x))^2));
        return;
    end
    
    
    if option == 2
        abtmp   = pcafit(x,y);
        fnc     = @(b,x) (wX.*wY)./(wY.*b^2+wX-2*b.*rxy.*ai); % Wi
        objfnc  = @(AB) sum(fnc(AB(2),x).*(y-AB(2)*x-AB(1)).^2);
        absol   = fminsearch(objfnc,abtmp);
        b       = absol(2);
        
        W       = (wX.*wY)./(wY.*b^2+wX-2*b.*rxy.*ai);
        Xbar    = sum(W.*x)/sum(W); 
        Ybar    = sum(W.*y)/sum(W);
        a       = Ybar-b*Xbar;
        ab      = [a;b];
        xi      = x+W.*(a+b.*x-y).*(rxy.*ai-b.*wY)./(wX.*wY); % xadj
        Wxi     = W.*xi;
        %yi     = y+W.*(a+b.*x-y).*(wX-b.*rxy.*ai)./(wX.*wY);
        siga    = sqrt(sum(Wxi.*xi)/(sum(Wxi.*xi)*sum(W)-(sum(Wxi))^2));
        sigb    = sqrt(sum(W)/(sum(Wxi.*xi)*sum(W)-(sum(Wxi))^2));
    return;
    end
    
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    tol     = 1e-15;
    err     = 10*tol;
    while err>tol
        
        % note - these are applicable to non-correlated errors
        W       = (wX.*wY)./(btmp^2.*wY+wX);
        WWU     = W.*W.*U./wX;
        WWV     = W.*W.*V./wX;

        switch option
            % option 2: "General Solution" section
            case 3
                alpha   = (2*sum(WWU.*V))/(3*sum(WWU.*U));
                beta    = (sum(WWV.*V)-sum(W.*U.*U))/(3*sum(WWU.*U));
                gamma   = -sum(W.*U.*V)/sum(WWU.*U);
                c1      = 1;
                c2      = -3.*alpha;
                c3      = 3.*beta;
                c4      = -gamma;
                fnc     = @(b) c1.*b^3 + c2.*b^2 + c3.*b + c4;
                
            % option 3: Eq. 20, with initial guess on b
            case 4
                c1  = sum(W.*W.*U.*U./wX);
                c2  = -2*sum(W.*W.*U.*V./wX);
                c3  = -(sum(W.*U.*U)-sum(W.*W.*V.*V./wX));
                c4  = sum(W.*U.*V);
                fnc = @(b) c1.*b^3 + c2.*b^2 + c3.*b + c4;
                
            case 5
                % option 4: Eq 20, fully explicit
                c1  = sum(((wX.*wY./(btmp^2.*wY+wX))).^2.*U.^2./wX);
                c2  = -2.*sum(((wX.*wY./(btmp^2.*wY+wX))).^2.*U.*V./wX);
                c3  = -(sum(((wX.*wY./(btmp^2.*wY+wX))).*U.^2) -              ...
                        sum(((wX.*wY./(btmp^2.*wY+wX))).^2.*V.^2./wX));
                c4  = sum(((wX.*wY./(btmp^2.*wY+wX))).*U.*V);
                fnc = @(b) c1.*b^3 + c2.*b^2 + c3.*b + c4;
                
            case 6 % correlated error (Eq. 6, 1968) (Wi = Zi)
                W       = (wX.*wY)./(btmp^2.*wY+wX-2*btmp.*rxy.*ai);
                Xbar    = sum(W.*x)/sum(W); Ybar = sum(W.*y)/sum(W);
                U       = x-Xbar; V = y-Ybar;
                fnc     = @(b) b*sum(W.^2.*U.*(U./wY+b*V./wX-b*rxy.*U./ai)) ...
                        - sum(W.^2.*V.*(U./wY+b.*V./wX-rxy.*V./ai));
                    
            case 7  % correlated error (Eq. 3, 1968)
                W       = (wX.*wY)./(btmp^2.*wY+wX-2*btmp.*rxy.*ai);
                Xbar    = sum(W.*x)/sum(W); Ybar = sum(W.*y)/sum(W);
                U       = x-Xbar; V = y-Ybar;
                W2      = W.*W; U2 = U.*U; V2 = V.*V; UV = U.*V;
                c1      = sum(W2.*U2./wX);
                c2      = -(2*sum(W2.*UV./wX) + sum(W2.*rxy.*U2./ai));
                c3      = -(sum(W.*U2)-2*sum(W2.*rxy.*UV./ai)-sum(W2.*V2./wX));
                c4      = sum(W.*UV) - sum(W2.*rxy.*V2./ai);
                fnc     = @(b) c1.*b^3 + c2.*b^2 + c3.*b + c4;

% abandoned this, not needed, i did it b/c williamson is cited in mahon but
% can't find the pdf and reed i think implementes williamson
%             case 8 % Reed, 1992, Eq. 19
%                 W       = (wX.*wY)./(btmp^2.*wY+wX-2*btmp.*rxy.*ai);
%                 c1      = sum(W.*W.*U.*V./wX);
%                 c2      = sum(W.*W.*(U.*U./wY-V.*V./wX));
%                 c3      = -sum(W.*W.*U.*V./wY);
        end
        
        % solve it
        bsoln   = fzero(fnc,btmp);
        err     = abs(bsoln-btmp);
        btmp    = bsoln;
        
        %bsoln  = real(roots([c1 c2 c3 c4]));
        %err    = abs(bsoln(2)-btmp);
        %btmp   = bsoln(2); 
        
    end
    % adjusted x,y values
    b       = btmp;
    W       = (wX.*wY)./(wY.*b^2+wX-2*b.*rxy.*ai);
    Xbar    = sum(W.*x)/sum(W); 
    Ybar    = sum(W.*y)/sum(W);
    a       = Ybar-b*Xbar;
    c       = -a/b; % x-intercept
    ab      = [a;b];
    xi    = x+W.*(a+b.*x-y).*(rxy.*ai-b.*wY)./(wX.*wY);
    %yadj   = y+W.*(a+b.*x-y).*(wX-b.*rxy.*ai)./(wX.*wY);
    siga    = sqrt(sum(W.*xi.*xi)/(sum(W.*xi.*xi)*sum(W)-(sum(W.*xi))^2));
    sigb    = sqrt(sum(W)/(sum(W.*xi.*xi)*sum(W)-(sum(W.*xi))^2));
    
    % note, concise equations for siga,sigb are in york 2004, 13c/d, and in
    % yorkfit.m, also xi/yi (xadj/yadj)
end

% abtmp   = pcafit(x,y);
% fnc     = @(AB) sum(((wX.*wY)./(AB(2)^2.*wY+wX-2*AB(2).*rxy.*ai)).*(y-AB(2)*x-AB(1)).^2);
% abtest  = fminsearch(fnc,abtmp);