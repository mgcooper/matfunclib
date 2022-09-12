function ab = yorktest2(x,y,wx,wy)
    N       = numel(x);
    M       = [ones(N,1),x]\y;
    btmp    = M(2);
    Ui      = x-mean(x);
    Vi      = y-mean(y);
    tol     = 1e-15;
    err     = 10*tol;
    while err>tol
        Wi      = (wx.*wy)/(btmp^2.*wy+wx);
        d1      = sum(Wi.*Wi.*Ui.*Ui./wx);
        alpha   = (2*sum(Wi.*Wi.*Ui.*Vi./wx))/(3*d1);
        beta    = (sum(Wi.*Wi.*Vi.*Vi./wx)-sum(Wi.*Ui.*Ui))/(3*d1);
        c2      = -3*alpha;
        c3      = 3*beta;
        c4      = sum(Wi.*Ui.*Vi)/d1;
        bsoln   = real(roots([1 c2 c3 c4])); % c1*b^3 + c2*b^2 + c3*b + gamma = 0;
        err     = abs(bsoln(2)-btmp);
        btmp    = bsoln(2); 
    end
    b   = btmp;
    a   = mean(x)-b*mean(y);
    ab  = [a;b];
end