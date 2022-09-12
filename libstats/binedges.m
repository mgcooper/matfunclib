function [edges,centers,binwidth] = binedges(x,varargin)
   
   % see: 
   % https://en.wikipedia.org/wiki/Histogram#Number_of_bins_and_width
   
   % in general: numbins = ceil((max(x) - min(x)) / binwidth)
   % but the methods used to get binwidth or numbins depend on the
   % distribution, and general rules don't apply to all distributions
   
   N        = numel(x);
   
   % square root method:
   numbins  = ceil(sqrt(N));
   binwidth = (max(x)-min(x))/numbins;

   % Sturges' formula (assumes approximately normal dist, and may not
   % perform well for N<30)
   numbins  = ceil(log2(N) + 1);
   
   % Rice rule
   numbins  = ceil(2*N^(1/3))
   
   % Doane's formula (modified Sturges rule for non-normal data)
   g1       = skewness(x);
   sigg1    = sqrt((6*(N-2))/((N+1)*(N+3)));
   numbins  = ceil(1 + log2(N) + log2(1 + g1/sigg1));
   
   % Scott's rule optimal for normal
   binwidth = 3.49*std(x)*N^(-1/3);
   numbins  = ceil((max(x)-min(x))/binwidth);
   
   % Freedman-Diaconis rule:
   IQRange  = iqr(x);
   binwidth = 2*IQRange*N^(-1/3);
   numbins  = ceil((max(x)-min(x))/binwidth);
   
   % equiprobable
   numbins  = ceil(2*N^(2/5));
   
   % shimazaki shinimoto
   % complicated, numerical iteration i think
   numbins  = sshist(x);
   binwidth = (max(x)-min(x))/numbins;
   
   %
   edges    = linspace(min(x),max(x),numbins);
   
   
