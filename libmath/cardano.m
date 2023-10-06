function roots = cardano(a, b, c, d, lb, ub)
   %CARDANO Find roots of polynomial using Cardano method.

   if a == 0 % If a is zero, solve the quadratic equation
      roots = quadraticRoots(b, c, d, lb, ub);
      return;
   end

   % Coefficients for the depressed cubic equation
   p = (3*a*c - b^2) / (3*a^2);
   q = (2*b^3 - 9*a*b*c + 27*a^2*d) / (27*a^3);

   % Compute the discriminant
   delta = 4*p^3 + 27*q^2;

   if delta < 0 % Three real roots
      phi = acos(-q/2 * sqrt(-27/p^3));
      r = 2 * sqrt(-p/3);

      roots = zeros(3, 1);
      for k = 0:2
         x_k = r * cos((phi + 2*pi*k)/3) - b / (3*a);
         if x_k >= lb && x_k <= ub
            roots(k+1) = x_k;
         end
      end
   else % One real root
      u = nthroot(-q/2 + sqrt(delta)/2, 3);
      v = nthroot(-q/2 - sqrt(delta)/2, 3);
      x = u + v - b / (3*a);
      if x >= lb && x <= ub
         roots = x;
      else
         roots = [];
      end
   end
end

function roots = quadraticRoots(a, b, c, lb, ub)
   delta = b^2 - 4*a*c;
   if delta < 0
      roots = [];
      return;
   end

   x1 = (-b + sqrt(delta)) / (2*a);
   x2 = (-b - sqrt(delta)) / (2*a);
   roots = [x1, x2];
   roots = roots(roots >= lb & roots <= ub);
end
