function [edges,binwidth,centers] = binedges(x, method, varargin)
   %BINEDGES Compute bin edges for histogram using one of 8 methods
   %
   %
   % NOTE: this is not tested and only a few methods are fully implemented
   %
   % see: https://en.wikipedia.org/wiki/Histogram#Number_of_bins_and_width
   %
   % in general: numbins = ceil((max(x) - min(x)) / binwidth)
   % but the methods used to get binwidth or numbins depend on the
   % distribution, and general rules don't apply to all distributions
   %
   % See also

   N = numel(x);

   switch method

      case 'squareroot'
         % square root method:
         numbins  = ceil(sqrt(N));
         binwidth = (max(x)-min(x))/numbins;

      case 'sturges'
         % Sturges' formula (assumes approximately normal dist, and may not
         % perform well for N<30)
         numbins  = ceil(log2(N) + 1);

      case 'rice'
         % Rice rule
         numbins  = ceil(2*N^(1/3));

      case 'doane'
         % Doane's formula (modified Sturges rule for non-normal data)
         g1       = skewness(x);
         sigg1    = sqrt((6*(N-2))/((N+1)*(N+3)));
         numbins  = ceil(1 + log2(N) + log2(1 + g1/sigg1));

      case 'scott'
         % Scott's rule optimal for normal
         binwidth = 3.49*std(x)*N^(-1/3);
         numbins  = ceil((max(x)-min(x))/binwidth);

      case 'freedman-diaconis'
         % Freedman-Diaconis rule:
         IQRange  = iqr(x);
         binwidth = 2*IQRange*N^(-1/3);
         numbins  = ceil((max(x)-min(x))/binwidth);

      case 'equiprobable'
         % equiprobable
         numbins  = ceil(2*N^(2/5));

      case 'shimazaki-shinimoto'
         % shimazaki shinimoto
         % complicated, numerical iteration i think
         numbins  = sshist(x);
         binwidth = (max(x)-min(x))/numbins;
   end

   edges = linspace(min(x),max(x),numbins);
end
