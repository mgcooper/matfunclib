function alpha = plawfit(x, xmin)
   %PLAWFIT fit power law using mle with log pdf function taking log(alpha)
   %
   %
   %
   % See also

   % Not functional

   if nargin<2
      xmin = min(x);
   end

   % not sure how to pass xmin into mylogpdf
   p = mle(x,'logpdf',@pllogpdf,'start',1);
   alpha = exp(p);
end
