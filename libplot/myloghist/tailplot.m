function h = tailplot(data,varargin)

   % mgiht make this a wrapper around loghist with new option to fitdist
   % and make ccdf plot I added to loghist
   
   p = MipInputParser;
   p.FunctionName='tailplot';
   p.addRequired('data',@(x)isnumeric(x));
   p.addParameter('dist','gp',@(x)ischar(x))
%    p.addParameter('edges'
   

[F,x]    = ecdf(Q,'function','survivor');

figure; loglog(x,F);
plot(sort(Q),gpfitQ.cdf(sort(Q)));
set(gca,'YScale','log','XScale','log');