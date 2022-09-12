function h = plawgof(x,xmin)

% recommended: 
% stats.stackexchange.com/questions/111268/kolmogorov-smirnov-for-pareto-distribution-on-sample

% Case 1: known xmin, unknown α:
% - if xmin isn't 1, divide by xm, so you have a pareto with xmin = 1, 
% - take logs, resulting in an exponential with unknown scale parameter α
% - apply Lilliefors test for an exponential random variable

% Case 2: unknown xmin, unknown α:
% - take logs, yielding a shifted exponential
% - subtract the minimum observation from all observations, and discard the
% minimum, leaving n-1 observations
% - test the reduced sample for exponentiality as above

% first test the original data
hexp     = lillietest(x,'Distr','exp');   % null = exponential, 1 = reject exp
hev      = lillietest(x,'Distr','ev');    % null = extreme value, 1 = reject ev
hnorm    = lillietest(x,'Distr','norm');  % null = normal, 1 = reject normal

if nargin == 2
   x        = log(x./xmin);
   hexppl   = lillietest(x,'Distr','exp');
   hevpl    = lillietest(x,'Distr','ev');
   hnormpl  = lillietest(x,'Distr','norm');
   
elseif nargin == 1
   
   x        = log(x);
   x        = x(x>min(x))-min(x);
   hexppl   = lillietest(x,'Distr','exp');
   hevpl    = lillietest(log(x),'Distr','ev');
   hevnorm  = lillietest(log(x),'Distr','norm');
   
end

