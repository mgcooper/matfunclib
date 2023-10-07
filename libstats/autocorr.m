function [ lagcorr ] = autocorr( X, lag, dim )
   %AUTOCORR compute autocorrelation of vector for lag along dimension dim
   %
   % [ lagcorr ] = autocorr( X, lag, dim ) returns the lagged auto-correlation
   % of data in vector or matrix X. If X is a matrix, use DIM to control the
   % dimension along which the correlation is computed.
   %
   % See also

   numsamples = size(X,dim) - lag;

   Xbar = mean(X,dim);
   Xvar = var(X,numsamples,dim);

   dif = X - Xbar;
   dif1 = dif(1:end-lag);
   dif2 = dif(lag+1:end);

   difprod = dif1.*dif2;
   difprodsum = sum(difprod,dim);
   C = difprodsum/numsamples;

   lagcorr = C/Xvar;
end
