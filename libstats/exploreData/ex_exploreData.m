
% test normally distributed data
clean
N       = 1000;
x       = normrnd(0,2,N,1);
stats   = exploreData(x);

% test exponentially distributed data
clean
N       = 1000;
x       = exprnd(15,N,1);
stats   = exploreData(x);

% test log-normally distributed data
clean
N       = 1000;
x       = lognrnd(log(2),log(4),N,1);
stats   = exploreData(x);