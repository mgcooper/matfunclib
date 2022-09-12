function [F,x,Fx] = plcdf(x,xmin,alpha)
   
   % Inputs:
   %  x     = data (observed states)
   %  xmin  = threshold power law behavior
   %  alpha = exponent of the power law pdf
   
   % Outputs:
   % F      = theoretical plaw cdf (0:numdata-1)./numdata
   % x      = sorted (ranked) data from low to high
   
   x     = sort(x);
   x     = x(x>=xmin);                 % truncate the data
   N     = length(x);                  % sample size for z>zmin
   lam   = alpha-1;                    % alpha-1 (cdf exponent)
   Fx    = (0:N-1)'./N;                % the empirical cdf
   F     = 1-(xmin./x).^lam;           % the theoretical cdf
   
   % maybe an easier way to see what it really means:
   x     = sort(x);
   x     = x(x>=xmin);                 % truncate the data
   N     = length(x);                  % sample size for z>zmin
   lam   = alpha-1;                    % alpha-1 (cdf exponent)
   Fx    = (0:N-1)'./N;                % the empirical cdf
   F     = 1-(xmin./x).^lam;           % the theoretical cdf
   
   
   % this is how i had it in myplfit but this isn't how we want it in general
%    x     = sort(x);
%    x     = x(x>=xmin);                 % truncate the data
%    N     = length(x);                  % sample size for z>zmin
%    lam   = N ./ sum( log(x./xmin) );   % mle to get alpha-1 (cdf exponent)
%    cx    = (0:N-1)'./N;                % the empirical cdf
%    cf    = 1-(xmin./x).^lam;           % the theoretical cdf
%    alpha = 1+1/lam;                    % plaw exponent
%    xtr   = x;                          % truncated data


% this came from me translating plfit to my own notation, and the process
% of fitting the data is different than what this function should actually
% do. For exmaple, when fitting, we take the data that was provided to the
% function, sort it, 

   
end