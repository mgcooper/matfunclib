
% opened this up after many months away and clearly not all terms are
% defined by at minimum ab is the initial guess, should be ols

% this is the equation from Mahon, 1996
S       = sum(W.*(Y-b.*X-a)).^2;
logL    = k - 1/2.*S;

% use the same approach as yorkfit2, just need fnc
fnc     = @(b,X) (wX.*wY)./(wY.*b^2+wX-2*b.*rxy.*sqrt(wX.*wY)); % Wi
objfnc  = @(AB) k-sum(fnc(AB(2),X).*(Y-AB(2)*X-AB(1)).^2)./2;
absol   = fminsearch(objfnc,ab);

% what I'm not sure about is how to get k, alos, we need to maximize objfnc
% here, I think that's why we would use neg-loglikelhood, because
% maximizing that is identicl to minimizing log-like