% NOTE: may need to think harder about this, possibly set one tolerance for
% geographic and another for projected, or round to zero and get ndigits to
% discern a reasonable tolerance e.g. lat lon could have non-constant grid
% spacing that differs by 1/1000 of a degree, whereas it would be
% unreasonable for a utm grid in units of meters to differ by 1 mm
% confirm X and Y have constant grid spacing (rounding error tol = 10^-3)
assert(all(roundn(diff(X(1,:),2),-3)==0), ...
                'Input argument 1, X, must have uniform grid spacing');
assert(all(roundn(diff(Y(:,1),2),-3)==0), ...
                'Input argument 2, Y, must have uniform grid spacing');