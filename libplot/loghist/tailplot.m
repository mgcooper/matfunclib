function h = tailplot(x, varargin)
   %TAILPLOT Plot the tail of a distribution
   %
   %
   %
   % See also: loghist

   % mgiht make this a wrapper around loghist with new option to fitdist
   % and make ccdf plot I added to loghist

   parser = inputParser();
   parser.FunctionName = mfilename;
   parser.addRequired('x', @(x)isnumeric(x));
   parser.addParameter('dist', 'gp', @(x)ischar(x))
   parser.parse(x, varargin{:})
   dist = parser.Results.dist;

   % Compute the complementary cumulative distribution function
   [F, X] = ecdf(x, 'function', 'survivor');

   % Create the figure
   figure; 
   loglog(X, F);
   plot(sort(x), dist.cdf(sort(x)));
   set(gca,'YScale','log','XScale','log');
end
