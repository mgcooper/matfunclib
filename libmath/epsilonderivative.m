function dfdx = epsilonderivative(f)

% found this neat trick to compute a derivative on stack overflow
% known as 'newton's difference quotient'

epsilon = 1e-10;

% apparently the "complex step method" is "orders of magnitude" more
% efficient than the newton's difference quotient
dfdx    = @(x) imag(f(x(:) + 1i*epsilon))./epsilon;

% newton's difference quotient:
% dfdx    = @(x) (f(x+epsilon) - f(x)) ./ epsilon;