function alphahat = mlefitalpha(x)

   % didn't finish this, i think i may have started it when i started on
   % teh Pareto distributin class

   % should replace with logspace probably
   xmin = linspace(min(x),max(x),100);

   for n = 1:numel(xmin)
      xn = x(x>xmin);
      N  = numel(xn);
      alphahat(n) = N./(sum(log(xn./xmin)));
   end
end
