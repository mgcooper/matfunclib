function dfdx = epsilonderivative(f)
   %EPSILONDERIVATIVE Compute df/dx using the epsilon method.
   %
   %  dfdx = epsilonderivative(f) computes df/dx, the derivative of function f
   %  wrt x using the epsilon method aka newton's difference quotient.
   %
   % Matt Cooper, 2021, https://github.com/mgcooper
   %
   % See also: derivative, movingslope, sgolay

   epsilon = 1e-10;

   % apparently the "complex step method" is "orders of magnitude" more
   % efficient than the newton's difference quotient
   dfdx = @(x) imag(f(x(:) + 1i*epsilon))./epsilon;

   % newton's difference quotient:
   % dfdx = @(x) (f(x+epsilon) - f(x)) ./ epsilon;
end
